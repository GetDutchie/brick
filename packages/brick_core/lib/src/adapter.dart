import 'package:brick_core/src/model.dart';
import 'package:brick_core/src/provider.dart';

/// An adapter is a factory that produces an app [Model]. In an effort to normalize data input and
/// output between [Provider]s, subclasses must pass the data in `Map<String, dynamic>` format.
abstract class Adapter<_Model extends Model> {
  /// An adapter is a factory that produces an app [Model]. In an effort to normalize data input and
  /// output between [Provider]s, subclasses must pass the data in `Map<String, dynamic>` format.
  const Adapter();
}
