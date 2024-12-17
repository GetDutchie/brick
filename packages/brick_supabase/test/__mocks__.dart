import 'package:brick_core/src/model_repository.dart';
import 'package:brick_supabase/brick_supabase.dart';

part '__mocks_generated__.dart';

class Demo extends SupabaseModel {
  @Supabase(unique: true)
  final String id;

  final String name;

  final int age;

  Demo({
    required this.id,
    required this.name,
    required this.age,
  });
}

class DemoNestedAssociationModel extends SupabaseModel {
  @Supabase(unique: true)
  final String id;

  final String name;

  @Supabase(name: 'nested_column')
  final DemoAssociationModel nested;

  DemoNestedAssociationModel({
    required this.id,
    required this.name,
    required this.nested,
  });
}

class DemoAssociationModel extends SupabaseModel {
  @Supabase(name: 'assocs_id')
  final List<Demo>? assocs;

  @Supabase(name: 'assoc_id')
  final Demo assoc;

  @Supabase(unique: true)
  final String id;

  final String name;

  DemoAssociationModel({
    this.assocs,
    required this.assoc,
    required this.id,
    required this.name,
  });
}

class RecursiveParent extends SupabaseModel {
  final RecursiveChild child;

  final String parentId;

  RecursiveParent({
    required this.child,
    required this.parentId,
  });
}

class RecursiveChild extends SupabaseModel {
  final RecursiveParent parent;

  final String childId;

  final Demo otherAssoc;

  RecursiveChild({
    required this.parent,
    required this.childId,
    required this.otherAssoc,
  });
}

final Map<Type, SupabaseAdapter<SupabaseModel>> _supabaseMappings = {
  Demo: DemoAdapter(),
  DemoAssociationModel: DemoAssociationModelAdapter(),
  DemoNestedAssociationModel: DemoNestedAssociationModelAdapter(),
  RecursiveParent: RecursiveParentAdapter(),
  RecursiveChild: RecursiveChildAdapter(),
};
final supabaseModelDictionary = SupabaseModelDictionary(_supabaseMappings);
