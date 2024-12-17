import 'package:analyzer/dart/element/element.dart';
import 'package:brick_build/generators.dart';
import 'package:brick_offline_first_build/brick_offline_first_build.dart';
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_offline_first_with_supabase_build/src/offline_first_supabase_generators.dart';
import 'package:source_gen/source_gen.dart';

///
class OfflineFirstWithSupabaseGenerator
    extends OfflineFirstGenerator<ConnectOfflineFirstWithSupabase> {
  ///
  const OfflineFirstWithSupabaseGenerator({
    super.repositoryName,
    super.superAdapterName,
  });

  /// Given an [element] and an [annotation], scaffold generators
  @override
  List<SerdesGenerator> buildGenerators(Element element, ConstantReader annotation) {
    final supabase = OfflineFirstSupabaseModelSerdesGenerator(
      element,
      annotation,
      repositoryName: repositoryName,
    );
    final sqlite =
        OfflineFirstSqliteModelSerdesGenerator(element, annotation, repositoryName: repositoryName);
    return <SerdesGenerator>[...supabase.generators, ...sqlite.generators];
  }
}
