import 'package:brick_rest/brick_rest.dart';

// NOTE: This is just a minimal example, you may need to adjust the transformer
//       to support querying/filtering. See the linked PostgREST docs below.

class CustomerRequestTransformer extends RestRequestTransformer {
  @override
  // see https://postgrest.org/en/v12/references/api/tables_views.html#read
  RestRequest get get => RestRequest(url: '/customers');

  @override
  // see: https://postgrest.org/en/v12/references/api/tables_views.html#upsert
  RestRequest get upsert => RestRequest(url: '/customers');

  @override
  // see https://postgrest.org/en/v12/references/api/tables_views.html#delete
  RestRequest get delete => throw UnimplementedError();

  const CustomerRequestTransformer(super.query, super.instance);
}
