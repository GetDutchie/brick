import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/src/rest_fields.dart';
import 'package:meta/meta.dart';

abstract class RestSerdesGenerator<_Model extends RestModel> extends SerdesGenerator<Rest, _Model> {
  final providerName = 'Rest';

  final String repositoryName;

  RestSerdesGenerator(
    ClassElement element,
    RestFields fields, {
    @required this.repositoryName,
  }) : super(element, fields);
}
