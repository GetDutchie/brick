// Heavily, heavily inspired by [Aqueduct](https://github.com/stablekernel/aqueduct/blob/master/aqueduct/lib/src/db/schema/migration.dart)

import 'dart:core' as core;
import 'dart:core';

/// SQLite data types.
///
/// While SQLite only supports 5 datatypes, it will still cast these
/// into an [intelligent affinity](https://www.sqlite.org/datatype3.html).
enum Column {
  /// No data type
  undefined._('', dynamic),

  ///
  bigint._('BIGINT', core.num),

  ///
  blob._('BLOB', List),

  ///
  boolean._('BOOLEAN', bool),

  ///
  date._('DATE', DateTime),

  ///
  datetime._('DATETIME', DateTime),

  ///
  // ignore: constant_identifier_names
  Double._('DOUBLE', double),

  ///
  integer._('INTEGER', int),

  ///
  float._('FLOAT', core.num),

  ///
  num._('DOUBLE', core.num),

  ///
  text._('TEXT', String),

  ///
  varchar._('VARCHAR', String);

  /// The equivalent Dart primitive
  final Type dartType;

  /// SQLite equivalent type
  final core.String definition;

  const Column._(this.definition, this.dartType);

  /// Convert native Dart to `Column`
  factory Column.fromDartPrimitive(Type type) {
    switch (type) {
      case bool:
        return Column.boolean;
      case DateTime:
        return Column.datetime;
      case double:
        return Column.Double;
      case int:
        return Column.integer;
      case core.num:
        return Column.num;
      case String:
        return Column.varchar;
      default:
        return throw ArgumentError('$type not associated with a Column');
    }
  }
}
