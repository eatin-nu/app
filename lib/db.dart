
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "package:path/path.dart" show join;
import "package:flutter/services.dart" show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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
  final int rdX;
  final int rdY;

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
      this.kanBezorgen,
      this.rdX,
      this.rdY
      });
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Keuken> fetchKeuken(int keukenId) async {
    assert(keukenId != null);

    Database db = await database;
    var resultatenVanDb = await db.query("kitchens", where: "id = $keukenId", limit: 1);
    var row = resultatenVanDb[0];
    var id = row["id"];
    var naam = row["name"];
    var iconBlob = row["blob_icon"];

    return Keuken(id: id, naam: naam, icon: iconBlob );
  }

  Future<Map<int,Keuken>> fetchKeukens() async {
    Database db = await database;
    var resultatenVanDb = await db.query("kitchens");
    Map<int, Keuken> keukens = Map();

    resultatenVanDb.forEach((row) {
      var id = row["id"];
      var naam = row["name"];
      var iconBlob = row["blob_icon"];

      var keuken = Keuken(id: id, naam: naam, icon: iconBlob );
      keukens[id] = keuken;
    });


    return keukens;
  }

  Future<List<Plaats>> fetchPlaatsen() async {
    Database db = await database;
    var resultatenVanDb = await db.query("places");

    List<Plaats> plaatsen = [];

    resultatenVanDb.forEach((element) {
      var id = element["id"];
      var naam = element["name"];
      Plaats plaats = Plaats(id: id, naam: naam);
      plaatsen.add(plaats);
    });

    return plaatsen;
  }

  // Filter op keukens, als filterKeuken != -1
  Future<List<Restaurant>> fetchRestaurants({Plaats plaats, int filterKeuken  = -1, bool filterOpKanBezorgen = false, bool filterOpKanOphalen = false}) async {
    Database db = await database;
    String extraWhereClause = "";

    if (filterKeuken != -1) {
      extraWhereClause += " and kitchen_id = ${filterKeuken}" ;
    }

    if (filterOpKanBezorgen) {
      extraWhereClause += " and can_deliver = 1" ;
    }

    if (filterOpKanOphalen) {
      extraWhereClause += " and can_pick_up = 1" ;
    }

    var resultatenVanDb =
        await db.query("restaurants", where: "place_id = ${plaats.id} ${extraWhereClause}");

    List<Restaurant> restaurants = [];

    resultatenVanDb.forEach((element) {
      var id = element["id"];
      var keukenId = element["kitchen_id"];
      var naam = element["name"];
      var pitch = element["pitch"];
      var website = element["website"];
      var telefoonnummer = ""; // TODO element["telefoonnummer"];
      var adres = element["full_address"];
      var email = element["email"];
      var postcode = element["postcode"];
      var bestelLink = element["order_link"];
      var derdenBestelLink = element["third_party_order_link"];
      var kanOphalen = element["can_pick_up"];
      var kanBezorgen = element["can_deliver"];
      var rdX = element["rd_x"];
      var rdY = element["rd_y"];
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
          kanOphalen: kanOphalen == 1,
          rdX: rdX,
          rdY: rdY,
      );
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
    var path = join(databasesPath, "eatin.db");

    Uint8List bytes;

    if (kReleaseMode) {
      String url = "http://eatin.nu/db/db.sqlite3";
      var response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Noooez, we kunnen de db niet downloaden :(");
      }
      bytes = response.bodyBytes;
    } else {
      ByteData data = await rootBundle.load(join('db', 'db.sqlite3'));
      bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }

    await new File(path).writeAsBytes(bytes);

    return await openDatabase(path);
  }
}
