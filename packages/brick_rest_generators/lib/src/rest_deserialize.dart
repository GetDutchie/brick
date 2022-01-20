import 'package:analyzer/dart/element/element.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/src/json_deserialize.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:brick_rest_generators/src/rest_serdes_generator.dart';

/// Generate a function to produce a [ClassElement] from REST data
class RestDeserialize extends RestSerdesGenerator
    with JsonDeserialize<RestModel, Rest> {
  RestDeserialize(
    ClassElement element,
    RestFields fields, {
    required String repositoryName,
  }) : super(element, fields, repositoryName: repositoryName);

  @override
  List<String> get instanceFieldsAndMethods {
    var endpoint = (fields as RestFields).config?.endpoint?.trim() ?? "=> ''";
    var fromKey = (fields as RestFields).config?.fromKey?.trim();
    if (!endpoint.endsWith(';') && !endpoint.endsWith('}')) {
      endpoint += ';';
    }

    if (fromKey != null) fromKey = "'$fromKey'";

    return [
      '@override\nString? restEndpoint({query, instance}) $endpoint',
      '@override\nfinal String? fromKey = $fromKey;',
    ];
  }
}
