# Brick with Supabase Example

This minimal example demonstrates how to use Brick with [Supabase](https://supabase.com/). Follow the instructions below to get started.

Every Supabase project comes with a [ready-to-use REST API](https://supabase.com/docs/guides/api) using [PostgREST](https://postgrest.org/) which Brick can use to interact with the database.

## Setting up the Supabase project

1. **Create the table**: Run the following SQL command in your Supabase SQL editor to create the customers table:

```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

2. **Insert Dummy Data**: Insert some dummy data into the customers table by running the following SQL command

```sql
INSERT INTO customers (id, first_name, last_name, created_at) VALUES 
    ('a8098c1a-f86e-11da-bd1a-00112444be1e', 'Bruce', 'Fortner', NOW()),
    ('b8098c1a-f86e-11da-bd1a-00112444be1e', 'Jane', 'Smith', NOW()),
    ('c8098c1a-f86e-11da-bd1a-00112444be1e', 'Alice', 'Johnson', NOW());
```


3. **Enable Anonymous Sign-Ins**: Go to your Supabase dashboard, navigate to Settings > Authentication > User Signups, and enable anonymous sign-ins.

## Setting up the Flutter example project

4. **Update Environment Variables**: Open the `lib/env.dart` file and update it with your Supabase project URL and anonymous key. You can find these values in the Supabase dashboard under Settings > API.

## Running the Flutter app

5. **Run the Flutter Project**: This example supports iOS and Android. Make sure run `flutter create .` first.