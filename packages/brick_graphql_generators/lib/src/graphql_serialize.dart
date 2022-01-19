import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serialize.dart';

/// Generate a function to produce a [ClassElement] to REST data
class GraphqlSerialize<_Model extends RestModel> extends RestSerialize {
  GraphqlSerialize(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);
}
