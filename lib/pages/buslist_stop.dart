import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:pinmybus/widgets/loadingpagewidget.dart';

class BuslistStop extends StatefulWidget {
  final Stop stop;
  BuslistStop({Key key, @required this.stop}) : super(key: key);

  @override
  _BuslistStopState createState() => _BuslistStopState();
}

class _BuslistStopState extends State<BuslistStop> {
  List<BusRoute> routeList = [];
  Future<bool> _getRouteListByStop() async {
    Map<String, dynamic> data = {
      "startStop": widget.stop.stopid,
    };
    print(data);
    final HttpsCallable callable =
        CloudFunctions.instance.getHttpsCallable(functionName: "searchRoutes");
    final HttpsCallableResult response = await callable.call(data);
    print(response.data);
    for (var route in response.data) {
      routeList.add(BusRoute.fromResponse(route));
    }
    return true;
  }

  List<Widget> routeWid = [];

  List<Widget> createWid() {
    routeWid = [];
    for (BusRoute route in routeList) {
      Stop stop = route.routeStops.firstWhere(
          (element) => element.stopName == widget.stop.stopName, orElse: () {
        return null;
      });
      print(stop);
      if (stop == null) continue;
      print(route.userData);
      print(route.toJson());
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
                      route.userData.busName ?? "default",
                      style: TextStyle(fontSize: 25),
                    )),
                Align(
                    alignment: Alignment(.75, -.60),
                    child: Text(
                      stop.offset.hour.toString().padLeft(2, "0") +
                          ':' +
                          stop.offset.minute.toString().padLeft(2, "0"),
                      style: TextStyle(fontSize: 25),
                    )),
                Align(
                  alignment: Alignment(-.75, .50),
                  child: Text(
                    route.userData.licenseNumber ?? "default",
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                )
              ],
            )),
          )));
    }
    print(routeWid);
    if (routeWid.isEmpty) {
      routeWid = [
        Container(
            height: 100,
            color: Color.fromRGBO(255, 171, 0, .9),
            child: Card(
              child: Center(
                child: Text("No routes exist", style: TextStyle(fontSize: 20)),
              ),
            ))
      ];
      print("empty");
    }
    return routeWid;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stop.stopName ?? "default"),
        backgroundColor: Color.fromRGBO(255, 171, 0, .9),
      ),
      body: FutureBuilder(
        future: _getRouteListByStop(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData)
            return SingleChildScrollView(
              child: Column(
                children: createWid(),
              ),
            );
          else
            return LoadingPageWidget();
        },
      ),
    );
  }
}
