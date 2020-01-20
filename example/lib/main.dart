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
    Repository().initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder(
          future: Repository().get<Customer>(),
          builder: (context, AsyncSnapshot<List<Customer>> customerList) {
            final customers = customerList.data;

            return ListView.builder(
              itemCount: customers.length,
              itemBuilder: (ctx, index) {
                return Text("${customers[index].firstName}");
              },
            );
          },
        ),
      ),
    );
  }
}
