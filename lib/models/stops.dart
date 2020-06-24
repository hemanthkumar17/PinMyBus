import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Stop {
  LatLng location;
  String stopid;
  String stopName;
  TimeOfDay offset;
  Stop(this.stopName, this.stopid, this.location);

  Map<String, dynamic> toJson() => {
        'location': [location.latitude, location.longitude],
        'stopid': stopid,
        'stopName': stopName,
        'offset': offset.hour.toString().padLeft(2, '0') +
            offset.minute.toString().padLeft(2, '0'),
      };
  Map<String, dynamic> toJsonNoOffset() => {
        'location': [location.latitude, location.longitude],
        'stopid': stopid,
        'stopName': stopName,
      };

}
