import 'dart:async';
import 'package:flutter/material.dart';
import 'db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';
import 'package:google_fonts/google_fonts.dart';
import 'zoekpagina.dart';

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
        textTheme: GoogleFonts.varelaRoundTextTheme(Theme.of(context).textTheme)
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
  Future<Map<int, Keuken>> keukens;

  @override
  void initState() {
    super.initState();
    plaatsen = DatabaseHelper.instance.fetchPlaatsen();
    keukens = DatabaseHelper.instance.fetchKeukens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('EatIn menu'),
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
            ),
            ListTile(
              title: Text('Over ons'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OverOns(),
                    ));
              },
            ),
            ListTile(
              title: Text('Aanmelden'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Aanmelden(),
                    ));
              },
            ),
            ListTile(
              title: Text('Privacy Statement'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Privacy(),
                    ));
                },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          title: Image(
        image: AssetImage('assets/Logo.png'),
        height: 50,
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              '',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30 ),
            ),
            Text(
              'Kies jouw stad:',
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w700, fontSize: 30),
            ),
            Text(
              '',
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w700, fontSize: 30),
            ),
            FutureBuilder(
              future: keukens,
              builder: (context, keukens_snapshot) {
                return FutureBuilder(
                  future: plaatsen,
                  builder: (context, snapshot) {
                    if (snapshot.hasError || keukens_snapshot.hasError) {
                      print("snapshot error: ${snapshot.error}");
                      print("keukens error: ${keukens_snapshot.error}");
                      return Text("Er is iets mis gegaan, herstart de app");
                    }

                    if (snapshot.hasData && keukens_snapshot.hasData) {
                      List<Plaats> plaatsen = snapshot.data;
                      Map<int, Keuken> keukens = keukens_snapshot.data;
                      return Column(
                          children: plaatsen.map((plaats) {
                            return FlatButton(
                              child: Text("${plaats.naam}",
                                  style: GoogleFonts.getFont('Varela Round',
                                      fontWeight: FontWeight.w700, fontSize: 40)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Zoekpagina(
                                            plaats: plaats,
                                            keukens: keukens,
                                          ),
                                    ));
                              },
                            );
                          }).toList());
                    }

                    // no data, show spinner
                    return Text("Bezig met laden...");
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

