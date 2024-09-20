import 'package:flutter/material.dart';
import 'package:pizza_shoppe/brick/models/customer.model.dart';
import 'package:pizza_shoppe/brick/repository.dart';

const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  await Repository.initializeSupabaseAndConfigure(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await Repository().initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 20.0),
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: Repository().get<Customer>(),
          builder: (context, AsyncSnapshot<List<Customer>> customerList) {
            final customers = customerList.data;

            return ListView.builder(
              itemCount: customers?.length ?? 0,
              itemBuilder: (ctx, index) =>
                  customers?[index] == null ? Container() : CustomerTile(customers![index]),
            );
          },
        ),
      ),
    );
  }
}

class CustomerTile extends StatelessWidget {
  final Customer customer;

  CustomerTile(this.customer);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('id: ${customer.id}'),
        Text('name: ${customer.firstName} ${customer.lastName}'),
        Text('pizzas:'),
        if (customer.pizzas.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                for (var pizza in customer.pizzas) Text('id: ${pizza.id}\nfrozen: ${pizza.frozen}'),
              ],
            ),
          ),
      ],
    );
  }
}
