import 'package:flutter/material.dart';

class BuslistRoute extends StatefulWidget {
  BuslistRoute({Key key}) : super(key: key);

  @override
  _BuslistRouteState createState() => _BuslistRouteState();
}

class _BuslistRouteState extends State<BuslistRoute> {
  @override
  String stopname = 'insert_stop_name_here';
  String busname = "bus name 1";
  String bustype = "Private";
  String busnumber = '0000';
  String details = 'Other details';
  String deptimehr = '00';
  String deptimemin = '00';
  String arrtimehr = '00';
  String arrtimemin = '00';
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Routes'),
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
                            alignment: Alignment(.30, -.50),
                            child: Text(
                              "Departure :",
                              style: TextStyle(fontSize: 10),
                            )),
                        Align(
                            alignment: Alignment(.75, -.60),
                            child: Text(
                              deptimehr + ':' + deptimemin,
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
                              arrtimehr + ':' + arrtimemin,
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
            ],
          ),
        ));
  }
}
