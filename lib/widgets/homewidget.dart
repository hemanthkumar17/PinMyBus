import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/utils/reminder.dart';
import 'package:pinmybus/widgets/search.dart';
import 'package:pinmybus/models/stops.dart';

class HomeStackWidget extends StatefulWidget {
  final Completer<GoogleMapController> _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  HomeStackWidget(this._controller, this._scaffoldKey, {Key key})
      : super(key: key);

  @override
  _HomeStackWidgetState createState() => _HomeStackWidgetState();
}

class _HomeStackWidgetState extends State<HomeStackWidget> {
  Future<void> _gotoLocation(double lat, double long) async {
    (await widget._controller.future)
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 15,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }

  String stop = "Search for your stop...";
  Icon stopCancel = Icon(Icons.search);

  Future<void> searchStop(context) async {
    var res = await showSearch(
      context: context,
      delegate: Stopsearch(stopsComplete),
    );
    setState(() {
      if (res == null || res.stopName == '') {
        stop = "Search for your stop...";
        stopCancel = Icon(Icons.search);
      } else {
        stop = res.stopName;
        stopCancel = Icon(Icons.arrow_back);
        stopsComplete.remove(res);
        stopsComplete.insert(0, res);
        _gotoLocation(res.location.latitude, res.location.longitude);
      }
    });
  }

  List<Widget> generateCards() {
    List<Widget> _cardList = [];

    for (var stop in stopsComplete) {
      _cardList.add(stopCard(stop));
    }
    return _cardList;
  }

  Widget stopCard(Stop stop) {
    return GestureDetector(
      child: Padding(
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
                      Text(
                        "Tap to View Routes",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ]))),
      ),
      onTap: () =>
          Navigator.pushNamed(context, '/buslist_stop', arguments: stop),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top * 1.5),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white70),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          color: Colors.white,
                          child: Row(children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.menu),
                              onPressed: () {
                                widget._scaffoldKey.currentState.openDrawer();
                              },
                            ),
                            InkWell(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(left: 10),
                                        child: IconButton(
                                          icon: stopCancel,
                                          onPressed: () {
                                            if (stopCancel.icon ==
                                                Icons.arrow_back) {
                                              setState(() {
                                                stopCancel = Icon(Icons.search);
                                                stop =
                                                    "Search for your stop...";
                                              });
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text(stop,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                            )),
                                      ),
                                    ]),
                                onTap: () {
                                  searchStop(context);
                                }),
                          ])))),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).padding.top,
                      0,
                      MediaQuery.of(context).padding.top,
                      MediaQuery.of(context).padding.top),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 8,
                      child: ListView(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: generateCards())))
            ]),
      ),
    );
  }
}
