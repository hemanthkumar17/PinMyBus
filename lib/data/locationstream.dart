import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  StreamController<LatLng> _locationController = StreamController<LatLng>();
  Stream<LatLng> get locationStream => _locationController.stream;

  LocationService() {
    const LocationOptions locationOptions =
          LocationOptions(accuracy: LocationAccuracy.best);
      Geolocator().getPositionStream(locationOptions).listen(
          (Position position) => _locationController.add(LatLng(position.latitude, position.longitude)));
  }
}
