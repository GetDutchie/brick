import 'package:brick_json_generators/json_serdes_generator.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';

///
abstract class RestSerdesGenerator extends JsonSerdesGenerator<RestModel, Rest> {
  ///
  RestSerdesGenerator(
    super.element,
    RestFields super.fields, {
    required super.repositoryName,
  }) : super(
          providerName: 'Rest',
        );
}
