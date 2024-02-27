import 'package:flutter/material.dart';
import 'package:exscort/view/home.dart';
import 'package:exscort/view/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Set initial route
      routes: {
        '/splash': (context) => Splash(),
        '/home': (context) => Home(),
      },
    );
  }
}
