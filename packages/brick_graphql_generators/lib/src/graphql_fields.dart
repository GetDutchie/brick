// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_rest_generators/generators.dart';
import 'package:brick_rest/rest.dart' show FieldRename;

/// Find `@GraphQL` given a field
class GraphQLAnnotationFinder extends RestAnnotationFinder {
  GraphQLAnnotationFinder([GraphQLSerializable? config]) : super(config);

  /// Change serialization key based on the configuration.
  /// `name` defined with a field annotation (`@GraphQL`) take precedence.
  String _renameField(String name) {
    final renameTo = config?.fieldRename ?? GraphQLSerializable.defaults.fieldRename;
    switch (renameTo) {
      case FieldRename.none:
        return name;
      case FieldRename.snake:
        return StringHelpers.snakeCase(name);
      case FieldRename.kebab:
        return StringHelpers.kebabCase(name);
      case FieldRename.pascal:
        return StringHelpers.pascalCase(name);
      default:
        throw FallThroughError();
    }
  }

  @override
  GraphQL from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return GraphQL(
        ignore: GraphQL.defaults.ignore,
        ignoreFrom: GraphQL.defaults.ignoreFrom,
        ignoreTo: GraphQL.defaults.ignoreTo,
        name: _renameField(element.name),
        nullable: GraphQL.defaults.nullable,
        enumAsString: GraphQL.defaults.enumAsString,
      );
    }

    return GraphQL(
      defaultValue: obj.getField('defaultValue')!.toStringValue(),
      enumAsString: obj.getField('enumAsString')!.toBoolValue() ?? GraphQL.defaults.enumAsString,
      fromGenerator: obj.getField('fromGenerator')!.toStringValue(),
      ignore: obj.getField('ignore')!.toBoolValue() ?? GraphQL.defaults.ignore,
      ignoreFrom: obj.getField('ignoreFrom')!.toBoolValue() ?? GraphQL.defaults.ignoreFrom,
      ignoreTo: obj.getField('ignoreTo')!.toBoolValue() ?? GraphQL.defaults.ignoreTo,
      name: obj.getField('name')!.toStringValue() ?? _renameField(element.name),
      nullable: obj.getField('nullable')!.toBoolValue() ?? GraphQL.defaults.nullable,
      toGenerator: obj.getField('toGenerator')!.toStringValue(),
    );
  }
}

/// Converts all fields to [GraphQL]s for later consumption
class GraphQLFields extends RestFields {
  @override
  final GraphQLAnnotationFinder finder;

  GraphQLFields(ClassElement element, [GraphQLSerializable? config])
      : finder = GraphQLAnnotationFinder(config),
        super(element, config);
}
