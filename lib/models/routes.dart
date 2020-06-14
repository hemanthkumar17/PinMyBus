import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

import 'stops.dart';

enum RecMode { ONE_OFF, WEEKLY, MONTHLY }

class BusRoute {
  String name;
  RecMode recMode;
  Stop start = Stop("", "", LatLng(0, 0)), end = Stop("", "", LatLng(0, 0));
  List<String> recList;
  List<Stop> routeStops;
  TimeOfDay startTime;
  String ownerId;
  Map toJson() => jsonDecode(jsonEncode(Route));  
  BusRoute(this.name, this.recMode, this.recList);
}
