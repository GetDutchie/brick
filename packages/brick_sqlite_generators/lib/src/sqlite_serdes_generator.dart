import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_sqlite_abstract/annotations.dart';
import 'package:brick_sqlite_abstract/db.dart' show InsertForeignKey;
import 'package:brick_sqlite_abstract/sqlite_model.dart';
import 'package:source_gen/source_gen.dart';

import 'sqlite_fields.dart';

abstract class SqliteSerdesGenerator<_Model extends SqliteModel>
    extends SerdesGenerator<Sqlite, _Model> {
  @override
  final providerName = 'Sqlite';

  @override
  final String repositoryName;

  SqliteSerdesGenerator(
    ClassElement element,
    SqliteFields fields, {
    required this.repositoryName,
  }) : super(element, fields);

  /// External models, such as REST or I/O, pull type inference data from class constructors.
  /// This is to allow for class constructors to process potentially nullable data
  /// into non-nullable data by assigning a default at initialization, or to allow a class
  /// to process one type into another at construction (eg String myString -> Foo(myString)).
  /// Sqlite data, however, is always serialized from dart -- as a result, we don't care about
  /// mismatches between the constructor and member fields, and will always use the type defined
  /// by the class member.
  @override
  SharedChecker checkerForField(FieldElement field) => checkerForType(field.type);

  @override
  bool ignoreCoderForField(field, annotation, checker) {
    if (annotation.columnType != null) {
      if (checker.isSerializable) return false;

      if (doesDeserialize) {
        if (annotation.fromGenerator == null) {
          throw InvalidGenerationSourceError(
              'Decalaring column type ${annotation.columnType} on ${field.name} requires `fromGenerator` to be declared');
        }
      } else {
        if (annotation.toGenerator == null) {
          throw InvalidGenerationSourceError(
              'Decalaring column type ${annotation.columnType} on ${field.name} requires `toGenerator` to be declared');
        }
      }

      return false;
    }

    return super.ignoreCoderForField(field, annotation, checker);
  }

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  @override
  String providerNameForField(annotatedName, {required checker}) {
    if (checker.isSibling) {
      return InsertForeignKey.foreignKeyColumnName(
          checker.unFuturedType.getDisplayString(withNullability: false), annotatedName);
    }

    return annotatedName ?? '';
  }
}
