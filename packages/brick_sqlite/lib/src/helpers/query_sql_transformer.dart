import 'package:brick_core/core.dart' show Query, WhereCondition, Compare, WherePhrase;
import 'package:brick_sqlite/src/db/migration_commands/insert_foreign_key.dart';
import 'package:brick_sqlite/src/db/migration_commands/insert_table.dart';
import 'package:brick_sqlite/src/models/sqlite_model.dart';
import 'package:brick_sqlite/src/runtime_sqlite_column_definition.dart';
import 'package:brick_sqlite/src/sqlite_adapter.dart';
import 'package:brick_sqlite/src/sqlite_model_dictionary.dart';
import 'package:meta/meta.dart' show protected;

/// Create a prepared SQLite statement for eventual execution. Only [statement] and [values]
/// should be accessed.
///
/// Example (using SQLFlite):
/// ```dart
/// final sqliteQuery = QuerySqlTransformer(modelDictionary: dict, query: query);
/// final results = await (await db).rawQuery(sqliteQuery.statement, sqliteQuery.values);
/// ```
class QuerySqlTransformer<_Model extends SqliteModel> {
  final SqliteAdapter adapter;
  final SqliteModelDictionary modelDictionary;
  final List<String> _statement = <String>[];
  final List<String> _where = <String>[];
  final Set<String> _innerJoins = <String>{};
  final List<dynamic> _values = <dynamic>[];

  /// Must-haves for the [statement], mainly used to build clauses
  final Query? query;

  /// An executable, prepared SQLite statement
  String get statement => _statement.join(' ').trim();

  /// The values to be included in the execution of the prepared statement
  List<dynamic> get values => _values.map((v) {
        /// SQLite considers boolean values by 1 and 0, so they must be converted
        if (v == true) return 1;
        if (v == false) return 0;
        return v;
      }).toList();

  /// Prepared; includes preceeding `WHERE`
  String get whereClause {
    if (_where.isNotEmpty) {
      final cleanedClause = _cleanWhereClause(_where.join(''));
      return 'WHERE $cleanedClause';
    }

    return '';
  }

  String get innerJoins => _innerJoins.join(' ');

  /// [selectStatement] will output [statement] as a `SELECT FROM`. When false, the [statement]
  /// output will be a `SELECT COUNT(*)`. Defaults `true`.
  QuerySqlTransformer({
    required this.modelDictionary,
    this.query,
    bool selectStatement = true,
  }) : adapter = modelDictionary.adapterFor[_Model]! {
    generate(selectStatement);
  }

  /// Compute [statement] and [values]
  @protected
  void generate(bool outputAsSelect) {
    // reset to clean instance
    _statement.clear();
    _values.clear();
    _where.clear();
    _innerJoins.clear();

    // Why not SELECT * FROM ?
    // Statements including INNER JOIN will merge the results, and results are only required from the queried table
    // DISTINCT included here for the INNER JOIN hack with one-to-many associations
    final execute = outputAsSelect ? 'SELECT DISTINCT `${adapter.tableName}`.*' : 'SELECT COUNT(*)';

    _statement.add('$execute FROM `${adapter.tableName}`');
    for (final condition in query?.where ?? []) {
      final whereStatement = _expandCondition(condition);
      if (whereStatement.isNotEmpty) _where.add(whereStatement);
    }

    if (_innerJoins.isNotEmpty) _statement.add(innerJoins);
    if (_where.isNotEmpty) _statement.add(whereClause);

    _statement.add(
      AllOtherClausesFragment(
        query?.providerArgs ?? {},
        fieldsToColumns: adapter.fieldsToSqliteColumns,
      ).toString(),
    );
  }

  /// Since the statements are evaluated in a recursive, tree-walking function, they are
  /// prefixed with their `required` operator before being added to the full WHERE clause.
  /// This is a bad hack to remove leading operators (otherwise it's invalid SQL)
  /// and should be refactored after experimental use in the wild.
  String _cleanWhereClause(String dirtyClause) {
    return dirtyClause
        .replaceFirst(RegExp('^ (AND|OR)'), '')
        .replaceAll(RegExp(r' \( (AND|OR)'), ' (')
        .replaceAll(RegExp(r'\(\s+'), '(')
        .trim();
  }

