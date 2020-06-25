import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/userData.dart';
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
  String routeId;

  BusData userData;

  BusRoute(this.name, this.recMode, this.recList);

  Map<String, dynamic> toJson() => {
        'name': name,
        'recMode': recMode.toString().substring(8),
        'start': start.toJson(),
        'end': end.toJson(),
        'recList': recList,
        'routeStops': routeStops.map((e) => e.toJson()).toList(),
        'startTime': startTime.hour.toString().padLeft(2, '0') +
            startTime.minute.toString().padLeft(2, '0'),
        'ownerId': userData.id,
        'routeId': routeId,
        'busName': userData.busName,
        'ownerName': userData.ownerName,
      };

  BusRoute.fromResponse(response) {
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

    this.recList = response["recList"].cast<String>();

    String startTimeTemp = response["startTime"].padLeft(4, "0");
    this.startTime = TimeOfDay(
        hour: int.parse(startTimeTemp.substring(0, 2)),
        minute: int.parse(startTimeTemp.substring(2)));

    userData = BusData.fromJson(response);

    this.routeStops = [];

    print(response['routeStops']);
    print(stopsComplete);

    for (var stop in response["routeStops"]) {
      if (stopsComplete.firstWhere(
              (element) => element.stopid == stop["stopId"],
              orElse: () => null) !=
          null) {
        this.routeStops.add(stopsComplete
            .firstWhere((element) => element.stopid == stop["stopId"]));

        String timeOfArrival = stop["timeOfArrival"].toString().padLeft(4, "0");
        this.routeStops.last.offset = TimeOfDay(
            hour: int.parse(timeOfArrival.substring(0, 2)),
            minute: int.parse(timeOfArrival.substring(2)));
      }
    }
    this.start = routeStops.first;
    this.end = routeStops.last;

    this.routeId = response["_id"];
  }
}
