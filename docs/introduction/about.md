## What is Brick?

Brick is an extensible query interface for Dart applications. It's an [all-in-one solution](https://www.youtube.com/watch?v=2noLcro9iIw) responsible for representing business data in the application, regardless of where your data comes from. Using Brick, developers can focus on implementing the application, without [concern for where the data lives](https://www.youtube.com/watch?v=jm5i7e_BQq0). Brick was inspired by the need for applications to work offline first, even if an API represents your source of truth.

Brick is inspired by [ActiveRecord](https://guides.rubyonrails.org/active_record_basics.html), [Ecto](https://hexdocs.pm/ecto/), and similar libraries.

Brick does a lot at once. [Learn](home.md#learn) includes videos, tutorials, and examples that break down Brick and is a great place to start.

## Why Brick?

* Your app requires [offline access](https://github.com/GetDutchie/brick/blob/main/packages/brick_offline_first) to data
* Handles and [hides](https://github.com/GetDutchie/brick/blob/main/packages/brick_build) all complex serialization/deserialization logic between any external source(s)
* Single [access point](data/repositories.md) and opinionated DSL establishes consistency when pushing and pulling data across your app
* Automatic, [intelligently-generated migrations](https://github.com/GetDutchie/brick/blob/main/packages/brick_sqlite)
* Legible [querying interface](data/query.md)

## When should I not use Brick?

* When data doesn't persist between sessions
* When large datasets are frequently used (images, document storage, etc.)
* When key-value data is stored (instead consider [localstorage](https://pub.dev/packages/localstorage))
