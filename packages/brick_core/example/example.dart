import 'dart:convert';
import 'dart:io';

import 'package:brick_core/core.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

abstract class FileModel extends Model {
  String get fileName;

  Future<dynamic> get contents async {
    final contents = await asFile.readAsString();
    if (contents.startsWith('{')) return jsonDecode(contents);
    return contents;
  }

  File get asFile => File(fileName);
}

class User extends FileModel {
  @override
  String get fileName => name;

  final String name;

  User({
    required this.name,
  });
}

class FileProvider implements Provider<FileModel> {
  @override
  final FileModelDictionary modelDictionary;
  FileProvider({required this.modelDictionary});

  @override
  Future<bool> delete<T extends FileModel>(
    instance, {
    Query? query,
    ModelRepository<FileModel>? repository,
  }) async {
    await instance.asFile.delete();
    return true;
  }

  @override
  bool exists<T extends FileModel>({Query? query, ModelRepository<FileModel>? repository}) => false;

  /// Query.where must always include `filePath`
  @override
  Future<List<T>> get<T extends FileModel>({
    Query? query,
    ModelRepository<FileModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[T]!;
    if (query?.where != null) {
      final filePath = Where.firstByField('filePath', query?.where)?.value;

      final contents = await File('${adapter.directory}/$filePath.json').readAsString();
      return [await adapter.fromFile(contents, provider: this, repository: repository) as T];
    }

    final files = Glob('${adapter.directory}/**.${adapter.fileExtension}');
    return Future.wait<T>(
      files.listSync().map<Future<T>>((file) async {
        final contents = await File(file.path).readAsString();
        return await adapter.fromFile(contents, provider: this, repository: repository) as T;
      }),
    );
  }

  @override
  Future<T> upsert<T extends FileModel>(
    T instance, {
    Query? query,
    ModelRepository<FileModel>? repository,
  }) async {
    final adapter = modelDictionary.adapterFor[T];
    final fileContents = await adapter?.toFile(instance, provider: this, repository: repository);
    await File(instance.fileName).writeAsString(fileContents ?? '');
    return instance;
  }
}

abstract class FileAdapter<TModel extends FileModel> extends Adapter<TModel> {
  /// Folder to store all of these
  String get directory;

  String get fileExtension => '.json';

  String filePath(String fileName) => '$directory/$fileName$fileExtension';

  Future<FileModel> fromFile(
    String data, {
    required FileProvider provider,
    ModelRepository<FileModel>? repository,
  });
  Future<String> toFile(
    TModel instance, {
    required FileProvider provider,
    ModelRepository<FileModel>? repository,
  });
}

/// This is generated. As this is an example, `FileProvider` does not
/// have a complimenting build system to generate this adapter. It was handwritten
/// for this example.
class UserAdapter extends FileAdapter<User> {
  @override
  final directory = 'users';

  UserAdapter();

  @override
  Future<User> fromFile(
    String input, {
    required FileProvider provider,
    ModelRepository<FileModel>? repository,
  }) async {
    final contents = jsonDecode(input);
    return User(name: contents['name']);
  }

  @override
  Future<String> toFile(
    User instance, {
    required FileProvider provider,
    ModelRepository<FileModel>? repository,
  }) async =>
      jsonEncode({'name': instance.name});
}

class FileModelDictionary extends ModelDictionary<FileModel, FileAdapter> {
  FileModelDictionary(super.adapterFor);
}

final Map<Type, FileAdapter> mappings = {
  User: UserAdapter(),
};
final fileModelDictionary = FileModelDictionary(mappings);

// finally, what the end application sees:
class FileRepository extends SingleProviderRepository<FileModel> {
  FileRepository() : super(FileProvider(modelDictionary: fileModelDictionary));
}

void main() async {
  final repository = FileRepository();

  await repository.upsert<User>(User(name: 'Thomas'));

  final users = await repository.get<User>(query: Query.where('fileName', 'Thomas'));
  await repository.delete<User>(users.first);
}
