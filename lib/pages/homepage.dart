import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/data/locationstream.dart';
import 'package:pinmybus/models/globals.dart';

import 'package:pinmybus/widgets/homewidget.dart';
import 'package:pinmybus/widgets/loadingpagewidget.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildGoogleMap(BuildContext context, LatLng locationData,
      Completer<GoogleMapController> _controller) {
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
        markerId: MarkerId("You"),
        position: locationData,
        infoWindow: InfoWindow(title: "You"),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: locationData, zoom: 15),
        markers: markerStops,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Completer<GoogleMapController> _controller = Completer();

    return WillPopScope(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                // DrawerHeader(child: Column(children: <Widget>[Container()])),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Search for a Route'),
                  onTap: () {
                    Navigator.pushNamed(context, '/searchRoute');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_balance),
                  title: Text('Instituitional Buses'),
                  onTap: () {
                    Navigator.pushNamed(context, '/insti');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.add_location),
                  title: Text('Suggest Stop'),
                  onTap: () {
                    Navigator.pushNamed(context, '/suggest');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.alarm),
                  title: Text('Reminders'),
                  onTap: () {
                    Navigator.pushNamed(context, '/reminders');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    // _signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                )
              ],
            ),
          ),
          key: _scaffoldKey,
          body: Container(
              alignment: FractionalOffset.center,
              child: StreamBuilder<LatLng>(
                stream: LocationService().locationStream,
                builder: (context, snapshot) {
                  List<Widget> children;
                  Geolocator().isLocationServiceEnabled().then((value) async {
                    if (value == false) {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Error"),
                              content: Text("Please Enable location services"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Done"),
                                  onPressed: () {
                                    Geolocator()
                                        .isLocationServiceEnabled()
                                        .then((value) {
                                      if (value == true) Navigator.pop(context);
                                    });
                                  },
                                )
                              ],
                            );
                          });
                    }
                  });
                  if (snapshot.hasError) {
                    children = <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('Error: ${snapshot.error}'),
                      )
                    ];
                  } else {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        children = <Widget>[
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: 60,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Enable location services'),
                          )
                        ];
                        break;
                      case ConnectionState.waiting:
                        children = <Widget>[LoadingPageWidget()];
                        break;
                      case ConnectionState.active:
                        Geolocator()
                            .isLocationServiceEnabled()
                            .then((value) async {
                          if (value == false) {
                            await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content:
                                        Text("Please Enable location services"),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text("Done"),
                                        onPressed: () {
                                          Geolocator()
                                              .isLocationServiceEnabled()
                                              .then((value) {
                                            if (value == true)
                                              Navigator.pop(context);
                                          });
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        });
                        children = <Widget>[
                          Stack(
                            children: <Widget>[
                              _buildGoogleMap(
                                  context, snapshot.data, _controller),
                              HomeStackWidget(_controller, _scaffoldKey),
                            ],
                          )
                        ];
                        break;
                      case ConnectionState.done:
                        children = <Widget>[
                          Icon(
                            Icons.info,
                            color: Colors.blue,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('\$${snapshot.data} (closed)'),
                          )
                        ];
                        break;
                    }
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  );
                },
              )),
        ),
        onWillPop: () async {
          if (_scaffoldKey.currentState.isDrawerOpen) {
            return true;
          } else
            return showDialog<bool>(
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
            );
        });
  }
}
