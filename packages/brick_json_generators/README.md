![brick_json_generators workflow](https://github.com/GetDutchie/brick/actions/workflows/brick_json_generators.yaml/badge.svg)

# Brick JSON Generators

Code generator that provides (de)serializing functions for Brick adapters. This package **does not** produce code. It can be imported into other Brick build or Brick generator domains.

This package should not be imported into an end application as it does not generate code.

## Usage

Use `JsonDeserialize` or `JsonSerialize` mixins with your own generators:

```dart
import 'package:brick_json_generators/json_serdes_generator.dart';
import 'package:brick_json_generators/json_deserialize.dart';

class MyJsonProtocolDeserialize extends JsonSerdesGenerator<MyJsonProtocolModel, MyJsonProtocol> with JsonDeserialize {
}
```
