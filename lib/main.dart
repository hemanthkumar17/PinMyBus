import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinmybus/pages/buslist_route.dart';
import 'package:pinmybus/pages/buslist_stop.dart';
import 'package:pinmybus/pages/phoneauth.dart';
import 'package:pinmybus/pages/searchroute.dart';
import 'package:pinmybus/pages/institutional.dart';
import 'package:pinmybus/pages/login.dart';
import 'package:pinmybus/pages/homepage.dart';
import 'package:pinmybus/pages/routeinfo.dart';
import 'package:pinmybus/pages/suggeststop.dart';
import 'package:pinmybus/utils/reminder.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Colors.orange,
        accentColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange),
      ),
      routes: {
        '/login': (context) => Login(),
        '/home': (context) => HomePage(),
        '/searchRoute': (context) => SearchRoutePage(),
        '/buslist_stop': (context) =>
            BuslistStop(args: ModalRoute.of(context).settings.arguments),
        '/buslist_route': (context) =>
            BuslistRoute(args: ModalRoute.of(context).settings.arguments),
        '/routeinfo': (context) =>
            Routeinfo(route: ModalRoute.of(context).settings.arguments),
        '/suggest': (context) => MapPickerPage(),
        '/insti': (context) => InstitutePage(),
        '/reminders': (context) => Reminder(),
        '/phoneauth': (context) => PhoneAuthScreen(),
      },
    );
  }
}
