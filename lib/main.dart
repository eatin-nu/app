import 'dart:async';
import 'package:flutter/material.dart';
import 'db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';
import 'package:google_fonts/google_fonts.dart';

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

  get fontSize => 48;

  @override
  void initState() {
    super.initState();
    plaatsen = DatabaseHelper.instance.fetchPlaatsen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w700, fontSize: 30),
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
              future: plaatsen,
              builder: (context, snapshot) {
                List<Plaats> plaatsen = snapshot.data;
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
  Zoekpagina({Key key, this.plaats}) : super(key: key);

  // @override
  _ZoekpaginaState createState() => _ZoekpaginaState();
}

class _ZoekpaginaState extends State<Zoekpagina> {
  Future<List<Restaurant>> restaurants;

  @override
  void initState() {
    super.initState();
    restaurants = DatabaseHelper.instance.fetchRestaurants(this.widget.plaats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurants in ${widget.plaats.naam}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder(
          future: this.restaurants,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Restaurant> restaurants = snapshot.data;

              var children = restaurants.map((e) {
                var keuken = DatabaseHelper.instance.fetchKeuken(e.keukenId);

                return FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetails(
                              restaurant: e,
                            ),
                          ));
                    },
                    child: Row(
                      children: [
                        FutureBuilder(
                          future: keuken,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Keuken keuken = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Image.memory(keuken.icon, height: 18),
                              );
                            } else if (snapshot.hasError) {
                              print(snapshot.error);
                              return Text("${snapshot.error}");
                            } else {
                              return Text(".");
                            }
                          },
                        ),
                        Text(
                          "${e.naam}",
                          style: GoogleFonts.getFont('Varela Round',
                              fontWeight: FontWeight.w200, fontSize: 18),
                        ),
                      ],
                    ));
              }).toList();

              return ListView(children: children);
            } else {
              return Text("Bezig met laden...");
            }
          },
        ),
      ),
    );
  }
}

class RestaurantDetails extends StatefulWidget {
  final Restaurant restaurant;

  @override
  RestaurantDetails({Key key, this.restaurant}) : super(key: key);

  @override
  _RestaurantState createState() => _RestaurantState();
}

class _RestaurantState extends State<RestaurantDetails> {
  @override
  Widget build(BuildContext context) {
    String adresUrl =
        "https://maps.google.com/?q=${Uri.encodeComponent(widget.restaurant.adres)}";

    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.restaurant.naam}"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "${widget.restaurant.pitch}",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w100,
                  fontSize: 20,
                  color: Colors.green[700]),
            ),
            SizedBox(height: 60),
            Text(
              "Contactgegevens",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w700, fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              "Telefoonummer: " "${widget.restaurant.telefoonummer}",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w400, fontSize: 16),
            ),
            SizedBox(height: 20),
            Link(
                tekst: "Website van ${widget.restaurant.naam}",
                url: widget.restaurant.website),
            SizedBox(height: 60),
            Text(
              "Bestellen",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w700, fontSize: 20),
            ),
            SizedBox(height: 20),
            Link(
                tekst: "Bestel hier via de website van het restaurant",
                url: widget.restaurant.bestelLink),
            SizedBox(height: 20),
            Link(
                tekst: "Bestel hier via derde partij",
                url: widget.restaurant.derdenBestelLink),
            SizedBox(height: 20),
            Link(tekst: "Bekijk op kaart", url: adresUrl),
          ]),
        ));
  }
}

class Link extends StatelessWidget {
  final String tekst;
  final String url;

  Link({Key key, this.tekst, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(tekst,
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          )),
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        }
      },
    );
  }
}
