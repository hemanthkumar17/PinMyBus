import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pinmybus/data/locationstream.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:pinmybus/utils/reminder.dart';

DateTime date;

class Routeinfo extends StatefulWidget {
  final BusRoute route;
  Routeinfo({Key key, @required this.route}) : super(key: key);

  @override
  _RouteinfoState createState() => _RouteinfoState();
}

class _RouteinfoState extends State<Routeinfo> {
  BitmapDescriptor pinbus;
  
  Set<Marker> markerStops = {};
  Marker current;

  Timer timer;
  void custompin() async {
    var pinbus = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/pinbus.png');
      setState(() {
        this.pinbus=pinbus;
      });
   }
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
          icon: pinbus
          ,
        );
        print("notNull");
      } else
        current = null;
    });
  }

  @override
  void initState() {
    super.initState();
    startTime();
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

  List<Widget> generateCards() {
    List<Widget> _cardList = [];

    for (var stop in widget.route.routeStops) {
      _cardList.add(stopCard(stop));
    }
    return _cardList;
  }

  Widget stopCard(Stop stop) {
    return Padding(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.directions_bus),
                        Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  stop.stopName,
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                )))
                      ],
                    ),
                    Container(
                      child: FlatButton(
                        color: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          height: 30,
                          width: 80,
                          child: Center(
                            child: Text(
                              "Set a Reminder",
                              style:
                                  TextStyle(fontSize: 11, color: Colors.black),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          var dateNow = DateTime.now();
                          DateTime date = DateTime(
                            dateNow.year,
                            dateNow.month,
                            dateNow.day,
                            stop.offset.hour,
                            stop.offset.minute,
                          );
                          await Scheduler.addNotification(
                            date,
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
                  ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: StreamBuilder<LatLng>(
          stream: LocationService().locationStream,
          builder: (context, snapshot) {
            List<Widget> children;
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
                  return Center(
                      child: AvatarGlow(
                          endRadius: 150,
                          duration: Duration(seconds: 2),
                          glowColor: Color.fromRGBO(255, 171, 0, .9),
                          repeat: true,
                          repeatPauseDuration: Duration(seconds: 2),
                          startDelay: Duration(seconds: 1),
                          child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(100)),
                              child: Image.asset(
                                'assets/images/logo.png',
                              ))));
                  break;
                case ConnectionState.active:
                  children = <Widget>[
                    Stack(children: <Widget>[
                      _buildGoogleMap(context, snapshot.data),
                      Padding(padding: EdgeInsets.only(top:MediaQuery.of(context).padding.top),child:IconButton(icon:Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context),)),
                      Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).padding.top,
                                      0,
                                      MediaQuery.of(context).padding.top,
                                      MediaQuery.of(context).padding.top),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              8,
                                      child: ListView(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          children: generateCards())))))
                    ])
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
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context, LatLng userLocation) {
    markerStops = {};
  Set<Polyline> _polylines = {};
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
      if(widget.route.routeStops.last.stopName != stop.stopName)
        _polylines.add(Polyline(
            polylineId: PolylineId(stop.location.toString()),
            visible: true,
            //latlng is List<LatLng>
            points: [stop.location, widget.route.routeStops.elementAt(widget.route.routeStops.indexOf(stop) + 1).location],
            color: Colors.blue,
        ));
    }
    markerStops.add(
      Marker(
        markerId: MarkerId('driver'),
        position: LatLng(userLocation.latitude, userLocation.longitude),
        infoWindow: InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      ),
    );
    if (current != null) markerStops.add(current);
    print("Hello");
    print(markerStops.map((e) => e.position).toList());
    print(_polylines.map((e) => e.points).toList());
  


    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(userLocation.latitude, userLocation.longitude),
            zoom: 20),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        zoomControlsEnabled: false,
        markers: markerStops,
        onCameraMove: (CameraPosition position) {},
        polylines: _polylines,
      ),
    );
  }
}
