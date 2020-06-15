import 'package:flutter/material.dart';
import 'package:pinmybus/models/routes.dart';

class BuslistStop extends StatefulWidget {
  final List<BusRoute> routeList;
  BuslistStop(this.routeList, {Key key}) : super(key: key);

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
    for (var route in widget.routeList) {
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
                      timehr + ':' + timemin,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(stopname),
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
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
                            alignment: Alignment(-.75, -.60),
                            child: Text(
                              busname,
                              style: TextStyle(fontSize: 25),
                            )),
                        Align(
                            alignment: Alignment(.75, -.60),
                            child: Text(
                              timehr + ':' + timemin,
                              style: TextStyle(fontSize: 25),
                            )),
                        Align(
                          alignment: Alignment(-.75, .50),
                          child: Text(
                            bustype + ', ' + busnumber,
                            style:
                                TextStyle(fontSize: 15, color: Colors.black45),
                          ),
                        )
                      ],
                    )),
                  ))
            ] + routeWid,
          ),
        ));
  }
}
