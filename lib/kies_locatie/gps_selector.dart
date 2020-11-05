import 'dart:ffi';

import 'package:eatin/kies_locatie/address_selector.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class GpsSelector extends StatefulWidget {
  @override
  _GpsSelectorState createState() => _GpsSelectorState();
}

class _GpsSelectorState extends State<GpsSelector> {
  Future<Position> position;

  Future<Position> _findLocation() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final params = <String,String>{ "q": "lat=hh"};
    var uri = Uri.https("geodata.nationaalgeoregister.nl","/locatieserver/v3/suggest", params);

    return pos;
  }

  initState() {
    super.initState();
    this.position = _findLocation();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("GPS locatie"),),
      body: FutureBuilder(
        future: this.position,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Position pos = snapshot.data;
            return PickCloseGPSOption(position: pos);
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return  Row(
              children: [
                Text("Dat ging helaas niet goed :("),
                ButtonBar(children: [
                  FlatButton(onPressed: () {}, child: Text("Probeer het nog een keer!")),
                  FlatButton(onPressed: () {}, child: Text("Ga terug.")),
                ],)
              ],
            );
          } else {
            return Text("Bezig met zoeken...");
          }
        },
      )
    );
  }
}

class PickCloseGPSOption extends StatefulWidget {
  @override
  _PickCloseGPSOptionState createState() => _PickCloseGPSOptionState();

  Position position;

  PickCloseGPSOption({Key key, this.position}): super(key: key);
}

class _PickCloseGPSOptionState extends State<PickCloseGPSOption> {

  Future<List<SelectedAddress>> closeAddresses;

  @override
  void initState() {
    this.closeAddresses = this._fetchCloseAddresses();
    super.initState();
  }

  Future<List<SelectedAddress>> _fetchCloseAddresses() async {
    final String lat =this.widget.position.latitude.toString() ;
    final String lon = this.widget.position.longitude.toString();
    final params = <String,String>{ "lat": lat, "lon": lon};
    var uri = Uri.https("geodata.nationaalgeoregister.nl","/locatieserver/revgeo", params);
    final response = await http.get(uri);
    List<dynamic> rawOptions = jsonDecode(response.body)["response"]["docs"];

    List<SelectedAddress> foundCloseAddresses = List();

    rawOptions.forEach((rawOption) {
      foundCloseAddresses.add(SelectedAddress(weergavenaam: rawOption["weergavenaam"], id: rawOption["id"]));
    });

    return foundCloseAddresses;
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.closeAddresses,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<SelectedAddress> options = snapshot.data;
          return Text("Found");
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Text("Nope");
        } else {
          return Text(
              "Looking for addresses close to ${this.widget.position.latitude}: ${this.widget.position
                  .longitude}");
        }
    },);
  }
}
