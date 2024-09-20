import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Pizza extends OfflineFirstWithSupabaseModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final String id;

  final bool frozen;

  @Supabase(foreignKey: 'customer_id')
  final Customer customer;

  // If the association will be created by the app, specify
  // a field that maps directly to the foreign key column
  // so that Brick can notify Supabase of the association.
  @Sqlite(ignore: true)
  String get customerId => customer.id;

  Pizza({
    required this.id,
    required this.frozen,
  });
}

enum Topping { olive, pepperoni }
