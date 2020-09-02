// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_build/src/annotation_finder.dart';
import 'package:brick_build/src/utils/fields_for_class.dart';
import 'package:brick_build/src/utils/string_helpers.dart';

/// Find `@Sqlite` given a field
class SqliteAnnotationFinder extends AnnotationFinder<Sqlite> {
  final SqliteSerializable config;

  SqliteAnnotationFinder([this.config]);

  @override
  Sqlite from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Sqlite(
        ignore: Sqlite.defaults.ignore,
        index: Sqlite.defaults.index,
        name: StringHelpers.snakeCase(element.name),
        nullable: config?.nullable ?? Sqlite.defaults.nullable,
        onDeleteCascade: Sqlite.defaults.onDeleteCascade,
        onDeleteSetDefault: Sqlite.defaults.onDeleteSetDefault,
        unique: Sqlite.defaults.unique,
      );
    }

    return Sqlite(
      defaultValue: obj.getField('defaultValue').toStringValue(),
      fromGenerator: obj.getField('fromGenerator').toStringValue(),
      ignore: obj.getField('ignore').toBoolValue() ?? Sqlite.defaults.ignore,
      index: obj.getField('index').toBoolValue() ?? Sqlite.defaults.index,
      name: obj.getField('name').toStringValue() ?? StringHelpers.snakeCase(element.name),
      nullable:
          obj.getField('nullable').toBoolValue() ?? config?.nullable ?? Sqlite.defaults.nullable,
      onDeleteCascade:
          obj.getField('onDeleteCascade').toBoolValue() ?? Sqlite.defaults.onDeleteCascade,
      onDeleteSetDefault:
          obj.getField('onDeleteSetDefault').toBoolValue() ?? Sqlite.defaults.onDeleteSetDefault,
      toGenerator: obj.getField('toGenerator').toStringValue(),
      unique: obj.getField('unique').toBoolValue() ?? Sqlite.defaults.unique,
    );
  }
}

/// Converts all fields to [Sqlite]s for later consumption
class SqliteFields extends FieldsForClass<Sqlite> {
  @override
  final SqliteAnnotationFinder finder;
  final SqliteSerializable config;

  SqliteFields(ClassElement element, [this.config])
      : finder = SqliteAnnotationFinder(config),
        super(element: element);
}
