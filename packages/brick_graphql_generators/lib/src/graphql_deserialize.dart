import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_deserialize.dart';

/// Generate a function to produce a [ClassElement] from Graphql data
class GraphqlDeserialize extends RestDeserialize {
  GraphqlDeserialize(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
