import 'package:analyzer/dart/element/type.dart';
import 'package:brick_offline_first_with_rest_build/src/offline_first_checker.dart';

OfflineFirstChecker checkerCallback(DartType type) {
  final checker = OfflineFirstChecker(type);
  if (checker.isFuture) {
    return checkerCallback(checker.argType);
  }

  return checker;
}
