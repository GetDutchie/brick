import 'package:brick_sqlite/brick_sqlite.dart';

/// An exception thrown by the remote provider or the [SqliteProvider].
/// An implementation may choose to ignore this error if the remote exception
/// is not important to the requested behavior.
class OfflineFirstException implements Exception {
  /// The producing error from the remote provider or [SqliteProvider].
  final Exception originalError;

  /// An exception thrown by the remote provider or the [SqliteProvider].
  /// An implementation may choose to ignore this error if the remote exception
  /// is not important to the requested behavior.
  OfflineFirstException(this.originalError);

  ///
  String get message => originalError.toString();

  @override
  String toString() => message;
}
