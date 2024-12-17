// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_sqlite/brick_sqlite.dart' show Column, Sqlite, SqliteSerializable;

/// Find `@Sqlite` given a field
class SqliteAnnotationFinder extends AnnotationFinder<Sqlite> {
  ///
  final SqliteSerializable? config;

  /// Find `@Sqlite` given a field
  SqliteAnnotationFinder([this.config]);

  @override
  Sqlite from(FieldElement element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Sqlite(
        enumAsString: Sqlite.defaults.enumAsString,
        ignore: Sqlite.defaults.ignore,
        ignoreTo: Sqlite.defaults.ignoreTo,
        ignoreFrom: Sqlite.defaults.ignoreFrom,
        index: Sqlite.defaults.index,
        name: StringHelpers.snakeCase(element.name),
        nullable: config?.nullable ?? Sqlite.defaults.nullable,
        onDeleteCascade: Sqlite.defaults.onDeleteCascade,
        onDeleteSetDefault: Sqlite.defaults.onDeleteSetDefault,
        unique: Sqlite.defaults.unique,
      );
    }

    final columnTypeValue = obj.getField('columnType')?.getField('index')?.toIntValue();
    final columnType = columnTypeValue != null ? Column.values[columnTypeValue] : null;

    return Sqlite(
      columnType: columnType,
      defaultValue: obj.getField('defaultValue')?.toStringValue(),
      enumAsString: obj.getField('enumAsString')?.toBoolValue() ?? Sqlite.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator')?.toStringValue(),
      ignore: obj.getField('ignore')?.toBoolValue() ?? Sqlite.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom')?.toBoolValue() ?? Sqlite.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo')?.toBoolValue() ?? Sqlite.defaults.ignoreTo,
      index: obj.getField('index')?.toBoolValue() ?? Sqlite.defaults.index,
      name: obj.getField('name')?.toStringValue() ?? StringHelpers.snakeCase(element.name),
      nullable:
          obj.getField('nullable')?.toBoolValue() ?? config?.nullable ?? Sqlite.defaults.nullable,
      onDeleteCascade:
          obj.getField('onDeleteCascade')?.toBoolValue() ?? Sqlite.defaults.onDeleteCascade,
      onDeleteSetDefault:
          obj.getField('onDeleteSetDefault')?.toBoolValue() ?? Sqlite.defaults.onDeleteSetDefault,
      toGenerator: obj.getField('toGenerator')?.toStringValue(),
      unique: obj.getField('unique')?.toBoolValue() ?? Sqlite.defaults.unique,
    );
  }
}

/// Converts all fields to [Sqlite]s for later consumption
class SqliteFields extends FieldsForClass<Sqlite> {
  @override
  final SqliteAnnotationFinder finder;

  ///
  final SqliteSerializable? config;

  /// Converts all fields to [Sqlite]s for later consumption
  SqliteFields(ClassElement element, [this.config])
      : finder = SqliteAnnotationFinder(config),
        super(element: element);
}
