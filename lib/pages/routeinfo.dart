import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:pinmybus/utils/reminder.dart';

DateTime date ;

class Routeinfo extends StatefulWidget {
  final BusRoute route;
  Routeinfo({Key key, @required this.route}) : super(key: key);

  @override
  _RouteinfoState createState() => _RouteinfoState();
}

class _RouteinfoState extends State<Routeinfo> {
  Set<Marker> markerStops = {};
  Marker current;
  final Location location = Location();
  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

  Timer timer;

  void startTime() {
    FirebaseDatabase.instance
        .reference()
        .child("routes")
        .child(widget.route.routeId)
        .child("location")
        .onValue
        .listen((event) {
      var data = event.snapshot.value;
      print(LatLng(data["latitude"], data["longitude"]));
      if (data != null) {
        current = Marker(
          markerId: MarkerId('driver'),
          position: LatLng(data["latitude"], data["longitude"]),
          infoWindow: InfoWindow(title: 'Bus'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        );
        print("notNull");
      } else
        current = null;
    });
    print(_location.toString());
  }

  @override
  void initState() {
    super.initState();
    _listenLocation();
    startTime();
  }

  Future<void> _listenLocation() async {
    _locationSubscription =
        location.onLocationChanged.handleError((dynamic err) {
      if (!mounted) return;
      setState(() {
        _error = err.code;
      });
      _locationSubscription.cancel();
    }).listen((LocationData currentLocation) {
      if (!mounted) return;
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
    List<Widget> boxList = [];
    for (var stop in widget.route.routeStops) {
      boxList.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _boxes(stop.location.latitude, stop.location.longitude, stop,
              stop.offset),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: boxList,
        ),
      ),
    );
  }

  Widget _boxes(double lat, double long, Stop stop, TimeOfDay offset) {
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
            width: 300,
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment(0, -.40),
                  child: Card(
                    child: Container(
                      height: 50,
                      width: 350,
                      child: Center(
                        child: Text(
                          stop.stopName,
                          style: TextStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(.75, .40),
                  child: Text(
                    'Time of arrival:',
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment(.75, .80),
                  child: Text(
                    offset.hour.toString().padLeft(2, "0") +
                        ':' +
                        offset.minute.toString().padLeft(2, "0"),
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Align(
                  alignment: Alignment(-.80, .90),
                  child: Container(
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        height: 30,
                        width: 80,
                        child: Center(
                          child: Text(
                            "Set a Reminder",
                            style: TextStyle(fontSize: 11, color: Colors.black),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await Scheduler.addNotification(
                          DateTime.now(),
                          widget.route.name,
                          stop,
                        );
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                content: Container(
                                  child: Text("Reminder Set"),
                                ),
                                actions: [
                                  FlatButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    markerStops = {};
    for (var stop in widget.route.routeStops) {
      markerStops.add(
        Marker(
          markerId: MarkerId(stop.stopid),
          position: stop.location,
          infoWindow: InfoWindow(title: stop.stopName),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
    markerStops.add(
      Marker(
        markerId: MarkerId('driver'),
        position: LatLng(_location.latitude, _location.longitude),
        infoWindow: InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );
    if (current != null) markerStops.add(current);
    print("Hello");
    print(markerStops.map((e) => e.position).toList());

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
        markers: markerStops,
        onCameraMove: (CameraPosition position) {},
      ),
    );
  }
}
