import 'package:test/test.dart';

import 'offline_first_generator/test_primitive_fields.dart' as _$primitiveFields;
import 'offline_first_generator/test_nullable_field.dart' as _$nullableField;
import 'offline_first_generator/test_futures.dart' as _$futures;
import 'offline_first_generator/test_offline_first_where.dart' as _$offlineFirstWhere;
import 'offline_first_generator/test_offline_first_apply_to_remote_deserialization.dart'
    as _$offlineFirstRemoteDeserialization;
import 'offline_first_generator/test_custom_offline_first_serdes.dart'
    as _$customOfflineFirstSerdes;
import 'offline_first_generator/test_default_value.dart' as _$defaultValue;
import 'offline_first_generator/test_enum_factory_serialize.dart' as _$enumFactorySerialize;
import 'offline_first_generator/test_ignore_field.dart' as _$ignoreField;
import 'offline_first_generator/test_no_final_no_const.dart' as _$noFinalNoConst;
import 'offline_first_generator/test_one_to_many_association.dart' as _$oneToManyAssociation;
import 'offline_first_generator/test_one_to_one_association.dart' as _$oneToOneAssociation;
import 'offline_first_generator/test_only_static_members.dart' as _$onlyStaticMembers;
import 'offline_first_generator/test_unrelated_association.dart' as _$unrelatedAssociation;
import 'offline_first_generator/test_constructor_arguments.dart' as _$constructorArguments;
import 'offline_first_generator/test_offlne_first_serdes_with_type_argument.dart'
    as _$oflineFirstSerdesWithTypeArgument;

import '__helpers__.dart';

void main() {
  group('OfflineFirstJsonGenerators', () {
    group('constructor arguments', () {
      test('repositoryName', () async {
        final generator = OfflineFirstWithTestGenerator(repositoryName: 'MyCustom');
        await generateAdapterExpectation(
            'constructor_arguments', _$constructorArguments.repositoryNameAdapterExpectation,
            generator: generator);
      });

      test('superAdapterName', () async {
        final generator = OfflineFirstWithTestGenerator(superAdapterName: 'SuperDuper');
        await generateAdapterExpectation(
            'constructor_arguments', _$constructorArguments.superAdapterNameAdapterExpectation,
            generator: generator);
      });
    });

    group('#generate', () {
      test('CustomOfflineFirstSerdes', () async {
        await generateExpectation('custom_offline_first_serdes', _$customOfflineFirstSerdes.output);
      });

      test('EnumFactorySerialize', () async {
        await generateExpectation('enum_factory_serialize', _$enumFactorySerialize.output);
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

    group('FieldSerializable', () {
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

      test('offlineFirstApplyToRemoteDeserialization', () async {
        await generateAdapterExpectation('offline_first_apply_to_remote_deserialization',
            _$offlineFirstRemoteDeserialization.output);
      });
    });
  });
}
