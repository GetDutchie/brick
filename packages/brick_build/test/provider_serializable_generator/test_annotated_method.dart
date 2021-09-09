// ignore_for_file: avoid_returning_null_for_void
import 'package:brick_build/builders.dart';

/// Output serializing code for all models with the @[AnnotationSuperGenerator] annotation.
/// [AnnotationSuperGenerator] **does not** produce code.
/// A `const` class is required from an non-relative import,
/// and [AnnotationSuperGenerator] was arbitrarily chosen for this test.
/// This will do nothing outside of this exact test suite.
@AnnotationSuperGenerator()
void annotatedMethod() => null;
