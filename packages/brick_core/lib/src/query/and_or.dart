import 'package:brick_core/src/query/where.dart';

/// Generate a required condition.
class And extends Where {
  const And(
    super.evaluatedField,
  ) : super(isRequired: true);
}

/// Generate an optional condition.
class Or extends Where {
  const Or(
    super.evaluatedField,
  ) : super(isRequired: false);
}
