import 'package:brick_core/core.dart';
import 'package:brick_rest/brick_rest.dart';

class CustomerRequestTransformer extends RestRequestTransformer {
  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get delete => get;

  @override
  RestRequest get get {
    if (query?.where != null) {
      final byId = Where.firstByField('id', query?.where);
      // member endpoint
      if (byId?.value != null) {
        return RestRequest(url: '/customer/${byId!.value}');
      }
    }
    return RestRequest(url: '/customers');
  }

  // A production code base would not forward to another operation
  // but for testing this is convenient
  @override
  RestRequest get upsert => RestRequest(url: '/customers');

  const CustomerRequestTransformer(super.query, super.instance);
}
