import 'package:brick_build/generators.dart';

/// Output serializing code for all models with the @[_ClassAnnotation] annotation
abstract class OfflineFirstGenerator<_ClassAnnotation>
    extends AnnotationSuperGenerator<_ClassAnnotation> {
  /// The prefix to the adapter name; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  @override
  final String superAdapterName;

  /// The prefix to the repository name, specified when declaring the repository type in
  /// serializing functions; useful if extending `OfflineFirstRepository`.
  /// Defaults to `OfflineFirst`.
  final String repositoryName;

  const OfflineFirstGenerator({
    this.superAdapterName = 'OfflineFirst',
    this.repositoryName = 'OfflineFirst',
  });
}
