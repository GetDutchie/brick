import 'package:brick_rest/brick_rest.dart';

/// [RestSerializable] has `requestTransformer`,
/// however, the function can't be re-interpreted by ConstantReader.
/// So the name is grabbed to be used in a later generator.
class RestSerializableExtended extends RestSerializable {
  final String? requestName;

  const RestSerializableExtended({
    FieldRename? fieldRename,
    bool? nullable,
    this.requestName,
  }) : super(fieldRename: fieldRename, nullable: nullable);
}
