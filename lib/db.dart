import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import "package:path/path.dart" show join;
import "package:flutter/src/services/asset_bundle.dart" show rootBundle;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

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
