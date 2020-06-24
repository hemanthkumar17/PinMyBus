import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/models/stops.dart';
import 'package:pinmybus/models/userData.dart';
import 'package:pinmybus/widgets/search.dart';
import 'package:http/http.dart' as http;

class SearchRoutePage extends StatefulWidget {
  SearchRoutePage({Key key}) : super(key: key);

  @override
  _SearchRoutePageState createState() => _SearchRoutePageState();
}

class _SearchRoutePageState extends State<SearchRoutePage> {
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
          title: Text('Search for your Route'),
        ),
        body: Center(
          child: SingleChildScrollView(
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
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        InkWell(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                side:
                                    BorderSide(color: Colors.white70, width: 1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              color: Colors.white,
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
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
                                    startCancel
                                  ]),
                            ),
                            onTap: () {
                              searchStop(context, true);
                            }),
                        InkWell(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      height: 50,
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
                                    destCancel
                                  ]),
                            ),
                            onTap: () {
                              searchStop(context, false);
                            }),
                        SizedBox(
                          height: 10,
                        ),
                        Theme(
                            data: Theme.of(context)
                                .copyWith(primaryColor: Colors.orange),
                            child: Builder(
                                builder: (context) => RaisedButton(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Container(
                                          height: 50,
                                          width: 300,
                                          child: Center(
                                              child: Text(
                                            "Select Date",
                                            style: TextStyle(fontSize: 10),
                                          ))),
                                      onPressed: () async {
                                        final DateTime picked =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: selectedDate,
                                                firstDate: DateTime(2015, 8),
                                                lastDate: DateTime(2101));
                                        if (picked != null &&
                                            picked != selectedDate)
                                          setState(() {
                                            selectedDate = picked;
                                          });
                                      },
                                    ))),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Container(
                                height: 50,
                                width: 300,
                                child: Center(
                                    child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.black),
                                ))),
                            onPressed: () async {
                              Map<String, dynamic> data = {
                                "startStop": stopsComplete
                                    .firstWhere(
                                        (element) => element.stopName == start)
                                    .stopid,
                                "endStop": stopsComplete
                                    .firstWhere(
                                        (element) => element.stopName == start)
                                    .stopid,
                                "date":
                                    "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year.toString()}"
                              };
                              print(data);
                              final HttpsCallable callable =
                                  CloudFunctions.instance.getHttpsCallable(
                                      functionName: "searchRoutes");
                              final HttpsCallableResult response =
                                  await callable.call(data);
                              List<BusRoute> routeList = [];
                              List<Data> userData = [];
                              print(response.data);
                              for (var route in response.data) {
                                routeList.add(BusRoute.fromResponse(route));
                                userData.add(Data(route['name']));
                              }

                              Navigator.pushNamed(context, '/buslist_route',
                                  arguments: {
                                    "routeList": routeList,
                                    "userData": userData
                                  });
                            }),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    child: RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/map');
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
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.white70, width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Color.fromRGBO(255, 171, 0, .9),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
