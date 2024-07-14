import 'package:brick_offline_first_with_rest/brick_offline_first_with_rest.dart';
import 'package:brick_rest/brick_rest.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick/models/customer.model.request.dart';

@ConnectOfflineFirstWithRest(
  restConfig:
      RestSerializable(requestTransformer: CustomerRequestTransformer.new),
)
class Customer extends OfflineFirstWithRestModel {
  @Sqlite(unique: true)
  final String id;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });
}
