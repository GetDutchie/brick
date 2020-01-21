import 'package:flutter/material.dart';
import 'package:pizza_shoppe/app/models/customer.dart';
import 'package:pizza_shoppe/app/repository.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          body1: TextStyle(fontSize: 20.0),
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    Repository.configure("http://localhost:8080");
    // Note that `.reset` is only called here for a clean debug environment
    // A production app should only call initialize, as using stored data is
    // essential with offline-first requirements
    Repository().reset().then((_) => Repository().initialize());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: Repository().get<Customer>(),
          builder: (context, AsyncSnapshot<List<Customer>> customerList) {
            final customers = customerList.data;

            return ListView.builder(
              itemCount: customers?.length ?? 0,
              itemBuilder: (ctx, index) => CustomerTile(customers[index]),
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
      children: <Widget>[
        Text("id: ${customer.id}"),
        Text("name: ${customer.firstName} ${customer.lastName}"),
        Text("pizzas:"),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            children: <Widget>[
              for (var pizza in customer.pizzas)
                Text("id: ${pizza.id}\nfrozen: ${pizza.frozen}\ncustomer: ${pizza.customer.id}"),
            ],
          ),
        )
      ],
    );
  }
}
