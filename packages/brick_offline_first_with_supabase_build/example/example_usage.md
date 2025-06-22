# Supabase SQL Generation Example

This example shows how the Supabase SQL generation feature works with Brick models.

## Model Definition

```dart
@ConnectOfflineFirstWithSupabase()
class Customer extends OfflineFirstWithSupabaseModel {
  @Sqlite(unique: true)
  final String id;

  final String? firstName;

  final String? lastName;

  Customer({
    required this.id,
    this.firstName,
    this.lastName,
  });
}
```

## Generated Migration File

When you run the build process, the generated migration file will include a Supabase SQL comment at the top:

```dart
// Equivalent Supabase SQL:
// -- Table for Customer
// CREATE TABLE customers (
//   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
//   first_name TEXT,
//   last_name TEXT
// );

// GENERATED CODE DO NOT EDIT
part of '../brick.g.dart';

class Migration20240101120000 extends Migration {
  const Migration20240101120000();

  @override
  final int version = 20240101120000;

  @override
  final List<MigrationCommand> up = [
    // ... migration commands
  ];

  @override
  final List<MigrationCommand> down = [
    // ... migration commands
  ];
}
```

## Usage

1. Copy the SQL from the comment section
2. Paste it into your Supabase SQL editor
3. Execute the SQL to create the equivalent table in Supabase

This ensures your Supabase database schema matches your Brick model definitions. 
