import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/globals.dart';
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
  BusRoute.fromResponse(Map<String, dynamic> response) {
    this.name = response["name"];
    switch (response["recMode"]) {
      case "WEEKLY":
        this.recMode = RecMode.WEEKLY;
        break;
      case "ONE_OFF":
        this.recMode = RecMode.ONE_OFF;
        break;
      case "MONTHLY":
        this.recMode = RecMode.MONTHLY;
        break;
    }
    this.recList = response["recList"];
    this.startTime = TimeOfDay(
        hour: response["startTime"].substring(0, 2),
        minute: response["startTime"].substring(2));
    this.ownerId = response["ownerId"];
    this.routeStops = [];
    for (var stop in response["routeStops"]) {
      this.routeStops.add(stopsComplete.firstWhere((element) => element.stopid == stop["stopId"]));
    }
    this.start = routeStops.first;
    this.end = routeStops.last;
  }
}
