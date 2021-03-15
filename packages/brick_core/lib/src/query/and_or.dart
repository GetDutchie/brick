import 'package:brick_core/src/query/where.dart';

/// Generate a required condition.
class And extends Where {
  const And(
    String evaluatedField,
  ) : super(evaluatedField, isRequired: true);
}

/// Generate an optional condition.
class Or extends Where {
  const Or(
    String evaluatedField,
  ) : super(evaluatedField, isRequired: false);
}
