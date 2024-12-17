import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_sqlite/db.dart' show InsertForeignKey;
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:source_gen/source_gen.dart';

///
abstract class SqliteSerdesGenerator<_Model extends SqliteModel>
    extends SerdesGenerator<Sqlite, _Model> {
  @override
  final providerName = 'Sqlite';

  @override
  final String repositoryName;

  ///
  SqliteSerdesGenerator(
    super.element,
    SqliteFields super.fields, {
    required this.repositoryName,
  });

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
  bool ignoreCoderForField(FieldElement field, Sqlite annotation, SharedChecker<Model> checker) {
    if (annotation.columnType != null) {
      if (checker.isSerializable) return false;

      if (doesDeserialize) {
        if (annotation.fromGenerator == null) {
          throw InvalidGenerationSourceError(
            'Decalaring column type ${annotation.columnType} on ${field.name} requires `fromGenerator` to be declared',
          );
        }
      } else {
        if (annotation.toGenerator == null) {
          throw InvalidGenerationSourceError(
            'Decalaring column type ${annotation.columnType} on ${field.name} requires `toGenerator` to be declared',
          );
        }
      }

      return false;
    }

    return super.ignoreCoderForField(field, annotation, checker);
  }

  /// Generate foreign key column if the type is a sibling;
  /// otherwise, return the field's annotated name;
  @override
  String providerNameForField(String? annotatedName, {required SharedChecker<Model> checker}) {
    if (checker.isSibling) {
      return InsertForeignKey.foreignKeyColumnName(
        SharedChecker.withoutNullability(checker.unFuturedType),
        annotatedName,
      );
    }

    return annotatedName ?? '';
  }
}
