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
  @protected
  @visibleForTesting
  static bool queryMatchesResponse(Map<String, dynamic> response, String query, List arguments) {
    // optionally starts with AND or OR
    // optional (
    // capture: one or more characters that match word, numer, space, or ?
    // optional )
    final clauseRegex = RegExp(r'\(?([\w=\?\d\s]+)\)?\s?(?:AND|OR)?');
    // optionally starts with AND or OR
    // capture: {word characters} = ?
    final columnRegex = RegExp(r'(\w+)\s=\s\?\s?(?:AND|OR)?');
    // start with WHERE
    // optional blank space
    // capture: everything
    final whereRegex = RegExp(r'WHERE\s(.*)');
    // Anything after LIMIT, HAVING< ORDER, GROUP, or OFFSET operators
    final withoutOperatorsRegex = RegExp(r'(GROUP|HAVING|LIMIT|OFFSET|ORDER).*');

    final whereStatement = whereRegex.allMatches(query);
    if (whereStatement.isEmpty) return false;

    final wherePhrases = whereStatement.first.group(1).replaceAll(withoutOperatorsRegex, '');
    final phrases = clauseRegex.allMatches(wherePhrases).toList();
    var argumentsPosition = 0;
    var previousPhraseWasAnd = false;

    return phrases.fold<bool>(false, (acc, match) {
      final clause = match.group(0).trim();
      final columnMatches = columnRegex.allMatches(clause).toList();
      final clauseIsAnd = clause.contains('AND');

      final expressionsDoMatch = columnMatches.fold<bool>(false, (columnAcc, columnMatch) {
        final columnName = columnMatch.group(1);
        final columnValue = arguments[argumentsPosition];
        final columnDoesMatch = response[columnName] != null && response[columnName] == columnValue;
        argumentsPosition++;

        if (clauseIsAnd) {
          // on the first pass, ensure that we're not && on the original `false` acc
          if (columnMatches.indexOf(columnMatch) == 0) {
            return columnDoesMatch;
          }

          return columnAcc && columnDoesMatch;
        }

        return columnDoesMatch || columnAcc;
      });

      if (previousPhraseWasAnd) {
        previousPhraseWasAnd = clauseIsAnd;
        // on the first pass, ensure that we're not && on the original `false` acc
        if (phrases.indexOf(match) == 0) {
          return expressionsDoMatch;
        }

        return acc && expressionsDoMatch;
      }

      previousPhraseWasAnd = clauseIsAnd;
      return expressionsDoMatch || acc;
    });
  }
}
