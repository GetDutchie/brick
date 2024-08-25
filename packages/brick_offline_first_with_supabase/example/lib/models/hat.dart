import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';

enum Style { party, dance }

class Hat extends OfflineFirstWithSupabaseModel {
  final String? name;

  final String? flavour;

  final Style style;

  Hat({
    this.name,
    this.flavour,
    required this.style,
  });
}
