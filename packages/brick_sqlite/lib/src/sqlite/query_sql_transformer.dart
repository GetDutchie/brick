import 'package:meta/meta.dart' show protected, required;
import 'package:brick_core/core.dart' show Query, WhereCondition, Compare, WherePhrase;
import 'package:brick_sqlite_abstract/db.dart' show InsertTable;

import '../../sqlite.dart' show SqliteModel, SqliteModelDictionary, SqliteAdapter;

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
  final List<String> _statement = List<String>();
  final List<String> _where = List<String>();
  final Set<String> _innerJoins = Set<String>();
  final List<dynamic> _values = List<dynamic>();

  /// Must-haves for the [statement], mainly used to build clauses
  final Query query;

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
      return 'WHERE ' + _cleanWhereClause(_where.join(''));
    }

    return '';
  }

  String get innerJoins => _innerJoins.join(' ');

  QuerySqlTransformer({
    @required this.modelDictionary,
    this.query,
  }) : adapter = modelDictionary.adapterFor[_Model] {
    generate();
  }

  /// Compute [statement] and [values]
  @protected
  void generate() {
    // reset to clean instance
    _statement.clear();
    _values.clear();
    _where.clear();
    _innerJoins.clear();

    // Why not SELECT * FROM ?
    // Statements including INNER JOIN will merge the results, and results are only required from the queried table
    // DISTINCT included here for the INNER JOIN hack with one-to-many associations
    _statement.add('SELECT DISTINCT `${adapter.tableName}`.* FROM `${adapter.tableName}`');
    (query?.where ?? []).forEach((condition) {
      String whereStatement = _expandCondition(condition);
      _where.add(whereStatement);
    });

    if (_innerJoins.isNotEmpty) _statement.add(innerJoins);
    if (_where.isNotEmpty) _statement.add(whereClause);

    _statement.add(AllOtherClausesFragment(
      query?.providerArgs ?? {},
      fieldsToColumns: adapter.fieldsToSqliteColumns,
    ).toString());
  }

  /// Since the statements are evaluated in a recursive, tree-walking function, they are
  /// prefixed with their `required` operator before being added to the full WHERE clause.
  /// This is a bad hack to remove leading operators (otherwise it's invalid SQL)
  /// and should be refactored after experimental use in the wild.
  String _cleanWhereClause(String dirtyClause) {
    return dirtyClause
        .replaceFirst(RegExp(r'^ (AND|OR)'), '')
        .replaceAll(RegExp(r' \( (AND|OR)'), ' (')
        .replaceAll(RegExp(r'\(\s+'), '(')
        .trim();
  }

  /// Recursively step through a `Where` or `WherePhrase` to ouput a condition for `WHERE`.
  String _expandCondition(WhereCondition condition, [SqliteAdapter _adapter]) {
    _adapter ??= adapter;

    // Begin a separate where phrase
    if (condition is WherePhrase) {
      final phrase = condition.conditions.fold('', (acc, phraseCondition) {
        return acc + _expandCondition(phraseCondition, _adapter);
      });

      final matcher = condition.required ? 'AND' : 'OR';
      return ' $matcher ($phrase)';
    }

    if (!_adapter.fieldsToSqliteColumns.containsKey(condition.evaluatedField)) {
      throw ArgumentError(
          'Field ${condition.evaluatedField} on $_Model is not serialized by SQLite');
    }

    final definition = _adapter.fieldsToSqliteColumns[condition.evaluatedField];

    /// Add an INNER JOINS statement to the existing list
    if (definition['association']) {
      if (condition.value is! WhereCondition) {
        throw ArgumentError(
            'Query value for association ${condition.evaluatedField} on $_Model must be a Where or WherePhrase');
      }

      final associationAdapter = modelDictionary.adapterFor[definition['type'] as Type];
      final association = AssociationFragment(
        adapter: associationAdapter,
        localTableColumn: '`${adapter.tableName}`.${definition['name']}',
        oneToOneAssociation: !definition['iterable'],
      );
      _innerJoins.add(association.toString());
      return _expandCondition(condition.value, associationAdapter);
    }

    /// The value is still not at the column level, so the process must restart
    if (condition.value is WhereCondition) {
      return _expandCondition(condition.value, _adapter);
    }

    /// Finally add the column to the complete phrase
    final String sqliteColumn = _adapter.tableName != adapter.tableName
        ? '`${_adapter.tableName}`.${definition['name']}'
        : definition['name'];
    final where = WhereColumnFragment(condition, sqliteColumn);
    _values.addAll(where.values);
    return where.toString();
  }
}

