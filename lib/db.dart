import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "package:path/path.dart" show join;
import "package:flutter/src/services/asset_bundle.dart" show rootBundle;
import 'package:path_provider/path_provider.dart';

class Plaats {
  int id;
  String naam;

  Plaats({naam: String, id: int}) {
    this.naam = naam;
    this.id = id;
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<List<Plaats>> fetchPlaatsen() async {
    Database db = await database;
    var resultaten_van_db = await db.query("plaats");

    List<Plaats> plaatsen = [];

    resultaten_van_db.forEach((element) {
      var id = element["id"];
      var naam  = element["naam"];
      Plaats plaats = Plaats(id:id, naam: naam);
      plaatsen.add(plaats);
    });

    return plaatsen;
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

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy
      ByteData data = await rootBundle.load(join('db', 'db.sqlite3'));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await new File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path);
  }
}
