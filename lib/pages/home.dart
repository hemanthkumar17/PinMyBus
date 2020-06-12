import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:pinmybus/widgets/search.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String start = "Start from ...";
  String dest = "Ends at ...";
  Duration tripTime;
  Widget startCancel = Container(), destCancel = Container();
  TimeOfDay starttime = TimeOfDay.now();
  String starthr = "", startmin = "";
  List<String> droplist = [];

  Future<void> _getStartTime() async {
    TimeOfDay time = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (time != null)
      setState(() {
        starttime = time;
      });
  }

  Future<void> addRoute() async {
    var response = await http.post('$URL/addRoute',
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "Name": "Test_1 ",
          "RecMode": "Daily",
          "RecList": [0],
          "TimeOfStart": 25,
          "Path": [start, dest],
          "Offsets": [0, 75],
          "Owner": "Owner_1",
          "Ref": "firebasereference1",
        }));
    print(response.body);
  }

  List<Stop> stops = [];

  Future<void> searchStop(context, bool entry) async {
    var res = await showSearch(
      context: context,
      delegate: Stopsearch(stopsComplete),
    );
    setState(() {
      if (entry == true) {
        if (res == null || res.stopName == '')
          start = "Start from ...";
        else
          start = res.stopName;
      } else {
        if (res == null || res.stopName == '')
          dest = "Ends at ...";
        else
          dest = res.stopName;
      }
      destCancel = Container();
    });
  }

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _showMultiSelect(BuildContext context) async {
    await _selectDate(context);
    // widget.dropList([selectedDate.day.toString()]);
  }

  void getvaluefromkey(Set selection) {
    if (selection != null) {
      droplist = [];
      for (int x in selection.toList()) {
        droplist.add("$x");
        // widget.dropList(droplist);
      }
      // print(widget.dropList);
      // print(widget.recMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
          title: Text('Home'),
        ),
        drawer: Drawer(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvatarGlow(
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
                            ))),
              Container(
                width: 400,
                child: Card(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Color.fromRGBO(255, 171, 0, .9),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            color: Colors.white,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  InkWell(
                                      child: Container(
                                          height: 50,
                                          child: Row(children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10)),
                                            Icon(Icons.search),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 20)),
                                            Text(start,
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.black,
                                                )),
                                          ])),
                                      onTap: () {
                                        searchStop(context, true);
                                      }),
                                  startCancel
                                ]),
                          ),
                          onTap: () {
                            searchStop(context, true);
                          }),
                      InkWell(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white70, width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            color: Colors.white,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    height: 50,
                                    child: InkWell(
                                      onTap: () {
                                        searchStop(context, false);
                                      },
                                      child: Row(children: <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(left: 10)),
                                        Icon(Icons.search),
                                        Padding(
                                            padding: EdgeInsets.only(left: 20)),
                                        Text(dest,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.black,
                                            )),
                                      ]),
                                    ),
                                  ),
                                  destCancel
                                ]),
                          ),
                          onTap: () {
                            searchStop(context, true);
                          }),
                      RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                            height: 50,
                            width: 300,
                            child: Center(
                                child: Text(
                              "Select Date",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black),
                            ))),
                        onPressed: () => _showMultiSelect(context),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                  child: RaisedButton(
                onPressed: () {
                  // Navigator.pushNamed(context, '/stopmap');
                },
                color: Color.fromRGBO(255, 171, 0, .9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                    height: 50,
                    width: 100,
                    child: Center(
                        child: Text(
                      "Go to Maps",
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ))),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
