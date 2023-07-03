import 'package:brick_graphql/brick_graphql.dart';

class DemoModelAssoc extends GraphqlModel {
  DemoModelAssoc({this.name});
  final String? name;
}

class DemoModelAssocWithSubfields extends DemoModelAssoc {
  DemoModelAssocWithSubfields({super.name});
}

class DemoModel extends GraphqlModel {
  final DemoModelAssoc? assoc;

  final String? complexFieldName;

  final String? lastName;

  List<DemoModelAssoc>? manyAssoc;

  @Graphql(name: 'full_name')
  final String? name;

  final bool? simpleBool;

  DemoModel({
    this.name,
    this.assoc,
    this.complexFieldName,
    this.lastName,
    this.manyAssoc,
    this.simpleBool,
  });
}
