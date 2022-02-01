class OfflineFirstException implements Exception {
  /// The producing error from either [RestProvider] or [SqliteProvider].
  final Exception originalError;

  OfflineFirstException(this.originalError);

  String get message => originalError.toString();

  @override
  String toString() => message;
}
