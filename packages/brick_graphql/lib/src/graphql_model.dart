import 'package:brick_core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
abstract class GraphQLModel extends JsonSerializable with EquatableMixin implements Model {}
