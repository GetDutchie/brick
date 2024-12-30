import 'package:brick_core/src/model_repository.dart';
import 'package:brick_core/src/provider.dart';

/// A model can be queried by the [ModelRepository], and if merited by the [ModelRepository] implementation,
/// the [Provider]. Subclasses may extend [Model] to include Repository-specific needs,
/// such as an HTTP endpoint or a table name.
abstract class Model {
  /// A model can be queried by the [ModelRepository], and if merited by the [ModelRepository] implementation,
  /// the [Provider]. Subclasses may extend [Model] to include Repository-specific needs,
  /// such as an HTTP endpoint or a table name.
  const Model();
}
