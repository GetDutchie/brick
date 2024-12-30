import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_rest_generators/generators.dart';
import 'package:brick_rest_generators/rest_model_serdes_generator.dart';

class _OfflineFirstRestSerialize extends RestSerialize
    with OfflineFirstJsonSerialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstRestSerialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);
}

class _OfflineFirstRestDeserialize extends RestDeserialize
    with OfflineFirstJsonDeserialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstRestDeserialize(
    super.element,
    super.fields, {
    required super.repositoryName,
  }) : offlineFirstFields = OfflineFirstFields(element);
}

///
class OfflineFirstRestModelSerdesGenerator extends RestModelSerdesGenerator {
  ///
  OfflineFirstRestModelSerdesGenerator(
    super.element,
    super.reader, {
    required String super.repositoryName,
  });

  @override
  List<SerdesGenerator> get generators {
    final classElement = element as ClassElement;
    final fields = RestFields(classElement, config);
    return [
      _OfflineFirstRestDeserialize(classElement, fields, repositoryName: repositoryName!),
      _OfflineFirstRestSerialize(classElement, fields, repositoryName: repositoryName!),
    ];
  }
}
