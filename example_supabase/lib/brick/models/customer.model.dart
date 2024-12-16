// ignore_for_file: public_member_api_docs

import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';

@ConnectOfflineFirstWithSupabase()
class Customer extends OfflineFirstWithSupabaseModel {
  @Sqlite(unique: true)
  final String id;

  final String? firstName;

  final String? lastName;

  Customer({
    required this.id,
    this.firstName,
    this.lastName,
  });
}
