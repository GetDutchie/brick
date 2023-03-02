import 'package:flutter/material.dart';
import 'package:pizza_shoppe/brick/models/customer.model.dart';
import 'package:pizza_shoppe/brick/repository.dart';

void main() => runApp(MyApp());

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var migrated = false;
  @override
  void initState() {
    // be sure to run `node server.js` before using this example
    Repository.configure('http://localhost:4000');
    // Note that subsequent boots of the app will use cached data
    // To clear this, wipe data on android or tap-press on iOS and delete the app
    Repository().initialize().then((_) => setState(() => migrated = true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: migrated
          ? Container(
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
            )
          : Text("Migrating database..."),
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
        if (customer.pizzas != null)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                for (var pizza in customer.pizzas!)
                  Text('id: ${pizza.id}\nfrozen: ${pizza.frozen}'),
              ],
            ),
          )
      ],
    );
  }
}