  /// Recursively step through a `Where` or `WherePhrase` to ouput a condition for `WHERE`.
  String _expandCondition(WhereCondition condition, [SqliteAdapter? passedAdapter]) {
    passedAdapter ??= adapter;

    // Begin a separate where phrase
    if (condition is WherePhrase) {
      final phrase = condition.conditions.fold<String>('', (acc, phraseCondition) {
        return acc + _expandCondition(phraseCondition, passedAdapter);
      });
      if (phrase.isEmpty) return '';

      final matcher = condition.isRequired ? 'AND' : 'OR';
      return ' $matcher ($phrase)';
    }

    if (!passedAdapter.fieldsToSqliteColumns.containsKey(condition.evaluatedField)) {
      throw ArgumentError(
        'Field ${condition.evaluatedField} on $_Model is not serialized by SQLite',
      );
    }

    final definition = passedAdapter.fieldsToSqliteColumns[condition.evaluatedField]!;

    /// Add an INNER JOINS statement to the existing list
    if (definition.association) {
      if (condition.value is! WhereCondition) {
        throw ArgumentError(
          'Query value for association ${condition.evaluatedField} on $_Model must be a Where or WherePhrase',
        );
      }

      final associationAdapter = modelDictionary.adapterFor[definition.type]!;

      // For nested associations, discover the prior nest based on the table within
      // the last generated statement
      final priorTable = _innerJoins.isEmpty
          ? null
          : RegExp(r'^INNER JOIN `(\w+)`').firstMatch(_innerJoins.last)?.group(1);
      // Determining if the prior table is required for this operation can be done by
      // ensuring the column definition does exist on the queried adapter (otherwise it
      // would be declared on the source, primary queried table)
      // Check for prior table to minimize potentially-costly firstWhere operation
      final column = priorTable != null
          ? adapter.fieldsToSqliteColumns.values
              .firstWhereOrNull((e) => e.columnName == definition.columnName)
          : null;
      final association = AssociationFragment(
        definition: definition,
        foreignTableName: associationAdapter.tableName,
        localTableName: column != null ? adapter.tableName : (priorTable ?? adapter.tableName),
      );
      // Avoid duplicate INNER JOIN declarations
      if (priorTable != associationAdapter.tableName) {
        _innerJoins.addAll(association.toJoinFragment());
      }
      return _expandCondition(condition.value as WhereCondition, associationAdapter);
    }

    /// The value is still not at the column level, so the process must restart
    if (condition.value is WhereCondition) {
      return _expandCondition(condition.value as WhereCondition, passedAdapter);
    }

    /// Finally add the column to the complete phrase
    final sqliteColumn = passedAdapter.tableName != adapter.tableName || _innerJoins.isNotEmpty
        ? '`${passedAdapter.tableName}`.${definition.columnName}'
        : definition.columnName;
    final where = WhereColumnFragment(condition, sqliteColumn);
    _values.addAll(where.values);
    return where.toString();
  }
}

/// Inner joins
class AssociationFragment {
  final String foreignTableName;

  final RuntimeSqliteColumnDefinition definition;

  final String localTableName;

  AssociationFragment({
    required this.definition,
    required this.foreignTableName,
    required this.localTableName,
  });

  List<String> toJoinFragment() {
    const primaryKeyColumn = InsertTable.PRIMARY_KEY_COLUMN;
    final oneToOneAssociation = !definition.iterable;
    final localColumnName = definition.columnName;
    final localTableColumn = '`$localTableName`.${definition.columnName}';

    if (oneToOneAssociation) {
      return [
        'INNER JOIN `$foreignTableName` ON $localTableColumn = `$foreignTableName`.$primaryKeyColumn'
      ];
    }

    final joinsTableName =
        InsertForeignKey.joinsTableName(localColumnName, localTableName: localTableName);
    // ['1','2','3','4']
    return [
      'INNER JOIN `$joinsTableName` ON `$localTableName`.$primaryKeyColumn = `$joinsTableName`.${InsertForeignKey.joinsTableLocalColumnName(localTableName)}',
      'INNER JOIN `$foreignTableName` ON `$foreignTableName`.$primaryKeyColumn = `$joinsTableName`.${InsertForeignKey.joinsTableForeignColumnName(foreignTableName)}'
    ];
  }
}

/// Column and iterable comparison
class WhereColumnFragment {
  final String column;

  final WhereCondition condition;

  String get matcher => condition.isRequired ? 'AND' : 'OR';

