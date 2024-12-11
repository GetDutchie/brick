import 'package:brick_core/core.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

QuerySupabaseTransformer<T> _buildTransformer<T extends SupabaseModel>([
  Query? query,
]) {
  return QuerySupabaseTransformer<T>(
    modelDictionary: supabaseModelDictionary,
    query: query,
  );
}

final _supabaseClient = SupabaseClient(
  'http://localhost:3000',
  'supabaseKey',
);

extension _PostgrestBuilderExtension on PostgrestBuilder {
  /// Get the URI from the builder.
  Uri get uri {
    var uriString = overrideSearchParams('', '').toString();

    // Remove any trailing '&' or '?' (which is added by the overrideSearchParams)
    if (uriString.endsWith('&') || uriString.endsWith('?')) {
      uriString = uriString.substring(0, uriString.length - 1);
    }

    return Uri.parse(uriString);
  }

  /// Get the decoded query from the URI of the builder.
  String get query {
    return Uri.decodeQueryComponent(uri.query);
  }
}

void main() {
  group('QuerySupabaseTransformer', () {
    group('#selectFields', () {
      test('no association', () {
        final transformer = _buildTransformer<Demo>();
        expect(transformer.selectFields, 'id,name,custom_age');
      });

      test('association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        expect(
          transformer.selectFields,
          'id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age)',
        );
      });

      test('association', () {
        final transformer = _buildTransformer<DemoNestedAssociationModel>();
        expect(
          transformer.selectFields,
          'id,nested_column:demo_associations(id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age))',
        );
      });

      test('recursive associations', () {
        final transformer = _buildTransformer<RecursiveParent>();
        expect(
          transformer.selectFields,
          'child:recursive_children(parent:recursive_parents(parent_id),child_id,other_assoc:demos(id,name,custom_age)),parent_id',
        );
      });
    });

    group('#select', () {
      test('no query', () {
        final select =
            _buildTransformer<Demo>().select(_supabaseClient.from(DemoAdapter().supabaseTableName));

        expect(select.query, 'select=id,name,custom_age');
      });

      group('with query', () {
        group('eq', () {
          test('by field', () {
            final query = Query.where('name', 'Jens');
            final select = _buildTransformer<Demo>(query)
                .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

            expect(select.query, 'select=id,name,custom_age&name=eq.Jens');
          });

          test('by association field', () {
            final query = Query.where('assoc', Where.exact('name', 'Thomas'));
            final select = _buildTransformer<DemoAssociationModel>(query)
                .select(_supabaseClient.from(DemoAssociationModelAdapter().supabaseTableName));

            expect(
              select.query,
              'select=id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age)&demos.name=eq.Thomas&assoc_id=not.is.null',
            );
          });
        });

        test('neq', () {
          final query = Query(
            where: [Where('name', value: 'Jens', compare: Compare.notEqual)],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=neq.Jens');
        });

        test('lt/gt/lte/gte', () {
          final query = Query(
            where: [
              Where('age', value: '30', compare: Compare.lessThan),
              Where('age', value: '18', compare: Compare.greaterThan),
              Where('age', value: '25', compare: Compare.lessThanOrEqualTo),
              Where('age', value: '21', compare: Compare.greaterThanOrEqualTo),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(
            select.query,
            'select=id,name,custom_age&age=lt.30&age=gt.18&age=lte.25&age=gte.21',
          );
        });

        test('contains', () {
          final query = Query(
            where: [Where('name', value: 'search', compare: Compare.contains)],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=like.search');
        });

        test('does not contain', () {
          final query = Query(
            where: [
              Where('name', value: 'search', compare: Compare.doesNotContain),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=not.like.search');
        });
      });
    });

    group('#applyProviderArgs', () {
      test('orderBy', () {
        final query = Query(providerArgs: {'orderBy': 'name asc'});
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(
          transformBuilder.query,
          'select=id,name,custom_age&order=name.asc.nullslast',
        );
      });

      test('orderBy with descending order', () {
        final query = Query(providerArgs: {'orderBy': 'name desc'});
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(
          transformBuilder.query,
          'select=id,name,custom_age&order=name.desc.nullslast',
        );
      });

      test('orderBy with referenced table', () {
        final query = Query(
          providerArgs: {'orderBy': 'name desc', 'orderByReferencedTable': 'foreign_tables'},
        );
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(
          transformBuilder.query,
          'select=id,name,custom_age&foreign_tables.order=name.desc.nullslast',
        );
      });

      test('limit', () {
        final query = Query(providerArgs: {'limit': 10});
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(transformBuilder.query, 'select=id,name,custom_age&limit=10');
      });

      test('limit with referenced table', () {
        final query = Query(providerArgs: {'limit': 10, 'limitReferencedTable': 'foreign_tables'});
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(transformBuilder.query, 'select=id,name,custom_age&foreign_tables.limit=10');
      });

      test('combined orderBy and limit', () {
        final query = Query(providerArgs: {'orderBy': 'name desc', 'limit': 20});
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyProviderArgs(filterBuilder);

        expect(
          transformBuilder.query,
          'select=id,name,custom_age&order=name.desc.nullslast&limit=20',
        );
      });
    });

    group('#destructureAssociationProperties', () {
      test('single association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        final result = transformer.destructureAssociationProperties(
          transformer.adapter.fieldsToSupabaseColumns,
        );
        expect(
          result,
          containsAll(['id', 'name', 'assoc_id:demos!assoc_id(id,name,custom_age)']),
        );
      });

      test('iterable association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        final result = transformer.destructureAssociationProperties(
          transformer.adapter.fieldsToSupabaseColumns,
        );
        expect(
          result,
          containsAll(['id', 'name', 'assoc_id:demos!assoc_id(id,name,custom_age)']),
        );
      });

      test('nested association', () {
        final transformer = _buildTransformer<DemoNestedAssociationModel>();
        final result = transformer.destructureAssociationProperties(
          transformer.adapter.fieldsToSupabaseColumns,
        );
        expect(
          result,
          containsAll([
            'id',
            'nested_column:demo_associations(id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age))',
          ]),
        );
      });
    });

    group('#expandCondition', () {
      test('missing field', () {
        final transformer = _buildTransformer<DemoAssociationModel>();

        expect(transformer.expandCondition(Where.exact('made_up_field', 1)), isEmpty);
      });

      test('matching a value to an association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();

        expect(
          () => transformer.expandCondition(Where.exact('assoc', 1)),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
      });

      test('respects OR statements', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        final result = transformer.expandCondition(
          WherePhrase([
            Where.exact('id', 1),
            const Or('name').isExactly('Guy'),
          ]),
        );
        expect(
          result,
          containsAll([
            {'or': '(id.eq.1, name.eq.Guy)'},
          ]),
        );
      });
    });
  });
}
