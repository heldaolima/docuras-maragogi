import 'package:docuras_maragogi/app/routes/routes.dart';
import 'package:docuras_maragogi/app/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();

  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Doçuras de Maragogi',
      routerConfig: router,
      theme: theme,
    );
  }
}
