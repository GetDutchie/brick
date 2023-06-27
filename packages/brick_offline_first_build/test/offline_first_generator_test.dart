import 'package:test/test.dart';

import '__helpers__.dart';
import 'offline_first_generator/test_constructor_arguments.dart' as constructorArguments;
import 'offline_first_generator/test_custom_offline_first_serdes.dart' as customOfflineFirstSerdes;
import 'offline_first_generator/test_default_value.dart' as defaultValue;
import 'offline_first_generator/test_enum_factory_serialize.dart' as enumFactorySerialize;
import 'offline_first_generator/test_futures.dart' as futures;
import 'offline_first_generator/test_ignore_field.dart' as ignoreField;
import 'offline_first_generator/test_no_final_no_const.dart' as noFinalNoConst;
import 'offline_first_generator/test_nullable_field.dart' as nullableField;
import 'offline_first_generator/test_offline_first_apply_to_remote_deserialization.dart'
    as offlineFirstRemoteDeserialization;
import 'offline_first_generator/test_offline_first_where.dart' as offlineFirstWhere;
import 'offline_first_generator/test_offlne_first_serdes_with_type_argument.dart'
    as oflineFirstSerdesWithTypeArgument;
import 'offline_first_generator/test_one_to_many_association.dart' as oneToManyAssociation;
import 'offline_first_generator/test_one_to_one_association.dart' as oneToOneAssociation;
import 'offline_first_generator/test_only_static_members.dart' as onlyStaticMembers;
import 'offline_first_generator/test_primitive_fields.dart' as primitiveFields;
import 'offline_first_generator/test_unrelated_association.dart' as unrelatedAssociation;

void main() {
  group('OfflineFirstJsonGenerators', () {
    group('constructor arguments', () {
      test('repositoryName', () async {
        final generator = OfflineFirstWithTestGenerator(repositoryName: 'MyCustom');
        await generateAdapterExpectation(
          'constructor_arguments',
          constructorArguments.repositoryNameAdapterExpectation,
          generator: generator,
        );
      });

      test('superAdapterName', () async {
        final generator = OfflineFirstWithTestGenerator(superAdapterName: 'SuperDuper');
        await generateAdapterExpectation(
          'constructor_arguments',
          constructorArguments.superAdapterNameAdapterExpectation,
          generator: generator,
        );
      });
    });

    group('#generate', () {
      test('CustomOfflineFirstSerdes', () async {
        await generateExpectation('custom_offline_first_serdes', customOfflineFirstSerdes.output);
      });

      test('EnumFactorySerialize', () async {
        await generateExpectation('enum_factory_serialize', enumFactorySerialize.output);
      });

      test('NoFinalNoConst', () async {
        await generateExpectation('no_final_no_const', noFinalNoConst.output);
      });

      test('OneToManyAssociation', () async {
        await generateAdapterExpectation('one_to_many_association', oneToManyAssociation.output);
      });

      test('OneToOneAssociation', () async {
        await generateExpectation('one_to_one_association', oneToOneAssociation.output);
      });

      test('OnlyStaticMembers', () async {
        await generateExpectation('only_static_members', onlyStaticMembers.output);
      });

      test('PrimitiveFields', () async {
        await generateExpectation('primitive_fields', primitiveFields.output);
      });

      test('UnrelatedAssociation', () async {
        await generateExpectation('unrelated_association', unrelatedAssociation.output);
      });

      test('Futures', () async {
        await generateAdapterExpectation('futures', futures.output);
      });

      test('OfflineFirstSerdesWithTypeArgument', () async {
        await generateAdapterExpectation(
          'offlne_first_serdes_with_type_argument',
          oflineFirstSerdesWithTypeArgument.output,
        );
      });
    });

    group('FieldSerializable', () {
      test('defaultValue', () async {
        await generateExpectation('default_value', defaultValue.output);
      });

      test('ignore', () async {
        await generateExpectation('ignore_field', ignoreField.output);
      });

      test('nullable', () async {
        await generateExpectation('nullable_field', nullableField.output);
      });
    });

    group('@OfflineFirst', () {
      test('offlineFirstWhere', () async {
        await generateAdapterExpectation('offline_first_where', offlineFirstWhere.output);
      });

      test('offlineFirstApplyToRemoteDeserialization', () async {
        await generateAdapterExpectation(
          'offline_first_apply_to_remote_deserialization',
          offlineFirstRemoteDeserialization.output,
        );
      });
    });
  });
}
