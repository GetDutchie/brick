// Generously inspired by JsonSerializable

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_graphql/brick_graphql.dart';
import 'package:brick_graphql_generators/src/graphql_serializable_query_transformer_extended.dart';

/// Find `@Graphql` given a field
class GraphqlAnnotationFinder extends AnnotationFinder<Graphql>
    with AnnotationFinderWithFieldRename {
  ///
  final GraphqlSerializable? config;

  /// Find `@Graphql` given a field
  GraphqlAnnotationFinder([this.config]);

  @override
  Graphql from(FieldElement element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Graphql(
        ignore: Graphql.defaults.ignore,
        ignoreFrom: Graphql.defaults.ignoreFrom,
        ignoreTo: Graphql.defaults.ignoreTo,
        name: renameField(
          element.name,
          config?.fieldRename,
          GraphqlSerializable.defaults.fieldRename,
        ),
        enumAsString: Graphql.defaults.enumAsString,
      );
    }

    return Graphql(
      defaultValue: obj.getField('defaultValue')!.toStringValue(),
      enumAsString: obj.getField('enumAsString')?.toBoolValue() ?? Graphql.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator')!.toStringValue(),
      ignore: obj.getField('ignore')?.toBoolValue() ?? Graphql.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom')?.toBoolValue() ?? Graphql.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo')?.toBoolValue() ?? Graphql.defaults.ignoreTo,
      name: obj.getField('name')?.toStringValue() ??
          renameField(element.name, config?.fieldRename, GraphqlSerializable.defaults.fieldRename),
      subfields: _convertMapToMap(obj.getField('subfields')?.toMapValue()),
      toGenerator: obj.getField('toGenerator')!.toStringValue(),
    );
  }

  static Map<String, Map<String, dynamic>> _convertMapToMap(
    Map<DartObject?, DartObject?>? unconvertedMap,
  ) {
    if (unconvertedMap == null) return {};
    return {
      for (final entry in unconvertedMap.entries)
        entry.key!.toStringValue()!:
            entry.value?.toStringValue() == null ? _convertMapToMap(entry.value!.toMapValue()) : {},
    };
  }
}

/// Converts all fields to [Graphql]s for later consumption
class GraphqlFields extends FieldsForClass<Graphql> {
  ///
  final GraphqlSerializableExtended? config;

  @override
  final GraphqlAnnotationFinder finder;

  /// Converts all fields to [Graphql]s for later consumption
  GraphqlFields(ClassElement element, [this.config])
      : finder = GraphqlAnnotationFinder(config),
        super(element: element);
}
