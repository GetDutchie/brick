import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/src/provider_serializable.dart';
import 'package:brick_build/src/sqlite_serdes/sqlite_deserialize.dart';
import 'package:brick_build/src/sqlite_serdes/sqlite_fields.dart';
import 'package:brick_build/src/sqlite_serdes/sqlite_serialize.dart';
import 'package:source_gen/source_gen.dart';
import 'package:brick_offline_first_abstract/annotations.dart';

/// Digest a `sqliteConfig` (`@ConnectOfflineFirst`) from [reader] and manage serdes generators
/// to and from a `SqliteProvider`.
class SqliteSerdes extends ProviderSerializable<SqliteSerializable> {
  /// Repository prefix passed to the generators. Does not include `Repository`.
  final String repositoryName;

  SqliteSerdes(
    Element element,
    ConstantReader reader, {
    this.repositoryName,
  }) : super(element, reader, configKey: 'sqliteConfig');

  @override
  SqliteSerializable get config {
    if (reader.read(configKey).isNull) {
      return SqliteSerializable.defaults;
    }

    return SqliteSerializable(
          nullable: withinConfigKey('nullable')?.boolValue ?? SqliteSerializable.defaults.nullable,
        ) ??
        SqliteSerializable.defaults;
  }

  @override
  get generators {
    final classElement = element as ClassElement;
    final fields = SqliteFields(classElement, config);
    return [
      SqliteDeserialize(classElement, fields, repositoryName: repositoryName),
      SqliteSerialize(classElement, fields, repositoryName: repositoryName)
    ];
  }
}
