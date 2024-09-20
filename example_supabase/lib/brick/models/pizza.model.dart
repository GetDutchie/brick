import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Pizza extends OfflineFirstWithSupabaseModel {
  /// Read more about `@Sqlite`: https://github.com/GetDutchie/brick/tree/main/packages/brick_sqlite#fields
  @Sqlite(unique: true)
  final int id;

  /// Read more about `@Supabase`: https://github.com/GetDutchie/brick/tree/main/packages/brick_supabase#fields
  @Supabase(enumAsString: true)
  final List<Topping> toppings;

  final bool frozen;

  Pizza({
    required this.id,
    required this.toppings,
    required this.frozen,
  });
}

enum Topping { olive, pepperoni }
