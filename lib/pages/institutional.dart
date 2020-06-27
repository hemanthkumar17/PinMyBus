import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:pinmybus/models/globals.dart';
import 'package:pinmybus/models/institute.dart';
import 'package:pinmybus/models/routes.dart';
import 'package:pinmybus/widgets/search.dart';

class InstitutePage extends StatefulWidget {
  InstitutePage({Key key}) : super(key: key);

  @override
  _InstitutePageState createState() => _InstitutePageState();
}

class _InstitutePageState extends State<InstitutePage> {
  String text = "Institute name";
  Widget cancelInstitute = Container();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _licensenoController = TextEditingController();

  Future<List<BusRoute>> _getInstituteRoutes() async {
    Institute selected = GlobalFunctions.institutes
        .firstWhere((element) => element.name == text);
    Map<String, dynamic> dataJson = {
      "code": _licensenoController.text,
      "institute": {
        "instituteId": selected.id,
        "searchKey": _codeController.text
      }
    };
    final HttpsCallable callable =
        CloudFunctions.instance.getHttpsCallable(functionName: "byCodeRoutes");
    HttpsCallableResult response = await callable.call(dataJson);

    List<BusRoute> routeList = [];
    for (var route in response.data) {
      routeList.add(BusRoute.fromResponse(route));
    }
    return routeList;
  }

  Future<void> searchStop(BuildContext context) async {
    var res = await showSearch(context: context, delegate: Institutesearch());
    setState(() {
      text = res.name;
      if (res.name != "Institute name")
        cancelInstitute = IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                text = "Institute name";
                cancelInstitute = Container();
              });
            });
      else
        cancelInstitute = Container();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget completePage = Center(
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 350,
                child: InkWell(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white70, width: 1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      color: Colors.white,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                height: 50,
                                child: Row(children: <Widget>[
                                  Padding(padding: EdgeInsets.only(left: 10)),
                                  Icon(Icons.search),
                                  Padding(padding: EdgeInsets.only(left: 20)),
                                  Text(text,
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black,
                                      )),
                                ])),
                            cancelInstitute
                          ]),
                    ),
                    onTap: () {
                      searchStop(context);
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Institute Code",
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(),
                    ),
                    // fillColor: Colors.green
                  ),
                  controller: _codeController,
                  validator: (val) {
                    if (val.length == 0) {
                      return "Code cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                child: TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Bus License Plate Number",
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(),
                    ),
                    // fillColor: Colors.green
                  ),
                  controller: _licensenoController,
                  validator: (val) {
                    if (val.length == 0) {
                      return "License Number cannot be empty";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                onPressed: () async {
                  List<BusRoute> routeList = await _getInstituteRoutes();
                  Map args = {"routeList": routeList};
                  Navigator.pushReplacementNamed(context, '/buslist_route',
                      arguments: args);
                },
                color: Color.fromRGBO(255, 171, 0, .9),
                child: Container(
                    height: 50,
                    width: 100,
                    child: Center(
                      child: Text(
                        'Search',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    )),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              SizedBox(
                height: 10,
              )
            ],
          )
        ])));
    if (GlobalFunctions.institutes != null)
      return Scaffold(appBar: AppBar(), body: completePage);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(255, 171, 0, .9),
        ),
        body: completePage);
  }
}
