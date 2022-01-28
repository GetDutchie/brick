# Brick Flutter Example

Before running this example in the simulator, create any missing Flutter files - `flutter create .` - and make sure the API is running: `node server.js`. Finally, generate Brick's code: `flutter pub run build_runner build`.

A progressive explanation of [a similar example can be found on Flutter by Example](http://www.flutterbyexample.com/#/posts/2_adding_a_repository).

## FAQ

### Why are generated files not ignored in this project?

While a [normal installation should ignore](https://github.com/GetDutchie/brick#recommended-but-optional) `*.g.dart` files, this project has them committed. This is for illustrative purposes to accessibly showcase Brick's output.
