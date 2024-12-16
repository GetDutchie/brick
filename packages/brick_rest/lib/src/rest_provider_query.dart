import 'package:brick_core/query.dart';
import 'package:brick_rest/src/rest_provider.dart';
import 'package:brick_rest/src/rest_request.dart';

/// A REST-specific query definitiion for use in [Query].
class RestProviderQuery extends ProviderQuery<RestProvider> {
  /// The [RestRequest] to use for the [Query].
  final RestRequest? request;

  /// A REST-specific query definitiion for use in [Query].
  const RestProviderQuery({
    this.request,
  });

  /// Creates a copy of this [RestProviderQuery] with the given fields replaced.
  RestProviderQuery copyWith({
    RestRequest? request,
  }) =>
      RestProviderQuery(
        request: request ?? this.request,
      );

  @override
  Map<String, dynamic> toJson() => {
        if (request != null) 'request': request?.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestProviderQuery && runtimeType == other.runtimeType && request == other.request;

  @override
  int get hashCode => request.hashCode;
}
