import 'model.dart';

/// An adapter is a factory that produces an app model. In an effort to normalize data input and
/// output between [Provider]s, subclasses must pass the data in `Map<String, dynamic>` format.
abstract class Adapter<_Model extends Model> {
  const Adapter();
}
