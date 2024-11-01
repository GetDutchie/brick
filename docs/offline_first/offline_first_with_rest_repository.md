# Offline First With Rest Repository

`OfflineFirstWithRestRepository` streamlines the REST integration with an `OfflineFirstRepository`. A serial queue is included to track REST requests in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity). See `OfflineFirstWithRest#reattemptForStatusCodes`.

The `OfflineFirstWithRest` domain uses all the same configurations and annotations as `OfflineFirst`.

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)

?> You can change default behavior on a per-request basis using `policy:` (e.g. `get<Person>(policy: OfflineFirstUpsertPolicy.localOnly)`). This is available for `delete`, `get`, `getBatched`, `subscribe`, and `upsert`.

## Generating Models from a REST Endpoint

A utility class is provided to make model generation from a JSON API a snap. Given an endpoint, the converter will infer the type of a field and scaffold a class. For example, the following would be saved to the `lib` directory of your project and run `$ dart lib/converter_script.dart`:

```dart
// lib/converter_script.dart
import 'package:brick_offline_first/rest_to_offline_first_converter.dart';

const BASE = "http://0.0.0.0:3000";
const endpoint = "$BASE/users";

final converter = RestToOfflineFirstConverter(endpoint: endpoint);

void main() {
  converter.saveToFile();
}

// => dart lib/converter_script.dart
```

After the model is generated, double check for `List<dynamic>` and `null` types. While the converter is smart, it's not smarter than you.

## OfflineQueueHttpClient

This content has been moved to [Offline Queue](offline_queue.md).
