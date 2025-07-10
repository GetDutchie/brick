import 'package:brick_core/core.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:brick_supabase/src/query_supabase_transformer.dart';
import 'package:brick_supabase/src/supabase_model.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

import '__mocks__.dart';

QuerySupabaseTransformer<T> _buildTransformer<T extends SupabaseModel>([
  Query? query,
]) =>
    QuerySupabaseTransformer<T>(
      modelDictionary: supabaseModelDictionary,
      query: query,
    );

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
  String get query => Uri.decodeQueryComponent(uri.query);
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

      test(
        'inIterable',
        () {
          final query = Query(
            where: [
              const Where('name').isIn(['Jens', 'Thomas']),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=in.("Jens","Thomas")');
        },
      );

      group('with query', () {
        group('eq', () {
          test('by field', () {
            final query = Query.where('name', 'Jens');
            final select = _buildTransformer<Demo>(query)
                .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

            expect(select.query, 'select=id,name,custom_age&name=eq.Jens');
          });

          test('by association field', () {
            final query = Query.where('assoc', const Where.exact('name', 'Thomas'));
            final select = _buildTransformer<DemoAssociationModel>(query)
                .select(_supabaseClient.from(DemoAssociationModelAdapter().supabaseTableName));

            expect(
              select.query,
              'select=id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age)&demos.name=eq.Thomas&assoc_id=not.is.null',
            );
          });
        });

        test('neq', () {
          const query = Query(
            where: [Where('name', value: 'Jens', compare: Compare.notEqual)],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=neq.Jens');
        });

        test('lt/gt/lte/gte', () {
          const query = Query(
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
          const query = Query(
            where: [Where('name', value: 'search', compare: Compare.contains)],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=like.search');
        });

        test('does not contain', () {
          const query = Query(
            where: [
              Where('name', value: 'search', compare: Compare.doesNotContain),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=not.like.search');
        });

        test('with non-string values', () {
          const query = Query(
            where: [
              Where('age', value: 30, compare: Compare.lessThan),
              Where('id', value: 42, compare: Compare.exact),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&age=lt.30&id=eq.42');
        });

        test('inIterable with non-string values', () {
          final query = Query(
            where: [
              const Where('id').isIn([1, 2, 3]),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&id=in.(1,2,3)');
        });

        test('inIterable with string values that might need quoting', () {
          final query = Query(
            where: [
              const Where('name').isIn(['John Doe', 'Jane Smith']),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&name=in.("John Doe","Jane Smith")');
        });

        test('inIterable with empty list', () {
          final query = Query(
            where: [
              const Where('id').isIn([]),
            ],
          );
          final select = _buildTransformer<Demo>(query)
              .select(_supabaseClient.from(DemoAdapter().supabaseTableName));

          expect(select.query, 'select=id,name,custom_age&id=in.()');
        });
      });
    });

    group('#applyQuery', () {
      test('orderBy', () {
        const result = 'select=id,name,custom_age&order=name.asc.nullslast';

        const query = Query(orderBy: [OrderBy('name')]);
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          result,
        );
      });

      test('orderBy with descending order', () {
        const result = 'select=id,name,custom_age&order=age.desc.nullslast';

        const query = Query(orderBy: [OrderBy('age', ascending: false)]);
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          result,
        );
      });

      test('orderBy with referenced table', () {
        const result =
            'select=id,nested_column:demo_associations(id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age))&demo_associations.order=name.desc.nullslast';

        const query = Query(
          orderBy: [OrderBy.desc('nested', associationField: 'name')],
        );
        final queryTransformer = _buildTransformer<DemoNestedAssociationModel>(query);
        final filterBuilder = queryTransformer
            .select(_supabaseClient.from(DemoNestedAssociationModelAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          result,
        );
      });

      test('orderBy with referenced table, no association field', () {
        const query = Query(
          orderBy: [OrderBy.desc('nested')],
        );
        final queryTransformer = _buildTransformer<DemoNestedAssociationModel>(query);
        final filterBuilder = queryTransformer
            .select(_supabaseClient.from(DemoNestedAssociationModelAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          'select=id,nested_column:demo_associations(id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age))&demo_associations.order=nested_column.desc.nullslast',
        );
      });

      test('limit', () {
        const result = 'select=id,name,custom_age&limit=10';

        const query = Query(limit: 10);
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(transformBuilder.query, result);
      });

      test('limit with referenced table', () {
        const result =
            'select=id,nested_column:demo_associations(id,name,assoc_id:demos!assoc_id(id,name,custom_age),assocs:demos(id,name,custom_age))&demo_associations.limit=10';

        const query = Query(limitBy: [LimitBy(10, evaluatedField: 'nested')]);
        final queryTransformer = _buildTransformer<DemoNestedAssociationModel>(query);
        final filterBuilder = queryTransformer
            .select(_supabaseClient.from(DemoNestedAssociationModelAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          result,
        );
      });

      test('combined orderBy and limit', () {
        const result = 'select=id,name,custom_age&order=name.desc.nullslast&limit=20';

        const query = Query(limit: 20, orderBy: [OrderBy('name', ascending: false)]);
        final queryTransformer = _buildTransformer<Demo>(query);
        final filterBuilder =
            queryTransformer.select(_supabaseClient.from(DemoAdapter().supabaseTableName));
        final transformBuilder = queryTransformer.applyQuery(filterBuilder);

        expect(
          transformBuilder.query,
          result,
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

        expect(transformer.expandCondition(const Where.exact('made_up_field', 1)), isEmpty);
      });

      test('matching a value to an association', () {
        final transformer = _buildTransformer<DemoAssociationModel>();

        expect(
          () => transformer.expandCondition(const Where.exact('assoc', 1)),
          throwsA(const TypeMatcher<ArgumentError>()),
        );
      });

      test('respects OR statements', () {
        final transformer = _buildTransformer<DemoAssociationModel>();
        final result = transformer.expandCondition(
          WherePhrase([
            const Where.exact('id', 1),
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
