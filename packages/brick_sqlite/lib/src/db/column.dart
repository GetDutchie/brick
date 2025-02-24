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
    if (type == bool) {
      return Column.boolean;
    } else if (type == DateTime) {
      return Column.datetime;
    } else if (type == double) {
      return Column.Double;
    } else if (type == int) {
      return Column.integer;
    } else if (type == core.num) {
      return Column.num;
    } else if (type == String) {
      return Column.varchar;
    }
    throw ArgumentError('$type not associated with a Column');
  }
}
