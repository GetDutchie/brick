import 'package:brick_build/src/serdes_generator.dart';
import 'package:dart_style/dart_style.dart' as dart_style;
import 'package:source_gen/source_gen.dart';

final _formatter =
    dart_style.DartFormatter(languageVersion: dart_style.DartFormatter.latestLanguageVersion);

/// Given a model, outputs generated code to use as a Brick adapter.
class AdapterGenerator {
  /// The adapted class
  final String className;

  /// The generated output for serializing/deserializing to JSON and SQLite
  final List<SerdesGenerator> generators;

  /// The name of the adapter this instance will extend. For example, `OfflineFirst`.
  /// Does **not** end in `Adapter`.
  final String superAdapterName;

  /// Generated adapter methods
  String get allAdapterMethods => generators.fold<Set<String>>(<String>{}, (acc, generator) {
        final expectedOutput = 'Future<${generator.adapterMethodOutputType}>';
        final methodAction = generator.doesDeserialize ? 'from' : 'to';
        final methodArguments =
            '${generator.adapterMethodInputType} input, {required provider, covariant ${superAdapterName}Repository? repository}';
        final methodName = '$methodAction${generator.providerName}($methodArguments)';

        acc.add('@override\n$expectedOutput $methodName async => ${generator.adapterMethod};');
        return acc;
      }).join('\n');

  /// Any special instance fields the serdes generator needs to forward to the adapter
  String get allInstanceFieldsAndMethods =>
      generators.fold<Set<String>>(<String>{}, (acc, generator) {
        final fromGenerator =
            generator.instanceFieldsAndMethods.fold<Set<String>>(<String>{}, (acc2, field) {
          final didAdd = acc2.add(field);
          if (!didAdd) {
            throw InvalidGenerationSourceError(
              '$field has already been declared by another generator',
            );
          }
          return acc2;
        });
        acc.addAll(fromGenerator);
        return acc;
      }).join('\n');

  /// The functions that serialize or deserialize, ultimately used by the adapter method
  String get serializerFunctions => generators.fold<Set<String>>(<String>{}, (acc, generator) {
        acc.add(generator.generate());
        return acc;
      }).join('\n');

  /// Given a model, outputs generated code to use as a Brick adapter.
  const AdapterGenerator({
    required this.superAdapterName,
    required this.className,
    required this.generators,
  });

  /// Complete adapter code, including imports and serialization/deserialization
  String generate() {
    final output = """
      // GENERATED CODE DO NOT EDIT
      part of '../brick.g.dart';

      $serializerFunctions

      /// Construct a [$className]
      class ${className}Adapter extends ${superAdapterName}Adapter<$className> {
        ${className}Adapter();

        $allInstanceFieldsAndMethods

        $allAdapterMethods
      }
    """;

    return _formatter.format(output);
  }
}
