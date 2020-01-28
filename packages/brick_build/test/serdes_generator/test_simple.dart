import 'package:brick_build/builders.dart';
import 'package:brick_core/core.dart';

// The builder requires a const constructor
// Defined in an absolute path. Unfortunately, an absoluate
// import is requried, so this can't be defined in the test folder
// This is a simple, light-weight class
@AnnotationSuperGenerator()
class Simple extends Model {
  final int someField;

  Simple(this.someField);
}
