import 'package:brick_core/core.dart';
import 'package:brick_rest/brick_rest.dart';

/// This class and code is always generated.
/// It is included here as an illustration.
/// Rest adapters are generated by domains that utilize the brick_rest_generators package,
/// such as brick_offline_first_with_rest_build
class UserAdapter extends RestAdapter<User> {
  @override
  Future<User> fromRest(data, {required provider, repository}) async {
    return User(
      name: data['name'],
    );
  }

  @override
  Future<Map<String, dynamic>> toRest(instance, {required provider, repository}) async {
    return {
      'name': instance.name,
    };
  }
}

/// This value is always generated.
/// It is included here as an illustration.
/// Import it from `lib/brick/brick.g.dart` in your application.
final dictionary = RestModelDictionary({
  User: UserAdapter(),
});

/// A model is unique to the end implementation (e.g. a Flutter app)
class User extends RestModel {
  final String name;

  User({
    required this.name,
  });
}

class MyRepository extends SingleProviderRepository<RestModel> {
  MyRepository(String baseApiUrl)
      : super(
          RestProvider(
            baseApiUrl,
            modelDictionary: dictionary,
          ),
        );
}

void main() async {
  final repository = MyRepository('http://localhost:8080');

  final users = await repository.get<User>();
  print(users);
}
