import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';

@ConnectOfflineFirstWithSupabase(
  supabaseConfig: SupabaseSerializable(tableName: 'finance_providers'),
)
class FinanceProvider extends OfflineFirstWithSupabaseModel {
  @Supabase(unique: true)
  @Sqlite(index: true, unique: true)
  final String id;
  final String name;
  final num interestRate;

  /// this is a string of supplier ids separated by comma.
  final String suppliersThatAcceptThisFinanceFacility;

  FinanceProvider({
    required this.id,
    required this.interestRate,
    required this.name,
    required this.suppliersThatAcceptThisFinanceFacility,
  });
}
