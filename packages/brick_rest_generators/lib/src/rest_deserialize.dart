import 'package:analyzer/dart/element/element.dart';
import 'package:brick_json_generators/json_deserialize.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] from REST data
class RestDeserialize extends RestSerdesGenerator with JsonDeserialize<RestModel, Rest> {
  /// Generate a function to produce a [ClassElement] from REST data
  RestDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  });

  @override
  List<String> get instanceFieldsAndMethods {
    final config = (fields as RestFields).config;

    return [
      if (config?.requestName != null) '@override\nfinal restRequest = ${config!.requestName};',
    ];
  }
}
