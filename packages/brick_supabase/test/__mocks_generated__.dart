part of '__mocks__.dart';

Demo _$DemoFromSupabase(Map<String, dynamic> json) {
  return Demo(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
  );
}

Future<Map<String, dynamic>> _$DemoToSupabase(Demo instance) async {
  return <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'age': instance.age,
  };
}

class DemoAdapter extends SupabaseAdapter<Demo> {
  @override
  Future<Demo> fromSupabase(data, {required provider, repository}) async =>
      _$DemoFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$DemoToSupabase(instance);

  @override
  final defaultToNull = false;

  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'age': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'age',
      query: 'custom_age',
    ),
  };

  @override
  final ignoreDuplicates = true;

  @override
  final onConflict = null;

  @override
  final supabaseTableName = 'demos';

  @override
  final uniqueFields = {'id'};
}

DemoNestedAssociationModel _$DemoNestedAssociationModelFromSupabase(Map<String, dynamic> json) {
  return DemoNestedAssociationModel(
    id: json['id'] as String,
    name: json['name'] as String,
    nested: _$DemoAssociationModelFromSupabase(json['nested'] as Map<String, dynamic>),
  );
}

Future<Map<String, dynamic>> _$DemoNestedAssociationModelToSupabase(
  DemoNestedAssociationModel instance,
) async {
  return <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'nested': await _$DemoAssociationModelToSupabase(instance.nested),
  };
}

class DemoNestedAssociationModelAdapter extends SupabaseAdapter<DemoNestedAssociationModel> {
  @override
  Future<DemoNestedAssociationModel> fromSupabase(data, {required provider, repository}) async =>
      _$DemoNestedAssociationModelFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$DemoNestedAssociationModelToSupabase(instance);

  @override
  final defaultToNull = false;

  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
      // Test blank query to ensure it isn't added to request
      query: '',
    ),
    'nested': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'nested_column',
      associationType: DemoAssociationModel,
    ),
  };

  @override
  final ignoreDuplicates = true;

  @override
  final onConflict = null;

  @override
  final supabaseTableName = 'demo_nested_associations';

  @override
  final uniqueFields = {'id'};
}

DemoAssociationModel _$DemoAssociationModelFromSupabase(Map<String, dynamic> json) {
  return DemoAssociationModel(
    id: json['id'] as String,
    name: json['name'] as String,
    assoc: _$DemoFromSupabase(json['assoc'] as Map<String, dynamic>),
  );
}

Future<Map<String, dynamic>> _$DemoAssociationModelToSupabase(
  DemoAssociationModel instance, {
  provider,
  repository,
}) async {
  return <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'assocs': await Future.wait<Map<String, dynamic>>(
      instance.assocs
              ?.map(
                (s) => DemoAdapter().toSupabase(s, provider: provider, repository: repository),
              )
              .toList() ??
          [],
    ),
    'assoc': await _$DemoToSupabase(instance.assoc),
  };
}

class DemoAssociationModelAdapter extends SupabaseAdapter<DemoAssociationModel> {
  @override
  Future<DemoAssociationModel> fromSupabase(data, {required provider, repository}) async =>
      _$DemoAssociationModelFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$DemoAssociationModelToSupabase(instance);

  @override
  final defaultToNull = false;

  @override
  final fieldsToSupabaseColumns = {
    'id': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'id',
    ),
    'name': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'name',
    ),
    'assoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      associationIsNullable: false,
      columnName: 'assoc_id',
      foreignKey: 'assoc_id',
      associationType: Demo,
    ),
    'assocs': const RuntimeSupabaseColumnDefinition(
      association: true,
      associationIsNullable: true,
      columnName: 'assocs',
      associationType: Demo,
    ),
  };

  @override
  final ignoreDuplicates = true;

  @override
  final onConflict = null;

  @override
  final supabaseTableName = 'demo_associations';

  @override
  final uniqueFields = {'id'};
}

RecursiveParent _$RecursiveParentFromSupabase(Map<String, dynamic> json) {
  return RecursiveParent(
    child: _$RecursiveChildFromSupabase(json['child'] as Map<String, dynamic>),
    parentId: json['parent_id'] as String,
  );
}

Future<Map<String, dynamic>> _$RecursiveParentToSupabase(RecursiveParent instance) async {
  return <String, dynamic>{
    'child': await _$RecursiveChildToSupabase(instance.child),
  };
}

class RecursiveParentAdapter extends SupabaseAdapter<RecursiveParent> {
  @override
  Future<RecursiveParent> fromSupabase(data, {required provider, repository}) async =>
      _$RecursiveParentFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$RecursiveParentToSupabase(instance);

  @override
  final defaultToNull = false;

  @override
  final fieldsToSupabaseColumns = {
    'child': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'child',
      associationType: RecursiveChild,
    ),
    'parentId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'parent_id',
    ),
  };

  @override
  final ignoreDuplicates = true;

  @override
  final onConflict = null;

  @override
  final supabaseTableName = 'recursive_parents';

  @override
  final uniqueFields = {'parentId'};
}

RecursiveChild _$RecursiveChildFromSupabase(Map<String, dynamic> json) {
  return RecursiveChild(
    parent: _$RecursiveParentFromSupabase(json['parent'] as Map<String, dynamic>),
    childId: json['child_id'] as String,
    otherAssoc: _$DemoFromSupabase(json['other_assoc'] as Map<String, dynamic>),
  );
}

Future<Map<String, dynamic>> _$RecursiveChildToSupabase(RecursiveChild instance) async {
  return <String, dynamic>{
    'parent': await _$RecursiveParentToSupabase(instance.parent),
    'child_id': instance.childId,
    'other_assoc': await _$DemoToSupabase(instance.otherAssoc),
  };
}

class RecursiveChildAdapter extends SupabaseAdapter<RecursiveChild> {
  @override
  Future<RecursiveChild> fromSupabase(data, {required provider, repository}) async =>
      _$RecursiveChildFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$RecursiveChildToSupabase(instance);

  @override
  final defaultToNull = false;

  @override
  final fieldsToSupabaseColumns = {
    'parent': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'parent',
      associationType: RecursiveParent,
    ),
    'childId': const RuntimeSupabaseColumnDefinition(
      association: false,
      columnName: 'child_id',
    ),
    'otherAssoc': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'other_assoc',
      associationType: Demo,
    ),
  };

  @override
  final ignoreDuplicates = true;

  @override
  final onConflict = null;

  @override
  final supabaseTableName = 'recursive_children';

  @override
  final uniqueFields = {'childId'};
}