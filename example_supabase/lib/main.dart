// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pizza_shoppe/brick/models/pizza.model.dart';
import 'package:pizza_shoppe/brick/repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
    return ProviderScope(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 20),
          ),
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}




final pizzaProvider = StreamProvider<List<Pizza>>(
      (ref) => Repository().subscribe<Pizza>(),
);

class MyHomePage extends ConsumerWidget {
  final String title;

  const MyHomePage({super.key, required this.title});



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pizzas = ref.watch(pizzaProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await Repository().reset();
              },
              child: const Text('Reset db'),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: pizzas.length,
              itemBuilder: (ctx, index) => PizzaTile(pizzas[index]),
            ),
          ],
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
