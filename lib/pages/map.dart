import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/userData.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  final Location location = Location();
  LocationData _location;
  StreamSubscription<LocationData> _locationSubscription;
  String _error;

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
      zoom: 15,
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

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<void> _signOut() async {
    // await _firebaseAuth.signOut();
  }

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                //   decoration: BoxDecoration(
                //       color: Color.fromRGBO(255, 171, 0, .9),
                //       shape: BoxShape.circle),
                //   child: IconButton(
                //     icon: Icon(Icons.my_location),
                //     iconSize: 30,
                //     onPressed: () =>
                //         _gotoLocation(_location.latitude, _location.longitude),
                //   ),
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
        onWillPop: () => showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: Text('Warning'),
                content: Text('Do you really want to exit'),
                actions: [
                  FlatButton(
                    child: Text('No'),
                    onPressed: () => Navigator.pop(c, false),
                  ),
                  FlatButton(
                    child: Text('Yes'),
                    onPressed: () => Navigator.pop(c, true),
                  ),
                ],
              ),
            ));
  }

  Widget _buildContainer() {
    List<Widget> boxList = [];
    for (var stop in stopsComplete) {
      boxList.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _boxes(
              stop.location.latitude, stop.location.longitude, stop.stopName),
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

  Widget _boxes(
    double lat,
    double long,
    String stopname,
  ) {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(stopname),
                    RaisedButton(
                      onPressed: () async {
                        _stopListen();
                        Map<String, dynamic> data = {
                          "startStop": stopsComplete
                              .firstWhere(
                                  (element) => element.stopName == stopname)
                              .stopid,
                        };
                        print(data);
                        final HttpsCallable callable = CloudFunctions.instance
                            .getHttpsCallable(functionName: "searchRoutes");
                        final HttpsCallableResult response =
                            await callable.call(data);
                        print(response);
                        List<BusRoute> routeList = [];
                        List<Data> userData = [];
                        for (var route in response.data) {
                          routeList.add(BusRoute.fromResponse(route));
                          print(route);
                        }
                        Navigator.pushNamed(context, '/buslist_stop',
                            arguments: {
                              "routeList": routeList,
                              "stopName": stopname,
                              "userData": userData
                            });
                      },
                      color: Colors.white,
                      child: Container(
                          height: 25,
                          width: 50,
                          child: Center(
                            child: Text(
                              'More',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromRGBO(255, 171, 0, .9)),
                            ),
                          )),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    )
                  ],
                ),
              )),
        ));
  }

  Widget _buildGoogleMap(BuildContext context) {
    Set<Marker> markerStops = {};
    for (var stop in stopsComplete) {
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

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(_location.latitude, _location.longitude), zoom: 15),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markerStops,
        onCameraMove: (CameraPosition position) {},
      ),
    );
  }
}
