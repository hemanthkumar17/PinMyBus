import 'package:flutter/material.dart';
import 'dart:convert';

import 'stops.dart';

enum RecMode { ONE_OFF, WEEKLY, MONTHLY }

class Routes {
  String name;
  RecMode recMode;
  Stop start = Stop("", ""), end = Stop("", "");
  List<String> recList;
  List<Stop> routeStops;
  TimeOfDay startTime;
  String ownerId;
  Map toJson() => jsonDecode(jsonEncode(Route));  
  Routes(this.name, this.recMode, this.recList);
}
