import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_json_generators/json_serdes_generator.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';

abstract class RestSerdesGenerator extends JsonSerdesGenerator<RestModel, Rest> {
  RestSerdesGenerator(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(
          element,
          fields,
          providerName: 'Rest',
          repositoryName: repositoryName,
        );
}
