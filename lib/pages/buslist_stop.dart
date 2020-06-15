import 'package:flutter/material.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/stops.dart';

class BuslistStop extends StatefulWidget {
  final Map args;
  BuslistStop({Key key, @required this.args}) : super(key: key);

  @override
  _BuslistStopState createState() => _BuslistStopState();
}

class _BuslistStopState extends State<BuslistStop> {
  String stopname = 'insert_stop_name_here';
  String busname = "bus name 1";
  String bustype = "Private";
  String busnumber = '0000';
  String details = 'Other details';
  String timehr = '00';
  String timemin = '00';

  List<Widget> routeWid = [];

  void createWid() {
    routeWid = [];
    for (BusRoute route in widget.args["routeList"]) {
      Stop stop = route.routeStops.firstWhere((element) => element.stopName == widget.args["stopName"]);
      routeWid.add(Container(
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
                    alignment: Alignment(-.75, -.60),
                    child: Text(
                      busname,
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
                    bustype + ', ' + busnumber,
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                )
              ],
            )),
          )));
    }
    print(routeWid);
    if (routeWid.isEmpty)
      {routeWid = [
        Container(
            height: 100,
            color: Color.fromRGBO(255, 171, 0, .9),
              child: Card(
                  child: Center(
                    child:Text("No routes exist",
                    style: TextStyle(fontSize: 20)
                  ),
                  ),
            ))  
      ];
      print("empty");
      }
  }

  @override
  void initState() {
    super.initState();
    createWid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.args["stopName"]),
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: routeWid,
          ),
        ));
  }
}
