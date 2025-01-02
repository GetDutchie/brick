# Fields (Model Properties)

A field is a single, accessible property of a model. For example, `final String id`.

## Serialized Fields

All `final` fields of a model, unless specified, will be (de)serialized by the provider. Computed getters (`int get number => 5 + 10`) are not deserialized _from_ providers. However, they are serialized to, allowing generation of custom fields to send to an API or to query cached results in SQLite (to skip, declare `ignore: true` in the field's annotation). Setters are never serialized.

## Annotations

As providers are ultimately responsible for converting raw data into model data, a description of fields on models is overly generic. Field-level annotations always override class-level annotations/configuration. However, providers should adhere to some standards of annotations:

| Named Arg       | Description                                                                                                                                                                                                                              | Example                                                            |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| `ignore:`       | Do not deserialize (from) or serialize (to) this field to a provider                                                                                                                                                                     | `@Rest(ignore: true)`                                              |
| `name:`         | Stored key for this field according to the provider. In SQLite, for example, this would be the column name.                                                                                                                              | `@Sqlite(name: "address_2")`                                       |
| `defaultValue:` | Value to use in absence or `null` of the instance. It does not dictate what the Dart model will hold on empty instantiation. **Recommended to use Dart's default constructor assignment instead**.                                       | `@Rest(defaultValue: '[]')`                                        |
| `fromGenerator` | A stringified function with access to [placeholders](#placeholders); replaces adapter's generated deserialize code for the field. Do not include trailing semicolons or function body wrapping symbols (`{}` or `=>`) in the definition. | `@Rest(fromGenerator: "int.tryParse(%DATA_PROPERTY%.toString())")` |
| `toGenerator`   | A stringified function with access to [placeholders](#placeholders); replaces adapter's generated serialize code for the field. Do not include trailing semicolons or function body wrapping symbols (`{}` or `=>`) in the definition.   | `@Sqlite(toGenerator: "%INSTANCE_PROPERTY% > 1 ? 1 : 0")`          |

## Custom Generators

For non-standard input, consider writing a custom (de)serializer. Use caution as this will **completely replace** inferred type serializations. These are available at field-level as arguments.

Since Dart requires annotations to be constants, `Function`s must be stringified.

```dart
// given
final data = {
  'outfit': {
    'hat': 0,
    'shoe': 1,
    'shirt': 1,
  },
};

// a simple generator for the field `final Map<Clothes, Condition> clothesMap`
"""(data['outfit'] as Map<String, dynamic>).map((key, value) {
  return MapEntry(
    Clothes.keys.firstWhere((v) => v.toString().split('.').last == value),
    Condition.values[value]
  );
})""";
```

### Placeholders

To replace a few parts and DRY up code in custom, field-level generators, placeholders can be employed and replaced with values at build time.

All custom generators passed through field annotations (such as `@Rest(fromGenerator:)` or `@Sqlite(toGenerator:)`) have access to predefined placeholders and custom placeholders.

To declare your own variables, wrap the variable name like a tag using `@`: `@VARIABLE_NAME@value@/VARIABLE_NAME@`. Placeholders and their values **must** conform to the RegEx `[\w\d]+`.

```dart
// Important parts are swapped out for placeholders:
final customGenerator = """(%DATA_PROPERTY% as Map<String, dynamic>).map((key, value) {
  return MapEntry(
    %ENUM%.keys.firstWhere((v) => v.toString().split('.').last == value),
    Condition.values[value]
  );
})""";

// And variable values are assigned:
@Rest(
  fromGenerator: "$customGenerator@ENUM@Clothes@/ENUM@",
);
```

There are several globally-defined placeholders:

- `%ANNOTATED_NAME%` - key name.
  ```dart
  @Rest(name: 'my_field')
  final String myField
  // => 'my_field'
  ```
- `%DATA_PROPERTY%` - deserializing key name (`@Rest(name:)` or `@Sqlite(name:)` or the default) wrapped in the deserialized map. **Only use in `fromGenerator`**.
  ```dart
  @Rest(name: 'my_field')
  final String myField
  // => data['my_field']
  ```
- `%INSTANCE_PROPERTY%` - serializing property. **Only use in `toGenerator`**.
  ```dart
  @Rest(name: 'my_field')
  final String myField
  // => instance.myField
  ```

## FAQ

### Why are annotations AND `extends` required?

The annotation is required to build the generated files (adapters, migrations, etc.). The type extension (e.g. `OfflineFirstModel`) is used by the repository's type system.
