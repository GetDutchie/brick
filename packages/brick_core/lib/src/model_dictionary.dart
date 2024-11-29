import 'package:brick_core/src/adapter.dart';
import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/provider.dart';

/// A modelDictionary points a [Provider] to the [Model]'s [Adapter]. The [Provider] uses it to construct
/// app models from raw data.
///
/// It should only be instantiated once, even if multiple [Provider]s are used. The end instantiation
/// is left to the end user in case `const` (favored over `final`) can be used for
/// all [Adapter] mappings.
abstract class ModelDictionary<ImplementationModel extends Model,
    ImplementationAdapter extends Adapter<ImplementationModel>> {
  /// A generated map associating models to adapters
  final Map<Type, ImplementationAdapter> adapterFor;

  /// A modelDictionary points a [Provider] to the [Model]'s [Adapter]. The [Provider] uses it to construct
  /// app models from raw data.
  ///
  /// It should only be instantiated once, even if multiple [Provider]s are used. The end instantiation
  /// is left to the end user in case `const` (favored over `final`) can be used for
  /// all [Adapter] mappings.
  const ModelDictionary(this.adapterFor);
}
