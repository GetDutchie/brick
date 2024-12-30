import 'package:test/test.dart';

import '__helpers__.dart';
import 'offline_first_generator/test_constructor_arguments.dart' as constructor_arguments;
import 'offline_first_generator/test_custom_offline_first_serdes.dart'
    as custom_offline_first_serdes;
import 'offline_first_generator/test_default_value.dart' as default_value;
import 'offline_first_generator/test_enum_factory_serialize.dart' as enum_factory_serialize;
import 'offline_first_generator/test_futures.dart' as futures;
import 'offline_first_generator/test_ignore_field.dart' as ignore_field;
import 'offline_first_generator/test_no_final_no_const.dart' as no_final_no_const;
import 'offline_first_generator/test_nullable_field.dart' as nullable_field;
import 'offline_first_generator/test_offline_first_apply_to_remote_deserialization.dart'
    as offline_first_remote_deserialization;
import 'offline_first_generator/test_offline_first_serdes_with_type_argument.dart'
    as offline_first_serdes_with_type_argument;
import 'offline_first_generator/test_offline_first_where.dart' as offline_first_where;
import 'offline_first_generator/test_one_to_many_association.dart' as one_to_many_association;
import 'offline_first_generator/test_one_to_one_association.dart' as one_to_one_association;
import 'offline_first_generator/test_only_static_members.dart' as only_static_members;
import 'offline_first_generator/test_primitive_fields.dart' as primitive_fields;
import 'offline_first_generator/test_unique_offline_first_serdes.dart'
    as unique_offline_first_serdes;
import 'offline_first_generator/test_unrelated_association.dart' as unrelated_association;

void main() {
  group('OfflineFirstJsonGenerators', () {
    group('constructor arguments', () {
      test('repositoryName', () async {
        const generator = OfflineFirstWithTestGenerator(repositoryName: 'MyCustom');
        await generateAdapterExpectation(
          'constructor_arguments',
          constructor_arguments.repositoryNameAdapterExpectation,
          generator: generator,
        );
      });

      test('superAdapterName', () async {
        const generator = OfflineFirstWithTestGenerator(superAdapterName: 'SuperDuper');
        await generateAdapterExpectation(
          'constructor_arguments',
          constructor_arguments.superAdapterNameAdapterExpectation,
          generator: generator,
        );
      });
    });

    group('#generate', () {
      test('CustomOfflineFirstSerdes', () async {
        await generateExpectation(
          'custom_offline_first_serdes',
          custom_offline_first_serdes.output,
        );
      });

      test('UniqueOfflineFirstSerdes', () async {
        await generateAdapterExpectation(
          'unique_offline_first_serdes',
          unique_offline_first_serdes.output,
        );
      });

      test('EnumFactorySerialize', () async {
        await generateExpectation('enum_factory_serialize', enum_factory_serialize.output);
      });

      test('NoFinalNoConst', () async {
        await generateExpectation('no_final_no_const', no_final_no_const.output);
      });

      test('OneToManyAssociation', () async {
        await generateAdapterExpectation('one_to_many_association', one_to_many_association.output);
      });

      test('OneToOneAssociation', () async {
        await generateExpectation('one_to_one_association', one_to_one_association.output);
      });

      test('OnlyStaticMembers', () async {
        await generateExpectation('only_static_members', only_static_members.output);
      });

      test('PrimitiveFields', () async {
        await generateExpectation('primitive_fields', primitive_fields.output);
      });

      test('UnrelatedAssociation', () async {
        await generateExpectation('unrelated_association', unrelated_association.output);
      });

      test('Futures', () async {
        await generateAdapterExpectation('futures', futures.output);
      });

      test('OfflineFirstSerdesWithTypeArgument', () async {
        await generateAdapterExpectation(
          'offline_first_serdes_with_type_argument',
          offline_first_serdes_with_type_argument.output,
        );
      });
    });

    group('FieldSerializable', () {
      test('defaultValue', () async {
        await generateExpectation('default_value', default_value.output);
      });

      test('ignore', () async {
        await generateExpectation('ignore_field', ignore_field.output);
      });

      test('nullable', () async {
        await generateExpectation('nullable_field', nullable_field.output);
      });
    });

    group('@OfflineFirst', () {
      test('offlineFirstWhere', () async {
        await generateAdapterExpectation('offline_first_where', offline_first_where.output);
      });

      test('offlineFirstApplyToRemoteDeserialization', () async {
        await generateAdapterExpectation(
          'offline_first_apply_to_remote_deserialization',
          offline_first_remote_deserialization.output,
        );
      });
    });
  });
}
