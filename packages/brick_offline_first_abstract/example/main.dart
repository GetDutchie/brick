import 'dart:convert';

import 'package:brick_offline_first_abstract/abstract.dart';

/// When we don't want to make a separate association but have complex data that can be stored in a single column
/// Serdes classes cannot be queried like model members.
class Horse extends OfflineFirstSerdes<Map<String, dynamic>, String> {
  final String? breed;

  Horse({
    this.breed,
  });

  factory Horse.fromRest(Map<String, dynamic> data) {
    return Horse(breed: data['breed']);
  }

  factory Horse.fromSqlite(String data) => Horse.fromRest(jsonDecode(data));

  @override
  Map<String, dynamic> toRest() {
    return {'breed': breed};
  }

  @override
  String toSqlite() => jsonEncode(toRest());
}
