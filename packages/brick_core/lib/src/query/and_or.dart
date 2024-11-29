import 'package:brick_core/src/query/where.dart';

/// Generate a required condition.
class And extends Where {
  /// Generate a required condition.
  const And(
    super.evaluatedField,
  ) : super(isRequired: true);
}

/// Generate an optional condition.
class Or extends Where {
  /// Generate an optional condition.
  const Or(
    super.evaluatedField,
  ) : super(isRequired: false);
}
