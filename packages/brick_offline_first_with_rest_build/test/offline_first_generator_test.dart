import 'package:brick_offline_first_abstract/annotations.dart';
import 'package:test/test.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_generator.dart';
import 'package:brick_build_test/brick_build_test.dart';

import 'offline_first_generator/test_primitive_fields.dart' as _$primitiveFields;
import 'offline_first_generator/test_nullable_field.dart' as _$nullableField;
import 'offline_first_generator/test_futures.dart' as _$futures;
import 'offline_first_generator/test_offline_first_where.dart' as _$offlineFirstWhere;
import 'offline_first_generator/test_custom_offline_first_serdes.dart'
    as _$customOfflineFirstSerdes;
import 'offline_first_generator/test_default_value.dart' as _$defaultValue;
import 'offline_first_generator/test_rest_config_endpoint.dart' as _$restConfigEndpoint;
import 'offline_first_generator/test_rest_config_field_rename.dart' as _$restConfigFieldRename;
import 'offline_first_generator/test_rest_config_response_keys.dart' as _$restConfigResponseKeys;
import 'offline_first_generator/test_custom_serdes.dart' as _$customSerdes;
import 'offline_first_generator/test_ignore_field.dart' as _$ignoreField;
import 'offline_first_generator/test_no_final_no_const.dart' as _$noFinalNoConst;
import 'offline_first_generator/test_one_to_many_association.dart' as _$oneToManyAssociation;
import 'offline_first_generator/test_one_to_one_association.dart' as _$oneToOneAssociation;
import 'offline_first_generator/test_only_static_members.dart' as _$onlyStaticMembers;
import 'offline_first_generator/test_specify_field_name.dart' as _$specifyFieldName;
import 'offline_first_generator/test_unrelated_association.dart' as _$unrelatedAssociation;
import 'offline_first_generator/test_constructor_arguments.dart' as _$constructorArguments;
import 'offline_first_generator/test_offlne_first_serdes_with_type_argument.dart'
    as _$oflineFirstSerdesWithTypeArgument;

final _generator = OfflineFirstGenerator();
final folder = 'offline_first_generator';
final generateReader = generateLibraryForFolder(folder);

void main() {
  group('OfflineFirstGenerator', () {
    group('constructor arguments', () {
      test('repositoryName', () async {
        final generator = OfflineFirstGenerator(repositoryName: 'MyCustom');
        await generateAdapterExpectation(
            'constructor_arguments', _$constructorArguments.repositoryNameAdapterExpectation,
            generator: generator);
      });

      test('superAdapterName', () async {
        final generator = OfflineFirstGenerator(superAdapterName: 'SuperDuper');
        await generateAdapterExpectation(
            'constructor_arguments', _$constructorArguments.superAdapterNameAdapterExpectation,
            generator: generator);
      });
    });

    group('#generate', () {
      test('CustomOfflineFirstSerdes', () async {
        await generateExpectation('custom_offline_first_serdes', _$customOfflineFirstSerdes.output);
      });

      test('CustomSerdes', () async {
        await generateExpectation('custom_serdes', _$customSerdes.output);
      });

      test('NoFinalNoConst', () async {
        await generateExpectation('no_final_no_const', _$noFinalNoConst.output);
      });

      test('OneToManyAssociation', () async {
        await generateAdapterExpectation('one_to_many_association', _$oneToManyAssociation.output);
      });

      test('OneToOneAssociation', () async {
        await generateExpectation('one_to_one_association', _$oneToOneAssociation.output);
      });

      test('OnlyStaticMembers', () async {
        await generateExpectation('only_static_members', _$onlyStaticMembers.output);
      });

      test('PrimitiveFields', () async {
        await generateExpectation('primitive_fields', _$primitiveFields.output);
      });

      test('UnrelatedAssociation', () async {
        await generateExpectation('unrelated_association', _$unrelatedAssociation.output);
      });

      test('Futures', () async {
        await generateAdapterExpectation('futures', _$futures.output);
      });

      test('OfflineFirstSerdesWithTypeArgument', () async {
        await generateAdapterExpectation(
            'offlne_first_serdes_with_type_argument', _$oflineFirstSerdesWithTypeArgument.output);
      });
    });

    group('@ConnectOfflineFirstWithRest', () {
      test('restSerializable#endpoint', () async {
        await generateAdapterExpectation('rest_config_endpoint', _$restConfigEndpoint.output);
      });

      test('restSerializable#fromKey restSerializable#toKey', () async {
        await generateAdapterExpectation(
            'rest_config_response_keys', _$restConfigResponseKeys.output);
      });

      test('restSerializable#nullable', () {}, skip: 'Write implementation and then write test');

      test('restSerializable#fieldRename', () async {
        await generateExpectation('rest_config_field_rename', _$restConfigFieldRename.output);
      });
    });

    group('FieldSerializable', () {
      test('name', () async {
        await generateExpectation('specify_field_name', _$specifyFieldName.output);
      });

      test('defaultValue', () async {
        await generateExpectation('default_value', _$defaultValue.output);
      });

      test('ignore', () async {
        await generateExpectation('ignore_field', _$ignoreField.output);
      });

      test('nullable', () async {
        await generateExpectation('nullable_field', _$nullableField.output);
      });
    });

    group('@OfflineFirst', () {
      test('offlineFirstWhere', () async {
        await generateAdapterExpectation('offline_first_where', _$offlineFirstWhere.output);
      });
    });
  });
}

Future<void> generateExpectation(String filename, String output,
    {OfflineFirstGenerator? generator}) async {
  final reader = await generateReader(filename);
  final generated = await (generator ?? _generator).generate(reader, MockBuildStep());
  expect(generated.trim(), output.trim());
}

Future<void> generateAdapterExpectation(String filename, String output,
    {OfflineFirstGenerator? generator}) async {
  final annotation = await annotationForFile<ConnectOfflineFirstWithRest>(folder, filename);
  final generated = (generator ?? _generator).generateAdapter(
    annotation.element,
    annotation.annotation,
    MockBuildStep(),
  );
  expect(generated.trim(), output.trim());
}
