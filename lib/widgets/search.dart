
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pinmybus/models/stops.dart';
class Stopsearch extends SearchDelegate<Stop> {
  List<Stop> stops = [
  ];
  Stopsearch(this.stops);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Stop("", "", LatLng(0, 0)));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (stops == null) return Center(child: Text("Bus stop not found!"));
    final results =
        stops.where((element) => element.stopName.toLowerCase().contains(query));
    return ListView(
      children: results
          .map<ListTile>((e) => ListTile(
                title: Text(e.stopName),
                onTap: () => close(context, e),
              ))
          .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results =
        stops.where((element) => element.stopName.toLowerCase().contains(query));
    if (results.toList() == []) return ListTile(title: Text("Bus stop not found!"));
    return ListView(
      children: results
          .map<ListTile>((e) => ListTile(
                title: Text(e.stopName),
                onTap: () => close(context, e),
              ))
          .toList(),
    );
  }
}
