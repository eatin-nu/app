
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "package:path/path.dart" show join;
import "package:flutter/services.dart" show rootBundle;
import 'package:http/http.dart' as http;

class Plaats {
  final int id;
  final String naam;

  Plaats({this.naam, this.id});
}

class Keuken {
  final int id;
  final String naam;
  final Uint8List icon;

  Keuken({this.id, this.naam, this.icon});
}

class Restaurant {
  final int id;
  final String naam;
  final int keukenId;
  final String pitch;
  final String website;
  final String telefoonummer;
  final String adres;
  final String email;
  final String postcode;
  final String bestelLink;
  final String derdenBestelLink;
  final bool kanOphalen;
  final bool kanBezorgen;

  Restaurant(
      {this.id,
      this.naam,
      this.keukenId,
      this.pitch,
      this.website,
      this.telefoonummer,
      this.adres,
      this.email,
      this.postcode,
      this.bestelLink,
      this.derdenBestelLink,
      this.kanOphalen,
      this.kanBezorgen});
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Keuken> fetchKeuken(int keukenId) async {
    assert(keukenId != null);

    Database db = await database;
    var resultatenVanDb = await db.query("keuken", where: "id = $keukenId", limit: 1);
    //print("Gevonden keukens: ${resultaten_van_db} voor id: $keukenId");
    var row = resultatenVanDb[0];
    var id = row["id"];
    var naam = row["naam"];
    var iconBlob = row["icon"];

    return Keuken(id: id, naam: naam, icon: iconBlob );
  }

  Future<List<Plaats>> fetchPlaatsen() async {
    Database db = await database;
    var resultatenVanDb = await db.query("plaats");

    List<Plaats> plaatsen = [];

    resultatenVanDb.forEach((element) {
      var id = element["id"];
      var naam = element["naam"];
      Plaats plaats = Plaats(id: id, naam: naam);
      plaatsen.add(plaats);
    });

    return plaatsen;
  }

  Future<List<Restaurant>> fetchRestaurants(Plaats plaats) async {
    Database db = await database;
    var resultatenVanDb =
        await db.query("restaurant", where: "plaats_id = ${plaats.id}");

    List<Restaurant> restaurants = [];

    resultatenVanDb.forEach((element) {
      var id = element["id"];
      var keukenId = element["keuken_id"];
      var naam = element["naam"];
      var pitch = element["pitch"];
      var website = element["website"];
      var telefoonnummer = element["telefoonnummer"];
      var adres = element["adres"];
      var email = element["email"];
      var postcode = element["postcode"];
      var bestelLink = element["bestel_link"];
      var derdenBestelLink = element["derden_bestel_link"];
      var kanOphalen = element["kan_ophalen"];
      var kanBezorgen = element["kan_bezorgen"];

      Restaurant restaurant = Restaurant(id: id,
          naam: naam,
          keukenId: keukenId,
          pitch: pitch,
          website: website,
          telefoonummer: telefoonnummer,
          adres: adres,
          email: email,
          postcode: postcode,
          bestelLink: bestelLink,
          derdenBestelLink: derdenBestelLink,
          kanBezorgen: kanBezorgen == 1,
          kanOphalen: kanOphalen == 1);
      restaurants.add(restaurant);
    });

    return restaurants;
  }

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "demo_asset_example.db");

    String url = "http://eatin.nu/db/db.sqlite3";
    var response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("Noooez, we kunnen de db niet downloaden :(");
    }
    var bytes = response.bodyBytes;
    await new File(path).writeAsBytes(bytes);

    return await openDatabase(path);
  }
}