/// Inner joins
class AssociationFragment {
  final SqliteAdapter adapter;
  final String localTableColumn;

  /// When false, the query is a one to many association.
  /// Defaults to [true].
  final bool oneToOneAssociation;

  AssociationFragment({
    this.adapter,
    this.localTableColumn,
    this.oneToOneAssociation = true,
  });

  toString() {
    final associationTableName = adapter.tableName;
    final primaryKeyColumn = InsertTable.PRIMARY_KEY_COLUMN;

    // 1) SQLite doesn't support a CONCAT function. It has these weird double pipes instead.
    // 2) For one-to-many queries, the primary key of the parent element is not stored on the child,
    // as the parent is the one who wants to know about the child. Therefore, the query is based on
    // a string array stored in a single parent column. This query is wildly unoptimized and is not
    // recommended. However, until the JSON1 extension enjoys wide support on platforms Brick
    // supports, this hack is necessary.
    // 3) The OR statements prevent queries from returning a row with the id of 10
    // when the id of 1 was specified
    final many = [
      '$localTableColumn LIKE "%," || `$associationTableName`.$primaryKeyColumn || ",%"',
      'OR $localTableColumn LIKE "%," || `$associationTableName`.$primaryKeyColumn || "]"',
      'OR $localTableColumn LIKE "[" || `$associationTableName`.$primaryKeyColumn || "]"',
      'OR $localTableColumn LIKE "[" || `$associationTableName`.$primaryKeyColumn || ",%"',
    ].join(' ');
    final one = '$localTableColumn = `$associationTableName`.$primaryKeyColumn';
    final joinCondition = oneToOneAssociation ? one : many;
    return 'INNER JOIN `$associationTableName` ON $joinCondition';
  }
}

/// Column and iterable comparison
class WhereColumnFragment {
  final String column;

  final WhereCondition condition;

  String get matcher => condition.required ? 'AND' : 'OR';

  String get sign {
    if (condition.value == null) {
      if (condition.compare == Compare.exact) return 'IS';
      if (condition.compare == Compare.notEqual) return 'IS NOT';
    }

    return compareSign(condition.compare);
  }

  final List values = [];

  /// Computed once after initialization by [generate]
  String _statement;

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
  dynamic sqlifiedValue(dynamic _value, Compare compare) {
    if (compare == Compare.contains) {
      return '%$_value%';
    }

    if (_value == null) return 'NULL';

    return _value;
  }

  toString() => _statement;

  static String compareSign(Compare compare) {
    switch (compare) {
      case Compare.exact:
        return '=';
      case Compare.contains:
        return 'LIKE';
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
    throw FallThroughError();
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

    return ' $matcher ' + wherePrepared.join(' $matcher ');
  }
}

/// Query modifiers such as `LIMIT`, `OFFSET`, etc. that require minimal logic.
class AllOtherClausesFragment {
  final Map<String, Map<String, dynamic>> fieldsToColumns;
  final Map<String, dynamic> providerArgs;

  /// Order matters. For example, LIMIT has to follow an ORDER BY but precede an OFFSET.
  static const Map<String, String> _supportedOperators = {
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
  static const List<String> _operatorsDeclaringFields = ['ORDER BY', 'GROUP BY', 'HAVING'];

  AllOtherClausesFragment(
    Map<String, dynamic> providerArgs, {
    this.fieldsToColumns,
  }) : providerArgs = providerArgs ?? {};

  toString() {
    return _supportedOperators.entries.fold(List<String>(), (acc, entry) {
      final op = entry.value;
      var value = providerArgs[entry.key];

      if (value == null) return acc;

      if (_operatorsDeclaringFields.contains(op)) {
        fieldsToColumns.keys.forEach((fieldName) {
          final columnName = (fieldsToColumns[fieldName] ?? {})['name'];

          if (columnName != null && value.contains(fieldName))
            value = value.replaceAll(fieldName, columnName);
        });
      }

      acc.add('$op $value');

      return acc;
    }).join(' ');
  }
}
