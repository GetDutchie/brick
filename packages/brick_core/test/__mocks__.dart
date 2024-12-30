// ignore_for_file: type_annotate_public_apis

import 'package:brick_core/core.dart';

export 'package:brick_core/core.dart';

class DemoModelDictionary extends ModelDictionary<DemoModel, DemoAdapter> {
  const DemoModelDictionary(super.adapterFor);
}

class DemoProvider extends Provider<DemoModel> {
  DemoProvider(this.modelDictionary);

  @override
  final DemoModelDictionary modelDictionary;

  @override
  bool delete<_Model extends DemoModel>(
    instance, {
    Query? query,
    ModelRepository<DemoModel>? repository,
  }) =>
      true;

  @override
  bool exists<_Model extends DemoModel>({Query? query, ModelRepository<DemoModel>? repository}) =>
      true;

  @override
  Future<List<DemoModel>> get<_Model extends DemoModel>({
    Query? query,
    ModelRepository<DemoModel>? repository,
  }) {
    final list = <DemoModel>[DemoModel('Thomas')];
    return Future.value(list);
  }

  @override
  bool upsert<_Model extends DemoModel>(
    instance, {
    Query? query,
    ModelRepository<DemoModel>? repository,
  }) =>
      true;
}

class DemoModel extends Model {
  DemoModel(this.name);

  final String name;
}

class DemoAdapter extends Adapter<DemoModel> {
  const DemoAdapter();
}

const Map<Type, DemoAdapter> mappings = {
  DemoModel: DemoAdapter(),
};
const modelDictionary = DemoModelDictionary(mappings);
