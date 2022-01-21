import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_rest/rest.dart';
import 'package:brick_rest_generators/generators.dart';
import 'package:brick_rest_generators/rest_model_serdes_generator.dart';
import 'package:source_gen/source_gen.dart';

class _OfflineFirstRestSerialize extends RestSerialize
    with OfflineFirstJsonSerialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstRestSerialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);
}

class _OfflineFirstRestDeserialize extends RestDeserialize
    with OfflineFirstJsonDeserialize<RestModel, Rest> {
  @override
  final OfflineFirstFields offlineFirstFields;

  _OfflineFirstRestDeserialize(ClassElement element, RestFields fields,
      {required String repositoryName})
      : offlineFirstFields = OfflineFirstFields(element),
        super(element, fields, repositoryName: repositoryName);
}

class OfflineFirstRestModelSerdesGenerator extends RestModelSerdesGenerator {
  OfflineFirstRestModelSerdesGenerator(Element element, ConstantReader reader,
      {required String repositoryName})
      : super(element, reader, repositoryName: repositoryName);

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
