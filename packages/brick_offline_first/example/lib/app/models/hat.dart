import 'dart:convert';
import 'package:brick_offline_first_abstract/abstract.dart' show OfflineFirstSerdes;

enum Style { party, dance }

class Hat extends OfflineFirstSerdes<Map<String, dynamic>, String> {
  final String name;

  final String flavour;

  final Style style;

  Hat({
    this.name,
    this.flavour,
    this.style,
  });

  factory Hat.fromRest(Map<String, dynamic> data) {
    return Hat(
      name: data['name'],
      flavour: data['flavour'],
      style: Style.values[data['style']],
    );
  }

  factory Hat.fromSqlite(String data) => Hat.fromRest(jsonDecode(data));

  toRest() => {
        'name': name,
        'flavour': flavour,
        'style': Style.values.indexOf(style),
      };
  toSqlite() => jsonEncode(toRest());
}
