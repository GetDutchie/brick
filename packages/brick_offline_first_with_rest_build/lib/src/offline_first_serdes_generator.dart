import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';

OfflineFirstChecker checkerCallback(FieldElement field, {DartType type}) {
  final checker = OfflineFirstChecker(type ?? field.type);
  if (checker.isFuture) {
    return checkerCallback(field, type: checker.argType);
  }

  return checker;
}
