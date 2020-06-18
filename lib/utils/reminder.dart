import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:rxdart/subjects.dart';

import 'package:pinmybus/models/routes.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

DateTime scheduleDate = DateTime.now();

Map<String, Day> days = {
  '0': Day.Sunday,
  '1': Day.Monday,
  '2': Day.Tuesday,
  '3': Day.Wednesday,
  '4': Day.Thursday,
  '5': Day.Friday,
  '6': Day.Saturday,
};

BusRoute mockRoute;

BusRoute initMockRoute() {
  BusRoute temp = BusRoute(
    "Route_1",
    RecMode.ONE_OFF,
    ['0', '1', '2'],
  );
  var tempStops = <Stop>[];
  var min = 0;
  var hour = 0;
  for (int i = 0; i < 5; i += 1) {
    Stop tempStop = Stop("Stop_$i", "$i", LatLng(0, 0));
    hour = ((i * 1) / 60).floor();
    min = (i * 1) % 60;
    tempStop.offset = TimeOfDay(
      hour: hour,
      minute: min,
    );
    tempStops.add(tempStop);
  }
  temp.startTime = TimeOfDay(
    hour: 2,
    minute: 14,
  );
  temp.routeStops = tempStops;
  return temp;
}

Future<bool> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  mockRoute = initMockRoute();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ));
      });
  var initializationSettings = InitializationSettings(
    initializationSettingsAndroid,
    initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload);
    },
  );
  _requestIOSPermissions() ;
  print("InitDone");
  return true;
}

class PaddedRaisedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const PaddedRaisedButton({
    @required this.buttonText,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: RaisedButton(child: Text(buttonText), onPressed: onPressed),
    );
  }
}

void _requestIOSPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

class Scheduler {
  static Future<void> initNotifications() async {
    await init();
  }

  static double toDouble(DateTime date) {
    double ans = 0;
    ans += date.hour * 3600 + date.minute * 60 + date.second;
    return ans;
  }

  static bool check(DateTime date) {
    var now = DateTime.now().subtract(Duration(minutes: 5));
    if (toDouble(date) > toDouble(now)) return true;
    return false;
  }

  static Future<void> _addRouteNotification(BusRoute route,
      {DateTime date}) async {
    if (route.recMode == RecMode.ONE_OFF)
      await _addOneRouteNotification(route, date);
    else if (route.recMode == RecMode.WEEKLY) {
      var dayList = <Day>[];
      route.recList.forEach((day) {
        dayList.add(days[day]);
      });
      await _addWeeklyRouteNotification(route, dayList);
    }
  }

  static Future<void> _addOneRouteNotification(
      BusRoute route, DateTime routeDate) async {
    var stops = route.routeStops;
    TimeOfDay time = route.startTime;
    DateTime startTime = DateTime(
      routeDate.year,
      routeDate.month,
      routeDate.day,
      time.hour,
      time.minute,
    );
    startTime = startTime.subtract(Duration(minutes: 5));
    DateTime scheduleDate;
    Stop stop;
    for (int i = 0; i < stops.length; i += 1) {
      stop = stops[i];
      scheduleDate = startTime.add(
        Duration(
          hours: stop.offset.hour,
          minutes: stop.offset.minute,
        ),
      );
      if (check(scheduleDate))
        await addNotification(
          scheduleDate,
          route.name,
          stop,
        );
    }
    await _showScheduleDone(route.name);
  }

  static Future<void> _addWeeklyRouteNotification(
      BusRoute route, List<Day> dayList) async {
    Day day;
    Stop stop;
    TimeOfDay startTime = route.startTime;
    for (int i = 0; i < dayList.length; i += 1) {
      day = dayList[i];
      for (int j = 0; j < route.routeStops.length; j += 1) {
        stop = route.routeStops[j];
        await _addWeeklyAtDayAndTime(
            stop,
            route.name,
            Time(
              startTime.hour + stop.offset.hour,
              startTime.minute + stop.offset.minute,
              0,
            ),
            day);
      }
    }
    await _showScheduleDone(route.name);
  }

  static Future<void> _addMonthlyRouteNotification(BusRoute route) async {}

  static Future<void> addNotification(
      DateTime date, String name, Stop stop) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    var scheduleDate = date;
    var pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var id = pending.length;
    id += 1;
    print("Reminder $id Set");
    await flutterLocalNotificationsPlugin.schedule(
      id,
      "Reminder ${stop.stopName}",
      "Route $name : Bus Will Reach Stop ${stop.stopName} In 5 mins",
      scheduleDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> _showScheduleDone(String name) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      '<b>Reminder</b>',
      'Schedule for $name Set',
      platformChannelSpecifics,
    );
  }

  static Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("Notification $id Cancelled");
  }

  static Future<void> checkPendingNotificationRequests(context) async {
    var pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var list = <Widget>[];
    pendingNotificationRequests.forEach((element) {
      var id = element.id;
      var title = element.title;
      list.add(Text("$id $title"));
    });
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              height: 100,
              width: 100,
              child: ListView(
                children: list,
              )),
          actions: [
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _addDailyAtTime() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    var time =
        Time(scheduleDate.hour, scheduleDate.minute, scheduleDate.second);
    var pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var id = pending.length;
    id += 1;
    await flutterLocalNotificationsPlugin.showDailyAtTime(
      id,
      'show daily title',
      'Daily notification shown at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
      time,
      platformChannelSpecifics,
    );
  }

  static Future<void> _addWeeklyAtDayAndTime(
      Stop stop, String name, Time time, Day day) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    var pending =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    var id = pending.length;
    id += 1;
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      id,
      'Reminder ${stop.stopName}',
      "Route $name : Bus Will Reach Stop ${stop.stopName} In 5 mins",
      day,
      time,
      platformChannelSpecifics,
    );
  }

  static String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }
}
