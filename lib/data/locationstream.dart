import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {
  StreamController<LatLng> _locationController = StreamController<LatLng>();
  Stream<LatLng> get locationStream => _locationController.stream;
  Location location = Location();

  LocationService() {
    location.requestPermission().then((granted) {
      if (granted == PermissionStatus.granted) {
        location.getLocation().then((locationData) {
          if (locationData != null) {
            print(locationData);
            _locationController.add(LatLng(
              locationData.latitude,
              locationData.longitude,
            ));
          }
        });
        location.onLocationChanged.listen((locationData) {
          if (locationData != null) {
            _locationController.add(LatLng(
              locationData.latitude,
              locationData.longitude,
            ));
          }
        });
      }
    });
  }
}
