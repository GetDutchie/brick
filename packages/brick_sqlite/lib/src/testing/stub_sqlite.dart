import 'package:brick_sqlite_abstract/db.dart' show InsertTable;
import 'package:brick_sqlite/sqlite.dart';
import 'package:meta/meta.dart';
import 'package:flutter/services.dart';

/// Used when you just want to stub SQLite method channel responses.
class StubSqlite {
  /// The accessed provider. While this provider's methods can be mocked, it should have the same
  /// [ModelDictionary] used by the implementation.
  final SqliteProvider provider;

  /// How SQFLite will respond given a successful query mapped by model types.
  /// The [Type] key must be a class the extends a [SqliteModel]
  final Map<Type, List<Map<String, dynamic>>> responses;

  /// All methods sent to the [sqliteChannel] are stored here for debug purposes.
  /// It is strongly recommended to include `tearDown(StubSqlite.sqliteLogs.clear)` in your suite.
  static final sqliteLogs = List<MethodCall>();

  static const MethodChannel sqliteChannel = MethodChannel('com.tekartik.sqflite');

  StubSqlite(this.provider, {this.responses}) {
    initialize();
  }

  /// Invoked immediately after instantiation
  void initialize() => stub();

  void stub() {
    sqliteChannel.setMockMethodCallHandler((methodCall) async {
      sqliteLogs.add(methodCall);

      if (methodCall.method == 'getDatabasesPath') {
        return Future.value('db');
      }

      if (methodCall.method == 'openDatabase') {
        return Future.value(null);
      }

      for (var modelType in responses.keys) {
        final tableName = provider.modelDictionary.adapterFor[modelType].tableName;
        if (statementIncludesModel(tableName, methodCall))
          return returnFromResponses(
            responses: responses[modelType],
            tableName: tableName,
            methodCall: methodCall,
          );
      }
    });
  }

  /// Given responses and the requested model ([tableName]), return stubbed SQLite data
  static dynamic returnFromResponses({
    List<Map<String, dynamic>> responses,
    String tableName,
    MethodCall methodCall,
  }) {
    responses = addPrimaryKeysToResponses(responses);
    responses = convertBoolValuesToInt(responses);

    final query = methodCall.arguments['sql'] as String;
    final arguments = methodCall.arguments['arguments'] as List<dynamic>;

    if (methodCall.method == 'insert') {
      return responses.length + 1;
    }
    if (query.startsWith('SELECT COUNT(*)')) {
      if (query.endsWith('`$tableName`')) {
        return [
          {'COUNT(*)': responses.length}
        ];
      }
    }

    // Delete all
    if (query.endsWith('`$tableName`')) {
      return methodCall.method == 'delete' ? responses.length : responses;
    }

    final response = responses.firstWhere(
      (r) =>
          r[InsertTable.PRIMARY_KEY_COLUMN] ==
          queryValueForColumn(InsertTable.PRIMARY_KEY_COLUMN, query, arguments),
      orElse: () => responses.lastWhere(
        (r) => !r.containsKey(InsertTable.PRIMARY_KEY_COLUMN),
        orElse: () => responses.first,
      ),
    );

    if (response == null) {
      return [{}];
    }

    final queryMatchesStub = queryMatchesResponse(response, query, arguments);

    if (!queryMatchesStub) {
      return methodCall.method == 'delete' ? 0 : [{}];
    }

    if (methodCall.method == 'update') {
      assert(
        response.containsKey(InsertTable.PRIMARY_KEY_COLUMN),
        'Expected response must include ${InsertTable.PRIMARY_KEY_COLUMN} for update queries',
      );
      return response[InsertTable.PRIMARY_KEY_COLUMN];
    }

    if (methodCall.method == 'delete') {
      return 1;
    }

    if (!response.containsKey(InsertTable.PRIMARY_KEY_COLUMN)) {
      response[InsertTable.PRIMARY_KEY_COLUMN] = 1;
    }

    return [response];
  }

  /// Determines whether the method call is requesting data from a specific table.
  static bool statementIncludesModel(String tableName, MethodCall methodCall) {
    final query = methodCall.arguments['sql'] as String;
    // select and delete
    return query.contains('FROM `$tableName`') ||
        // insert
        query.contains('INTO `$tableName`') ||
        // count and delete
        query.endsWith('`$tableName`');
  }

