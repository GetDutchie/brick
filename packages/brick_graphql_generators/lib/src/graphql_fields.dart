// Generously inspired by JsonSerializable

import 'package:analyzer/dart/element/element.dart';
import 'package:brick_graphql/graphql.dart';
import 'package:brick_build/generators.dart';

/// Find `@Graphql` given a field
class GraphqlAnnotationFinder extends AnnotationFinder<Graphql> {
  final GraphqlSerializable? config;

  GraphqlAnnotationFinder([this.config]);

  /// Change serialization key based on the configuration.
  /// `name` defined with a field annotation (`@Graphql`) take precedence.
  String _renameField(String name) {
    final renameTo = config?.fieldRename ?? GraphqlSerializable.defaults.fieldRename;
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
  Graphql from(element) {
    final obj = objectForField(element);

    if (obj == null) {
      return Graphql(
        ignore: Graphql.defaults.ignore,
        ignoreFrom: Graphql.defaults.ignoreFrom,
        ignoreTo: Graphql.defaults.ignoreTo,
        name: _renameField(element.name),
        nullable: Graphql.defaults.nullable,
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
      name: obj.getField('name')?.toStringValue() ?? _renameField(element.name),
      nullable: obj.getField('nullable')?.toBoolValue() ?? Graphql.defaults.nullable,
      toGenerator: obj.getField('toGenerator')!.toStringValue(),
    );
  }
}

/// Converts all fields to [Graphql]s for later consumption
class GraphqlFields extends FieldsForClass<Graphql> {
  final GraphqlSerializable? config;
  @override
  final GraphqlAnnotationFinder finder;

  GraphqlFields(ClassElement element, [this.config])
      : finder = GraphqlAnnotationFinder(config),
        super(element: element);
}
