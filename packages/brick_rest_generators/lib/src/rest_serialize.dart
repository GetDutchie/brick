import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_json_generators/json_serialize.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] to REST data
class RestSerialize extends RestSerdesGenerator with JsonSerialize<RestModel, Rest> {
  RestSerialize(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  List<String> get instanceFieldsAndMethods {
    var toKey = (fields as RestFields).config?.toKey?.trim();

    if (toKey != null) toKey = "'$toKey'";

    return ['@override\nfinal String? toKey = $toKey;'];
  }
}
