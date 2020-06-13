import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Stop {
  LatLng location;
  String stopid;
  String stopName;
  TimeOfDay offset;
  Stop(this.stopName, this.stopid, this.location);
}
