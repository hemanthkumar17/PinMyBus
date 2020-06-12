import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Routeinfo extends StatefulWidget {
  Routeinfo({Key key}) : super(key: key);

  @override
  _RouteinfoState createState() => _RouteinfoState();
}

class _RouteinfoState extends State<Routeinfo> {
  final Location location = Location();
  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      setState(() {
        _error = null;

        _location = currentLocation;
      });
    });
  }

  Future<void> _stopListen() async {
    _locationSubscription.cancel();
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 20,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _listenLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
          title: Center(child: Text("Home           ")),
        ),
        body: Stack(
          children: <Widget>[
            _buildGoogleMap(context),
            SlidingUpPanel(
              panel: Container(
                color: Colors.white,
                child: Center(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Icon(Icons.arrow_upward),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  'Swipe',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Color.fromRGBO(255, 171, 0, .9)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          child: _buildContainer(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              maxHeight: 300,
              minHeight: 75,
            ),
            Align(
              alignment: Alignment(.95, .95),
              child: Container(
                width: 50,
                height: 50,
                child: RaisedButton(
                    child: Center(
                        child: Icon(
                      IconData(58716, fontFamily: 'MaterialIcons'),
                      color: Colors.white,
                    )),
                    color: Color.fromRGBO(255, 171, 0, .9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    onPressed: () {
                      _gotoLocation(_location.latitude, _location.longitude);
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildContainer() {
    String distance = '100m';
    double stoplatitude = 0;
    double stoplongitude = 0;
    String stopname = 'this is the template remove the rest';
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(stoplatitude, stoplongitude, stopname, distance),
            ),
            //below are not templates and can be deleted
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(11.320775, 75.933986, "Name of Start", '10m'),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(11.321742, 75.932980, "Name of End", '10m'),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(11.321742, 75.932980, "Name of End", '10m'),
            )
          ],
        ),
      ),
    );
  }

  Widget _boxes(
    double lat,
    double long,
    String stopname,
    String dist,
  ) {
    String timehr = "00";
    String timemin = "00";
    return GestureDetector(
        onTap: () {
          _gotoLocation(lat, long);
        },
        child: Container(
          child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white70, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color.fromRGBO(255, 171, 0, .9),
              child: Container(
                width: 400,
                child: Stack(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment(0, -.40),
                        child: Card(child: Container(
                          height : 50,
                          width : 350,
                          child: Center(child: Text(stopname,style: TextStyle(),))))),
                    Align(
                        alignment: Alignment(-.75, .40),
                        child: Text('Distance:',
                            style: TextStyle(
                              fontSize: 10,
                            ))),
                    Align(alignment: Alignment(-.75, .80), child: Text(dist)),
                    Align(
                        alignment: Alignment(.75, .40),
                        child: Text(
                          'Time of arrival:',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        )),
                    Align(
                        alignment: Alignment(.75, .80),
                        child: Text(
                          timehr + ':' + timemin,
                          style: TextStyle(fontSize: 15),
                        )),
                  ],
                ),
              )),
        ));
  }

  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(_location.latitude, _location.longitude), zoom: 20),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          // startMarker,

          Marker(
            markerId: MarkerId('start'),
            position: LatLng(11.320775, 75.933986),
            infoWindow: InfoWindow(title: 'Name of Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),

          // driverMarker,
          Marker(
            markerId: MarkerId('driver'),
            position: LatLng(_location.latitude, _location.longitude),
            infoWindow: InfoWindow(title: 'You'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
          // endMarker,
          Marker(
            markerId: MarkerId('end'),
            position: LatLng(11.321742, 75.932980),
            infoWindow: InfoWindow(title: 'Name of End'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          )
        },
        onCameraMove: (CameraPosition position) {},
      ),
    );
  }
}