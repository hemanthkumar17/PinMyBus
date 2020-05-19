import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinmybus/pages/login.dart';

void main() async {
  runApp(PinMyBusApp());
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class PinMyBusApp extends StatelessWidget {
  const PinMyBusApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pin My Bus",
      home: Login(),
      theme: ThemeData(primaryColor: Colors.black, accentColor: Colors.orange),
      routes: {
        '/login': (context) => Login(),
      },
    );
  }
}
