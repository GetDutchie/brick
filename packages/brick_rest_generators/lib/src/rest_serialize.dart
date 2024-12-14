import 'package:analyzer/dart/element/element.dart';
import 'package:brick_json_generators/json_serialize.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class RestSerialize extends RestSerdesGenerator with JsonSerialize<RestModel, Rest> {
  ///
  RestSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });
}
