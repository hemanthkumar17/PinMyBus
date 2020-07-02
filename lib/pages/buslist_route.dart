import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/userData.dart';
import 'package:pinmybus/widgets/loadingpagewidget.dart';

class BuslistRoute extends StatefulWidget {
  final Map args;
  BuslistRoute({Key key, @required this.args}) : super(key: key);

  @override
  _BuslistRouteState createState() => _BuslistRouteState();
}

class _BuslistRouteState extends State<BuslistRoute> {
  List<BusRoute> routeList = [];
  List<Widget> routeWid = [];

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _getRouteListByRoute() async {
    print(widget.args);
    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: widget.args["function"]);
    final HttpsCallableResult response =
        await callable.call(widget.args["data"]);
    print(response.data);
    for (var route in response.data) {
      routeList.add(BusRoute.fromResponse(route));
    }
    createWid();
    return true;
  }

  void createWid() {
    routeWid = [];
    for (var route in routeList) {
      print(route.userData.toJson());
      routeWid.add(Container(
          height: 100,
          color: Color.fromRGBO(255, 171, 0, .9),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/routeinfo', arguments: route);
            },
            child: Card(
                child: Stack(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                ),
                Align(
                    alignment: Alignment(-.75, -.60),
                    child: Text(
                      route.userData.ownerName,
                      style: TextStyle(fontSize: 25),
                    )),
                Align(
                    alignment: Alignment(.30, -.50),
                    child: Text(
                      "Departure :",
                      style: TextStyle(fontSize: 10),
                    )),
                Align(
                    alignment: Alignment(.75, -.60),
                    child: Text(
                      route.startTime.hour.toString().padLeft(2, "0") +
                          ':' +
                          route.startTime.minute.toString().padLeft(2, "0"),
                      style: TextStyle(fontSize: 25),
                    )),
                Align(
                    alignment: Alignment(.35, .4),
                    child: Text(
                      'Arrival: ',
                      style: TextStyle(fontSize: 10),
                    )),
                Align(
                    alignment: Alignment(.75, .5),
                    child: Text(
                      route.end.offset.hour.toString().padLeft(2, "0") +
                          ':' +
                          route.end.offset.minute.toString().padLeft(2, "0"),
                      style: TextStyle(fontSize: 25),
                    )),
                Align(
                  alignment: Alignment(-.75, .50),
                  child: Text(
                    route.userData.licenseNumber,
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                )
              ],
            )),
          )));
    }
    if (routeWid == [])
      routeWid = [
        Container(
            height: 100,
            color: Color.fromRGBO(255, 171, 0, .9),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/routeinfo');
              },
              child: Card(
                  child: Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                  ),
                  Align(
                    alignment: Alignment(-.75, .50),
                    child: Text(
                      "No routes exist",
                      style: TextStyle(fontSize: 15, color: Colors.black45),
                    ),
                  )
                ],
              )),
            ))
      ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routes'),
        backgroundColor: Color.fromRGBO(255, 171, 0, .9),
      ),
      body: FutureBuilder(
        future: _getRouteListByRoute(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData)
            return SingleChildScrollView(
              child: Column(
                children: routeWid,
              ),
            );
          else
            return LoadingPageWidget();
        },
      ),
    );
  }
}
