import 'package:brick_core/src/provider.dart';

/// Specify query arguments that are exclusive to a specific [Provider].
/// For example, configuring a REST's POST method.
///
/// Implementations must specify the generic type argument as [Provider]
/// will read `Query` for this type. Implementations should also specify
/// equality operators.
///
/// [Provider] implementations should expect only one [ProviderQuery] per [T].
abstract class ProviderQuery<T extends Provider> {
  /// `Query` will build a map keyed by this provider, or [T].
  Type get provider => T;

  /// Specify query arguments that are exclusive to a specific [Provider].
  /// For example, configuring a REST's POST method.
  ///
  /// Implementations must specify the generic type argument as [Provider]
  /// will read `Query` for this type.
  ///
  /// [Provider] implementations should expect only one [ProviderQuery] per [T].
  const ProviderQuery();

  /// Serialize to JSON
  Map<String, dynamic> toJson();
}
