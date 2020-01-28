import 'package:brick_core/src/adapter.dart';
import 'package:brick_core/src/model.dart';

/// A modelDictionary points a [Provider] to the [Model]'s [Adapter]. The [Provider] uses it to construct
/// app models from raw data.
///
/// It should only be instantiated once, even if multiple [Provider]s are used. The end instantiation
/// is left to the end user in case `const` (favored over `final`) can be used for
/// all [Adapter] mappings.
abstract class ModelDictionary<_ImplementationModel extends Model,
    _ImplementationAdapter extends Adapter<_ImplementationModel>> {
  /// A generated map associating models to adapters
  final Map<Type, _ImplementationAdapter> adapterFor;

  const ModelDictionary(this.adapterFor);
}