  String get sign {
    if (condition.value == null) {
      if (condition.compare == Compare.exact) return 'IS';
      if (condition.compare == Compare.notEqual) return 'IS NOT';
    }

    return compareSign(condition.compare);
  }

  final List values = [];

  /// Computed once after initialization by [generate]
  late final String? _statement;

  WhereColumnFragment(
    this.condition,
    this.column,
  ) {
    _statement = generate();
  }

  @protected
  String generate() {
    if (condition.value is Iterable) {
      if (condition.compare == Compare.between) {
        return _generateBetween();
      }

      return _generateIterable();
    }

    if (condition.value == null) {
      return ' $matcher $column $sign NULL';
    } else {
      values.add(sqlifiedValue(condition.value, condition.compare));
    }

    return ' $matcher $column $sign ?';
  }

  @protected
  dynamic sqlifiedValue(dynamic value, Compare compare) {
    if (compare == Compare.contains || compare == Compare.doesNotContain) {
      return '%$value%';
    }

    if (value == null) return 'NULL';

    return value;
  }

  @override
  String toString() => _statement ?? '';

  static String compareSign(Compare compare) {
    switch (compare) {
      case Compare.exact:
        return '=';
      case Compare.contains:
        return 'LIKE';
      case Compare.doesNotContain:
        return 'NOT LIKE';
      case Compare.greaterThan:
        return '>';
      case Compare.greaterThanOrEqualTo:
        return '>=';
      case Compare.lessThan:
        return '<';
      case Compare.lessThanOrEqualTo:
        return '<=';
      case Compare.between:
        return 'BETWEEN';
      case Compare.notEqual:
        return '!=';
    }
  }

  String _generateBetween() {
    if (condition.value.length != 2) {
      throw ArgumentError(
          '''${condition.evaluatedField} expects only two arguments with Compare.between.
          Instead received ${condition.value}''');
    }

    values.addAll(condition.value);
    return ' $matcher $column $sign ? AND ?';
  }

  String _generateIterable() {
    final wherePrepared = [];

    condition.value.forEach((conditionValue) {
      wherePrepared.add('$column $sign ?');
      values.add(sqlifiedValue(conditionValue, condition.compare));
    });

    return ' $matcher ${wherePrepared.join(' $matcher ')}';
  }
}

/// Query modifiers such as `LIMIT`, `OFFSET`, etc. that require minimal logic.
class AllOtherClausesFragment {
  final Map<String, RuntimeSqliteColumnDefinition> fieldsToColumns;
  final Map<String, dynamic> providerArgs;

  /// Order matters. For example, LIMIT has to follow an ORDER BY but precede an OFFSET.
  static const _supportedOperators = <String, String>{
    'collate': 'COLLATE',
    'orderBy': 'ORDER BY',
    'groupBy': 'GROUP BY',
    'having': 'HAVING',
    'limit': 'LIMIT',
    'offset': 'OFFSET',
  };

  /// These operators declare a column to compare against. The fields provided in [providerArgs]
  /// will have to be converted to their column name.
  /// For example, `'orderBy': 'createdAt ASC'` must become `ORDER BY created_at ASC`.
  static const _operatorsDeclaringFields = <String>{'ORDER BY', 'GROUP BY', 'HAVING'};

  AllOtherClausesFragment(
    Map<String, dynamic>? providerArgs, {
    required this.fieldsToColumns,
  }) : providerArgs = providerArgs ?? {};

  @override
  String toString() {
    return _supportedOperators.entries.fold<List<String>>(<String>[], (acc, entry) {
      final op = entry.value;
      var value = providerArgs[entry.key];

      if (value == null) return acc;

      if (_operatorsDeclaringFields.contains(op)) {
        value = value.toString().split(',').fold<String>(value.toString(),
            (modValue, innerValueClause) {
          final fragment = innerValueClause.trim().split(' ');
          if (fragment.isEmpty) return modValue;

          final fieldName = fragment.first;
          final columnDefinition = fieldsToColumns[fieldName];
          var columnName = columnDefinition?.columnName;
          if (columnName != null && modValue.contains(fieldName)) {
            if (columnDefinition!.type == DateTime) {
              columnName = 'datetime($columnName)';
            }
            return modValue.replaceAll(fieldName, columnName);
          }

          return modValue;
        });
      }

      acc.add('$op $value');

      return acc;
    }).join(' ');
  }
}

// Taken directly from the Dart collection package
// Copied here to avoid the extra dependency
extension _CollectionClone<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
