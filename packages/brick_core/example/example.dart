import 'dart:convert';
import 'dart:io';

import 'package:glob/glob.dart';

import '../lib/core.dart';

abstract class FileModel extends Model {
  String get fileName;

  Future<dynamic> get contents async {
    final contents = await asFile.readAsString();
    if (contents.startsWith("{")) return jsonDecode(contents);
    return contents;
  }

  File get asFile => File(fileName);
}

class User extends FileModel {
  String get fileName => name;

  final String name;

  User({
    this.name,
  });
}

class FileProvider implements Provider<FileModel> {
  final FileModelDictionary modelDictionary;
  FileProvider({this.modelDictionary});

  @override
  delete<T extends FileModel>(instance, {query, repository}) async =>
      await instance.asFile.delete();

  /// Query.where must always include `filePath`
  @override
  Future<List<T>> get<T extends FileModel>({query, repository}) async {
    final adapter = modelDictionary.adapterFor[T];
    if (query.where != null) {
      final filePath = Where.firstByField('filePath', query.where)?.value;

      final contents = await File("${adapter.directory}/$filePath.json").readAsString();
      return [await adapter.fromFile(contents)];
    }

    final files = Glob("${adapter.directory}/**.${adapter.fileExtension}");
    return Future.wait<T>(files.listSync().map<Future<T>>((file) async {
      final contents = await File(file.path).readAsString();
      return await adapter.fromFile(contents);
    }));
  }

  @override
  Future<T> upsert<T extends FileModel>(instance, {query, repository}) async {
    final adapter = modelDictionary.adapterFor[T];
    final fileContents = await adapter.toFile(instance, provider: this, repository: repository);
    await File(instance.fileName).writeAsString(fileContents);
    return instance;
  }
}

abstract class FileAdapter<_Model extends FileModel> extends Adapter<_Model> {
  /// Folder to store all of these
  String get directory;

  String get fileExtension => ".json";

  String filePath(String fileName) => "$directory/$fileName$fileExtension";

  Future<FileModel> fromFile(
    String data, {
    FileProvider provider,
    ModelRepository<FileModel> repository,
  });
  Future<String> toFile(
    _Model instance, {
    FileProvider provider,
    ModelRepository<FileModel> repository,
  });
}

/// This is generated
class UserAdapter extends FileAdapter<User> {
  final directory = "users";

  UserAdapter();

  Future<User> fromFile(input, {provider, repository}) async {
    final contents = jsonDecode(input);
    return User(name: contents["name"]);
  }

  Future<String> toFile(instance, {provider, repository}) async =>
      jsonEncode({'name': instance.name});
}

class FileModelDictionary extends ModelDictionary<FileModel, FileAdapter> {
  FileModelDictionary(Map<Type, FileAdapter> dictionary) : super(dictionary);
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

  await repository.upsert<User>(User(name: "Thomas"));

  final users = await repository.get<User>(query: Query.where('fileName', 'Thomas'));
  await repository.delete<User>(users.first);
}
