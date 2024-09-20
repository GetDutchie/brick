# Brick with Supabase Example

1. **Create the table**: Run the following SQL command in your Supabase SQL editor to create the customers and pizzas table:

```sql
CREATE TABLE customers (
  id UUID PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE pizzas (
  id UUID PRIMARY KEY,
  frozen boolean NOT NULL DEFAULT false,
  customer_id UUID NOT NULL
);

ALTER TABLE pizzas ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers (id);
```

2. **Insert Dummy Data**: Insert some dummy data:

```sql
INSERT INTO customers (id, first_name, last_name, created_at) VALUES
  ('a8098c1a-f86e-11da-bd1a-00112444be1e', 'Bruce', 'Fortner', NOW()),
  ('b8098c1a-f86e-11da-bd1a-00112444be1e', 'Jane', 'Smith', NOW()),
  ('c8098c1a-f86e-11da-bd1a-00112444be1e', 'Alice', 'Johnson', NOW());
INSERT INTO pizzas (id, frozen, customer_id) VALUES
  ('d8098c1a-f86e-11da-bd1a-00112444be1e', TRUE, 'a8098c1a-f86e-11da-bd1a-00112444be1e'),
  ('e8098c1a-f86e-11da-bd1a-00112444be1e', FALSE, 'b8098c1a-f86e-11da-bd1a-00112444be1e'),
  ('f8098c1a-f86e-11da-bd1a-00112444be1e', TRUE, 'c8098c1a-f86e-11da-bd1a-00112444be1e');
```

3. **Enable Anonymous Sign-Ins**: Go to your Supabase dashboard, navigate to Settings > Authentication > User Signups, and enable anonymous sign-ins.

4. **Update Variables**: Update `main.dart` with your Supabase project URL and anonymous key. You can find these values in the Supabase dashboard under Settings > API.

5. **Run the Flutter Project**: This example supports iOS and Android. Make sure run `flutter create .` first.
