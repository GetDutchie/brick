import 'package:brick_supabase/brick_supabase.dart';

class DemoModel extends SupabaseModel {
  @Supabase(unique: true)
  final String id;

  final String name;

  final int age;

  DemoModel({
    required this.id,
    required this.name,
    required this.age,
  });
}

DemoModel _$DemoModelFromSupabase(Map<String, dynamic> json) {
  return DemoModel(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
  );
}

Future<Map<String, dynamic>> _$DemoModelToSupabase(DemoModel instance) async {
  return <String, dynamic>{
    'id': instance.id,
    'name': instance.name,
    'age': instance.age,
  };
}

class DemoModelAdapter extends SupabaseAdapter<DemoModel> {
  @override
  Future<DemoModel> fromSupabase(data, {required provider, repository}) async =>
      _$DemoModelFromSupabase(data);

  @override
  Future<Map<String, dynamic>> toSupabase(instance, {required provider, repository}) async =>
      await _$DemoModelToSupabase(instance);

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

class DemoNestedAssociationModel extends SupabaseModel {
  @Supabase(unique: true)
  final String id;

  final String name;

  @Supabase(name: 'nested_id')
  final DemoAssociationModel nested;

  DemoNestedAssociationModel({
    required this.id,
    required this.name,
    required this.nested,
  });
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
    ),
    'nested': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'nested_id',
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

class DemoAssociationModel extends SupabaseModel {
  @Supabase(name: 'assocs_id')
  final List<DemoModel>? assocs;

  @Supabase(name: 'assoc_id')
  final DemoModel assoc;

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

DemoAssociationModel _$DemoAssociationModelFromSupabase(Map<String, dynamic> json) {
  return DemoAssociationModel(
    id: json['id'] as String,
    name: json['name'] as String,
    assoc: _$DemoModelFromSupabase(json['assoc'] as Map<String, dynamic>),
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
                (s) => DemoModelAdapter().toSupabase(s, provider: provider, repository: repository),
              )
              .toList() ??
          [],
    ),
    'assoc': await _$DemoModelToSupabase(instance.assoc),
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
      columnName: 'assoc_id',
      associationType: DemoModel,
    ),
    'assocs': const RuntimeSupabaseColumnDefinition(
      association: true,
      columnName: 'assocs_id',
      associationType: DemoModel,
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

final Map<Type, SupabaseAdapter<SupabaseModel>> _supabaseMappings = {
  DemoModel: DemoModelAdapter(),
  DemoAssociationModel: DemoAssociationModelAdapter(),
  DemoNestedAssociationModel: DemoNestedAssociationModelAdapter(),
};
final supabaseModelDictionary = SupabaseModelDictionary(_supabaseMappings);
