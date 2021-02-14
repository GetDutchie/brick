# Offline First With Rest Repository

`OfflineFirstWithRestRepository` streamlines the REST integration with an `OfflineFirstRepository`. A serial queue is included to track REST requests in a separate SQLite database, only removing requests when a response is returned from the host (i.e. the device has lost internet connectivity). See `OfflineFirstWithRest#reattemptForStatusCodes`.

The `OfflineFirstWithRest` domain uses all the same configurations and annotations as `OfflineFirst`.

![OfflineFirst#get](https://user-images.githubusercontent.com/865897/72176226-cdd8ca00-3392-11ea-867d-42f5f4620153.jpg)


## Generating Models from a REST Endpoint

A utility class is provided to make model generation from a JSON API a snap. Given an endpoint, the converter will infer the type of a field and scaffold a class. For example, the following would be saved to the `lib` directory of your project and run `$ dart lib/converter_script.dart`:

```dart
// lib/converter_script.dart
import 'package:brick_offline_first/rest_to_offline_first_converter.dart';

const BASE = "http://localhost:3000";
const endpoint = "$BASE/users";

final converter = RestToOfflineFirstConverter(
  endpoint: endpoint,
);

void main() {
  converter.saveToFile();
}

// => dart lib/converter_script.dart
```

After the model is generated, double check for `List<dynamic>` and `null` types. While the converter is smart, it's not smarter than you.

## OfflineQueueHttpClient

All requests to the REST provider in the repository first pass through a queue that tracks unsuccessful requests in a SQLite database separate from the one that maintains application models. Should the application ever lose connectivity, the queue will resend all `upsert`ed requests that occurred while the app was offline. All requests are forwarded to an inner client.

The queue is automatically added to all `OfflineFirstWithRestRepository`s. This means that a queue **should not be used as the `RestProvider`'s client**, however, the queue should use the RestProvider's client as its inner client:

```dart
final client = OfflineQueueHttpClient(
  restProvider.client, // or http.Client()
  "OfflineQueue",
);
```

![OfflineQueue logic flow](https://user-images.githubusercontent.com/865897/72175823-f44a3580-3391-11ea-8961-bbeccd74fe7b.jpg)

!> The queue ignores requests that are not `DELETE`, `PATCH`, `POST`, and `PUT`. `get` requests are not worth tracking as the caller may have been disposed by the time the app regains connectivity.
