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
  bool delete<_Model extends DemoModel>(instance, {query, repository}) {
    return true;
  }

  @override
  bool exists<_Model extends DemoModel>({query, repository}) {
    return true;
  }

  @override
  Future<List<DemoModel>> get<_Model extends DemoModel>({query, repository}) {
    final list = <DemoModel>[];
    list.add(DemoModel('Thomas'));
    return Future.value(list);
  }

  @override
  bool upsert<_Model extends DemoModel>(instance, {query, repository}) {
    return true;
  }
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
final modelDictionary = DemoModelDictionary(mappings);
