import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinmybus/pages/buslist_route.dart';
import 'package:pinmybus/pages/buslist_stop.dart';
import 'package:pinmybus/pages/home.dart';
import 'package:pinmybus/pages/instistuitional.dart';
import 'package:pinmybus/pages/login.dart';
import 'package:pinmybus/pages/map.dart';
import 'package:pinmybus/pages/routeinfo.dart';
import 'package:pinmybus/pages/suggeststop.dart';
import 'package:pinmybus/utils/reminder.dart' ;

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
        '/home' : (context) => Home(ModalRoute.of(context).settings.arguments),
        '/map':(context) => MapPage(),
        '/buslist_stop':(context) => BuslistStop(ModalRoute.of(context).settings.arguments),
        '/buslist_route':(context) => BuslistRoute(ModalRoute.of(context).settings.arguments),
        '/routeinfo' :(context) => Routeinfo(),
        '/suggest' : (context) => MapPickerPage(),
        '/insti' : (context) => Instituitional(),
        '/remind' : (context) => Remind() ,
       },
    );
  }
}
