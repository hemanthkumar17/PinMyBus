import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/institute.dart';
import 'stops.dart';
import 'package:pinmybus/utils/reminder.dart';

const URL = "https://us-central1-pinmybus-staging.cloudfunctions.net";
List<Stop> stopsComplete;

abstract class GlobalFunctions {
  static List<Institute> institutes;
  static LatLng _location;
  static void printError(String error, GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(content: Text(error)));
  }

  static Future<void> getStops() async {
    // FirebaseAuth _auth = FirebaseAuth.instance;
    // await _auth.signInWithEmailAndPassword(email: "admin@anandu.net", password: "password");
    final HttpsCallable callable =
        CloudFunctions.instance.getHttpsCallable(functionName: "listStops");
    HttpsCallableResult response = await callable.call({});
    print(response.data);
    stopsComplete = [];
    for (var item in response.data['stops']) {
      stopsComplete.add(Stop(
          item['name'],
          item["_id"],
          LatLng(double.parse(item['location']['coordinates'][0].toString()),
              double.parse(item['location']['coordinates'][1].toString()))));
    }
    getInstitutes();
    print(stopsComplete);
    // print(stops);
  }

  static Future<List<Institute>> getInstitutes() async {
    if (institutes != null) {
      final HttpsCallable callable = CloudFunctions.instance
          .getHttpsCallable(functionName: "listInstitutes");
      HttpsCallableResult response = await callable.call();
      print(response.data);

      institutes = [];
      for (var json in response.data) {
        institutes.add(Institute.fromJson(json));
      }
    }
    return institutes;
  }

  static LatLng getLocation() => _location;
}
