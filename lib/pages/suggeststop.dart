import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  MapPickerPage({Key key}) : super(key: key);

  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _initialposition, _markerposition;
  CameraPosition _position;

  Future<String> getLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _initialposition = LatLng(position.latitude, position.longitude);
    _position = CameraPosition(target: _initialposition, zoom: 20);
    return "Success";
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildGoogleMap(BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition:
                CameraPosition(target: _initialposition, zoom: 17),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onCameraMove: (position) {
              setState(() {
                _position = position;
              });
            }),
      );
    }

    Future<String> _asyncInputDialog() async {
      String stopname = '';
      return showDialog<String>(
        context: context,
        barrierDismissible:
            false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Bus Stop name'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Bus stop', hintText: 'eg. REC Bus stop'),
                  onChanged: (value) {
                    stopname = value;
                  },
                ))
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop(stopname);
                },
              ),
            ],
          );
        },
      );
    }

    return FutureBuilder<String>(
        future: getLocation(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Suggest a Stop'),
                backgroundColor: Color.fromRGBO(255, 171, 0, .9),
              ),
              body: Stack(children: <Widget>[
                _buildGoogleMap(context),
                Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.add_location,
                    size: 40.0,
                    color: Color.fromRGBO(255, 171, 0, .9),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: RaisedButton(
                          onPressed: () async {
                            print(_position.target.toString());
                            String text = await _asyncInputDialog();
                            print(text);
                            // final FirebaseAuth auth = FirebaseAuth.instance;
                            // await auth.signInWithEmailAndPassword(
                            //     email: "admin@anandu.net",
                            //     password: "password");
                            final HttpsCallable callable = CloudFunctions
                                .instance
                                .getHttpsCallable(functionName: "requestStop");
                                print(_position.target);
                            HttpsCallableResult response =
                                await callable.call(<String, dynamic>{
                              "name": text,
                              "coordinates": [
                                _position.target.latitude,
                                _position.target.longitude
                              ]
                            }).catchError((e)=>print(e));
                            print(response.data);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          color: Color.fromRGBO(255, 171, 0, .9),
                          child: Container(
                              height: 50,
                              width: 100,
                              child: Center(
                                child: Text(
                                  'Suggest Stop',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                              )),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        )))
              ]),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