  /// Assign an arbitrary id to the expected response
  @visibleForTesting
  @protected
  static List<Map<String, dynamic>> addPrimaryKeysToResponses(
    List<Map<String, dynamic>> responses,
  ) {
    int index = 0;
    return responses
        .map((resp) {
          index++;
          if (resp.containsKey(InsertTable.PRIMARY_KEY_COLUMN)) {
            // If defined id is greater than index, move index to that position to avoid
            // non unique ids
            if (resp[InsertTable.PRIMARY_KEY_COLUMN] >= index) {
              index = resp[InsertTable.PRIMARY_KEY_COLUMN];
            } else {
              throw StateError(
                '${resp[InsertTable.PRIMARY_KEY_COLUMN]} is less than previous iterables. Do not specify ${InsertTable.PRIMARY_KEY_COLUMN} or include this element - $resp - earlier in the list of expected responses.',
              );
            }
            return resp;
          }

          resp[InsertTable.PRIMARY_KEY_COLUMN] = index;
          return resp;
        })
        .toList()
        .cast<Map<String, dynamic>>();
  }

  /// Queries from Brick have boolean values converted to int because SQLite stores booleans as ints.
  /// Responses must be similarly converted before they're used in comparison for result fetching.
  @visibleForTesting
  @protected
  static List<Map<String, dynamic>> convertBoolValuesToInt(List<Map<String, dynamic>> responses) {
    return responses
        .map((response) {
          final entriesWithBoolConvertedToInt =
              response.entries.map<MapEntry<String, dynamic>>((e) {
            var value = e.value;
            if (e.value == true) value = 1;
            if (e.value == false) value = 0;
            return MapEntry(e.key, value);
          });

          return Map.fromEntries(entriesWithBoolConvertedToInt);
        })
        .toList()
        .cast<Map<String, dynamic>>();
  }

  /// Discovers value within a query for a single column.
  /// For example, in the query `WHERE first_name = ?` and arguments `['Thomas']`,
  /// `'Thomas'` would be returned
  static dynamic queryValueForColumn(String columnName, String query, List arguments) {
    final queryMatches = RegExp(r'(\w+)\s=\s\?').allMatches(query).toList();
    final queryMatch = queryMatches.firstWhere((match) {
      final matchedColumnName = match.group(1);

      if (matchedColumnName == columnName) {
        return true;
      }

      return false;
    }, orElse: () => null);

    return queryMatch == null ? null : arguments[queryMatches.indexOf(queryMatch)];
  }

  /// Expands a WHERE query into a true/false match.
  static bool queryMatchesResponse(Map<String, dynamic> response, String query, List arguments) {
    final whereStatement = RegExp(r'WHERE\s?(.*)$').allMatches(query);
    if (whereStatement.isEmpty) {
      return true;
    }

    final clauseMatches = RegExp(r'\(?([\w=\?\d\s]+)\)?\s?(AND|OR)?')
        .allMatches(whereStatement.first.group(1))
        .toList();
    return clauseMatches.fold<bool>(false, (acc, match) {
      final clause = match.group(0).trim().replaceAll('(', '').replaceAll(')', '');
      final columnMatches = RegExp(r'(\w+)\s=\s\?(AND|OR)?').allMatches(clause).toList();
      final clauseDoesMatch = columnMatches.fold<bool>(acc, (columnAcc, columnMatch) {
        final columnName = columnMatch.group(1);
        final columnValueIndex = clauseMatches.indexOf(match) + columnMatches.indexOf(columnMatch);
        final columnValue = arguments[columnValueIndex];
        final columnDoesMatch = response[columnName] != null && response[columnName] == columnValue;

        if (columnMatch.group(0).endsWith('AND')) {
          return columnAcc && columnDoesMatch;
        }

        return columnAcc || columnDoesMatch;
      });

      if (clause.endsWith('AND')) {
        return acc && clauseDoesMatch;
      }

      return acc || clauseDoesMatch;
    });
  }
}
