import 'package:brick_offline_first/brick_offline_first.dart';
import 'package:brick_supabase/brick/models/customer.model.dart';
import 'package:brick_supabase/brick/repository.dart';
import 'package:brick_supabase/env.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: SUPABASE_PROJECT_URL,
    supabaseAnonKey: SUPABASE_ANON_KEY,
  );

  Repository.configure();
  await Repository().initialize();

  await Supabase.instance.client.auth.signInAnonymously();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Supabase Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Brick Supabase Example'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text('Add Customer'),
        onPressed: () async {
          final customer = Customer(
            id: Uuid().v4(),
            createdAt: DateTime.now(),
            firstName: 'John',
            lastName: 'Doe',
          );

          await Repository().upsert<Customer>(customer);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder(
          stream: Repository().subscribe<Customer>(
            policy: OfflineFirstGetPolicy.awaitRemoteWhenNoneExist,
          ),
          builder: (context, AsyncSnapshot<List<Customer>> snapshot) {
            print(snapshot);
            if (snapshot.hasData) {
              final customers = snapshot.data ?? [];

              return customers.isEmpty
                  ? Center(child: Text('No customers found.'))
                  : ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) => CustomerListTile(customers[index]),
                    );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(child: CircularProgressIndicator.adaptive());
            }
          },
        ),
      ),
    );
  }
}

class CustomerListTile extends StatelessWidget {
  final Customer customer;

  CustomerListTile(this.customer);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('${customer.firstName} ${customer.lastName}'),
        subtitle: Text('ID: ${customer.id}'),
        trailing: Text('Created at: ${customer.createdAt}'),
      ),
    );
  }
}
