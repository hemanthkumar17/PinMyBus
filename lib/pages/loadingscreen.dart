import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/delayed_animation.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/utils/reminder.dart';
import 'package:pinmybus/widgets/loadingpagewidget.dart';

class LoadingPage extends StatelessWidget {
  Future<void> _initData(BuildContext context) async {
    await GlobalFunctions.getStops();
    await GlobalFunctions.getInstitutes();
    await Scheduler.initNotifications();
    Navigator.pushReplacementNamed(context, '/home');
  }

  Widget build(BuildContext context) {
    _initData(context);
    return Scaffold(body: LoadingPageWidget());
  }
}
