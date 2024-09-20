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

  PizzaTile(this.pizza);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text('id: ${pizza.id}'),
        Text('frozen: ${pizza.frozen}'),
        Text('name: ${pizza.customer.firstName} ${pizza.customer.lastName}'),
      ],
    );
  }
}
