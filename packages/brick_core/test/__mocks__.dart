import 'package:brick_core/core.dart';
export 'package:brick_core/core.dart';

class DemoModelDictionary extends ModelDictionary<DemoModel, DemoAdapter> {
  const DemoModelDictionary(Map<Type, DemoAdapter> mappings) : super(mappings);
}

class DemoProvider extends Provider<DemoModel> {
  DemoProvider(this.modelDictionary);

  final DemoModelDictionary modelDictionary;

  delete<_Model extends DemoModel>(instance, {query, repository}) {
    return true;
  }

  exists<_Model extends DemoModel>({query, repository}) {
    return true;
  }

  get<_Model extends DemoModel>({query, repository}) {
    final list = List<DemoModel>();
    list.add(DemoModel('Thomas'));
    return Future.value(list);
  }

  upsert<_Model extends DemoModel>(instance, {query, repository}) {
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
  DemoModel: const DemoAdapter(),
};
final modelDictionary = DemoModelDictionary(mappings);
