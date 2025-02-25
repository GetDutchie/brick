// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';
import 'package:pizza_shoppe/brick/repository.dart';

const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  await Repository.initializeSupabaseAndConfigure(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey,
  );
  await Repository().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 20),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          // necesary future
          // ignore: discarded_futures
          future: Repository().get<Pizza>(),
          builder: (context, AsyncSnapshot<List<Pizza>> pizzaList) {
            final pizzas = pizzaList.data;

            return ListView.builder(
              itemCount: pizzas?.length ?? 0,
              itemBuilder: (ctx, index) =>
                  pizzas?[index] == null ? Container() : PizzaTile(pizzas![index]),
            );
          },
        ),
      ),
    );
  }
}

class PizzaTile extends StatelessWidget {
  final Pizza pizza;

  const PizzaTile(this.pizza, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('id: ${pizza.id}'),
        Text('frozen: ${pizza.frozen}'),
        Text('name: ${pizza.customer.firstName} ${pizza.customer.lastName}'),
      ],
    );
  }
}
