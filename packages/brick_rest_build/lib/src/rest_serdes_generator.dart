import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_build/src/serdes_generator.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_build/src/rest_fields.dart';

abstract class RestSerdesGenerator extends SerdesGenerator<Rest, SharedChecker> {
  static const REST_PROVIDER_NAME = 'Rest';

  final String repositoryName;

  RestSerdesGenerator(
    ClassElement element,
    RestFields fields, {
    this.repositoryName,
  }) : super(element, fields);
}
