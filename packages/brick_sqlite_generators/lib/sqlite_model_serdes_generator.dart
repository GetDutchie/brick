import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/provider_serializable_generator.dart';
import 'package:brick_sqlite_generators/src/sqlite_deserialize.dart';
import 'package:brick_sqlite_generators/src/sqlite_fields.dart';
import 'package:brick_sqlite_generators/src/sqlite_serdes_generator.dart';
import 'package:brick_sqlite_generators/src/sqlite_serialize.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_sqlite_abstract/annotations.dart';

/// Digest a `sqliteConfig` from [reader] and manage serdes generators
/// to and from a `SqliteProvider`.
class SqliteModelSerdesGenerator extends ProviderSerializableGenerator<SqliteSerializable> {
  /// Repository prefix passed to the generators. Does not include `Repository`.
  final String? repositoryName;

  SqliteModelSerdesGenerator(
    Element element,
    ConstantReader reader, {
    this.repositoryName,
  }) : super(element, reader, configKey: 'sqliteConfig');

  @override
  SqliteSerializable get config {
    if (reader.peek(configKey) == null) {
      return SqliteSerializable.defaults;
    }

    return SqliteSerializable(
      nullable: withinConfigKey('nullable')?.boolValue ?? SqliteSerializable.defaults.nullable,
    );
  }

  @override
  List<SqliteSerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = SqliteFields(classElement, config);
    return [
      SqliteDeserialize(classElement, fields, repositoryName: repositoryName),
      SqliteSerialize(classElement, fields, repositoryName: repositoryName)
    ];
  }
}
