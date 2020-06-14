import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

Routes mockRoute;

Routes initMockRoute() {
  Routes temp = Routes(
    "Route_1",
    RecMode.ONE_OFF,
    ['0', '1', '2'],
  );
  var tempStops = <Stop>[];
  var min = 0;
  var hour = 0;
  for (int i = 0; i < 5; i += 1) {
    Stop tempStop = Stop("Stop_$i", "$i");
    hour = ((i * 1) / 60).floor();
    min = (i * 1) % 60;
    tempStop.offset = TimeOfDay(
      hour: hour,
      minute: min,
    );
    tempStops.add(tempStop);
  }
  temp.startTime = TimeOfDay(
    hour: 20,
    minute: 23,
  );
  temp.routeStops = tempStops;
  return temp;
}

Future<bool> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("Creating Mock Route");
  mockRoute = initMockRoute();
  print("Route ${mockRoute.routeStops}");

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
  print("InitDone");
  return true;
}

class Remind extends StatefulWidget {
  @override
  _RemindState createState() => _RemindState();
}

class _RemindState extends State<Remind> {
  @override
  Widget build(BuildContext context) {
    Future<bool> x = init();
    return MaterialApp(
      home: FutureBuilder(
        future: x,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done)
            return MaterialApp(
              home: HomePage(),
            );
          else
            return CircularProgressIndicator();
        },
      ),
    );
  }
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MethodChannel platform =
      MethodChannel('crossingthestreams.io/resourceResolver');
  @override
  void initState() {
    super.initState();
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
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

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SecondScreen(receivedNotification.payload),
                  ),
                );
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(payload),
        ),
      );
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text(
                        'Tap on a notification when it appears to trigger navigation'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Did notification launch app? ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '${notificationAppLaunchDetails?.didNotificationLaunchApp ?? false}',
                          )
                        ],
                      ),
                    ),
                  ),
                  if (notificationAppLaunchDetails?.didNotificationLaunchApp ??
                      false)
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Launch notification payload: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: notificationAppLaunchDetails.payload,
                            )
                          ],
                        ),
                      ),
                    ),
                  PaddedRaisedButton(
                    buttonText: "Select Date",
                    onPressed: () => DatePicker.showDateTimePicker(
                      context,
                      onChanged: (date) {
                        scheduleDate = date;
                        print("Selected $date");
                      },
                      onConfirm: (date) {
                        setState(() {
                          scheduleDate = date;
                        });
                        print("Confirmed $date");
                      },
                      currentTime: scheduleDate,
                    ),
                  ),
                  Text(scheduleDate.toString()),
                  PaddedRaisedButton(
                    buttonText: 'Add RouteSchedule',
                    onPressed: () async {
                      await Scheduler._addOneRouteNotification(mockRoute);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Add Notification',
                    onPressed: () async {
                      await Scheduler._addNotification(
                          scheduleDate, 'busName', 'stopName');
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel notification',
                    onPressed: () async {
                      await Scheduler._cancelNotification(0);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification every day at $scheduleDate',
                    onPressed: () async {
                      await Scheduler._addDailyAtTime();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText:
                        'Repeat notification weekly on Monday at $scheduleDate',
                    onPressed: () async {
                      await Scheduler._addWeeklyAtDayAndTime();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show insistent notification [Android]',
                    onPressed: () async {
                      await Scheduler._showInsistentNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Show ongoing notification [Android]',
                    onPressed: () async {
                      await Scheduler._showOngoingNotification();
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Check pending notifications',
                    onPressed: () async {
                      await Scheduler._checkPendingNotificationRequests(
                          context);
                    },
                  ),
                  PaddedRaisedButton(
                    buttonText: 'Cancel all notifications',
                    onPressed: () async {
                      await Scheduler._cancelAllNotifications();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  SecondScreen(this.payload);

  final String payload;

  @override
  State<StatefulWidget> createState() => SecondScreenState();
}

class SecondScreenState extends State<SecondScreen> {
  String _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen with payload: ${(_payload ?? '')}'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class Scheduler {
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

  static Future<void> _addOneRouteNotification(Routes route) async {
    var stops = route.routeStops;
    var today = DateTime.now();
    TimeOfDay time = route.startTime;
    DateTime startTime = DateTime(
      today.year,
      today.month,
      today.day,
      time.hour,
      time.minute,
    );
    print("StartTime $startTime");
    startTime = startTime.subtract(Duration(minutes: 5));
    print("StartTime $startTime");
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
      print("Schedule $scheduleDate");
      if (check(scheduleDate))
        await _addNotification(
          scheduleDate,
          route.name,
          stop.stopName,
        );
    }
    await _showScheduleDone(route.name);
  }

  static Future<void> _addDailyRouteNotification(Routes route) async {}

  static Future<void> _addWeeklyRouteNotification(Routes route) async {}

  static Future<void> _addNotification(
      DateTime date, String no, String stop) async {
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
    await flutterLocalNotificationsPlugin.schedule(
      id,
      "Reminder $stop",
      "Bus $no Will Reach Stop $stop In 5 mins",
      scheduleDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
    );
    print(scheduleDate);
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

  static Future<void> _showInsistentNotification() async {
    // This value is from: https://developer.android.com/reference/android/app/Notification.html#FLAG_INSISTENT
    var insistentFlag = 4;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker',
      additionalFlags: Int32List.fromList([insistentFlag]),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'insistent title',
      'insistent body',
      platformChannelSpecifics,
    );
  }

  static Future<void> _checkPendingNotificationRequests(context) async {
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

  static Future<void> _showOngoingNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'PinMyBus',
      'PinMyBusChannel',
      'PinMyBus Notification Channel',
      importance: Importance.Max,
      priority: Priority.High,
      ongoing: true,
      autoCancel: false,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics,
      iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'ongoing notification title',
      'ongoing notification body',
      platformChannelSpecifics,
    );
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

  static Future<void> _addWeeklyAtDayAndTime() async {
    var time =
        Time(scheduleDate.hour, scheduleDate.minute, scheduleDate.second);
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
      'show weekly title',
      'Weekly notification shown on Monday at approximately ${_toTwoDigitString(time.hour)}:${_toTwoDigitString(time.minute)}:${_toTwoDigitString(time.second)}',
      Day.Monday,
      time,
      platformChannelSpecifics,
    );
  }

  static String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }
}
