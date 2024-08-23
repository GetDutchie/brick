import 'package:brick_core/core.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

QuerySupabaseTransformer<T> _buildTransformer<T extends SupabaseModel>([Query? query]) {
  return QuerySupabaseTransformer<T>(
    modelDictionary: supabaseModelDictionary,
    query: query,
  );
}

void main() {
  group('QuerySupabaseTransformer', () {
    group('#selectFields', () {
      test('no association', () {
        final transformer = _buildTransformer<DemoModel>();
        expect(transformer.selectFields, 'id,name');
      });

      test('association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        expect(transformer.selectFields, 'id,name,assoc:demos!assoc_id(id,name)');
      });

      test('association', () {
        final transformer = _buildTransformer<DemoNestedAssociationModel>();
        expect(
          transformer.selectFields,
          'id,name,nested:demo_associations!nested_id(id,name,assoc:demos!assoc_id(id,name))',
        );
      });
    });

    group('#select', skip: true, () {
      test('no query', skip: true, () {});
      group('with query', skip: true, () {
        group('eq', skip: true, () {
          test('by field', skip: true, () {});
          test('by association field', skip: true, () {});
        });
        test('neq', skip: true, () {});

        test('lt/gt/lte/gte', skip: true, () {});
        test('contains', skip: true, () {});
        test('does not contain', skip: true, () {});
      });
    });

    group('#applyProviderArgs', skip: true, () {});

    group('#destructureAssociationProperties', () {
      test('single association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        final result = transformer
            .destructureAssociationProperties(transformer.adapter.fieldsToSupabaseColumns.values);
        expect(result, containsAll(['id', 'name', 'assoc:demos!assoc_id(id,name)']));
      });

      group('iterable association', skip: true, () {});

      test('nested association', () {
        final transformer = _buildTransformer<DemoNestedAssociationModel>();
        final result = transformer
            .destructureAssociationProperties(transformer.adapter.fieldsToSupabaseColumns.values);
        expect(
          result,
          containsAll([
            'id',
            'name',
            'nested:demo_associations!nested_id(id,name,assoc:demos!assoc_id(id,name))',
          ]),
        );
      });
    });

    test('#expandCondition', () {}, skip: true);
  });

  group('#limit', skip: true, () {});

  group('#order', skip: true, () {});
}
