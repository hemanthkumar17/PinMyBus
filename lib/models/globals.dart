import 'package:flutter/material.dart';
import 'stops.dart';

const URL = "https://us-central1-pinmybus-staging.cloudfunctions.net";
List<Stop> stopsComplete;

class GlobalFunctions {
  static void printError(String error, GlobalKey<ScaffoldState> key) {
    key.currentState.showSnackBar(SnackBar(content: Text(error)));
  }
}
