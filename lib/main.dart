import 'dart:async';
import 'package:flutter/material.dart';
import 'db.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'EatIn'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Plaats>> plaatsen;

  @override
  void initState() {
    super.initState();
    Future<Database> db = DatabaseHelper.instance.database;
    plaatsen = DatabaseHelper.instance.fetchPlaatsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Kies jouw stad',
            ),
            FutureBuilder(
              future: plaatsen,
              builder: (context, snapshot) {
                List<Plaats> plaatsen = snapshot.data;
                return Column(
                    children: plaatsen.map((plaats) {
                  return FlatButton(
                    child: Text("De plaats ${plaats.id} '${plaats.naam}'"),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Zoekpagina(
                              plaats: plaats,
                            ),
                          ));
                    },
                  );
                }).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Zoekpagina extends StatefulWidget {
  final Plaats plaats;

  @override
  Zoekpagina({Key Key, this.plaats}) : super(key: key);

  // @override
  _ZoekpaginaState createState() => _ZoekpaginaState();
}

class _ZoekpaginaState extends State<Zoekpagina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Restaurants in ${widget.plaats.naam}"),
        ),
        body: Center(
          child: Text("De Stad ${widget.plaats.naam}"),
        ));
  }
}
