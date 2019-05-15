import 'package:flutter/material.dart';

import 'package:treasure_nfc/src/treasure_screen.dart';

import 'bloc_provider.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
            body1: TextStyle(fontSize: 18.0),
            headline: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
            title: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
              color: Colors.amber,
            )
        ),
        primarySwatch: Colors.amber,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(child: TreasureScreen());
  }
}
