import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(),
)
class Customer extends OfflineFirstWithSupabaseModel {
  @Sqlite(unique: true)
  final int? id;

  final String? firstName;

  final String? lastName;

  final List<Pizza>? pizzas;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.pizzas,
  });
}
