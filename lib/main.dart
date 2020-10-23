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

  @override
  void initState() {
    super.initState();
    plaatsen = DatabaseHelper.instance.fetchPlaatsen();
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
                if (snapshot.hasError) {
                  return Text("Er is iets mis gegaan, herstart de app");
                }

                if (snapshot.hasData) {
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
                                  builder: (context) =>
                                      Zoekpagina(
                                        plaats: plaats,
                                      ),
                                ));
                          },
                        );
                      }).toList());
                }

                // no data, show spinner
                return Text("Bezig met laden...");
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
                              fontWeight: FontWeight.w200, fontSize: 19),
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

class OverOns extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Over Ons"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Wij, twee Utrechters, waren op zoek naar overzicht van de restaurants in de stad die afhaal of bezorgen aanbieden."
              "\n \nAangezien we hiervan geen overzicht hebben kunnen vinden hebben besloten deze app te ontwikkelen en daarmee een lijst te maken."
              "\n \nWe bieden deze app tegen kostprijs aan, daarom is er reclame aanwezig in de app."
              "\n \nWe bieden geen dienstverlening in de vorm van bezorgen of de mogelijkheid om de bestellen, die loopt allemaal via de horeca ondernemingen zelf.",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                  color: Colors.green[700]),
            ),
          ]),
        ));
  }
}

class Aanmelden extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Aanmelden"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Als u gebruik wil maken van de deze optie om uw restaurant ook onder de aandacht te brengen, "
              "dan willen we u vragen online de informatie van het restaurant aan ons beschikbaar te stellen. "
              "\n\nDeze informatie zullen wij vervolgens toevoegen aan de app. Als we een aantal restaurants hebben opgenomen in de app, "
              "zullen we beginnen met de promotie van de app onder consumenten."
              "\n\nOnze doelstelling is om deze app kostenneutraal aan te bieden aan de gebruikers en aan u als restauranthouder. "
              "Als er gegevens ontbreken of onjuist zijn in de app dan kunt u via info@eatin.nu contact met ons opnemen.",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                  color: Colors.green[700]),
            ),
          ]),
        ));
  }
}

class Privacy extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Aanmelden"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              "Gebruik van onze diensten"
              "\n\nWanneer jij je aanmeldt om te worden opgenomen in de app, vragen we je om persoonsgegevens te verstrekken."
              "Deze gegevens worden alleen gebruikt om de informatie in de app correct te houden en worden niet verstrekt aan derde partijen."
              "\n\nDeze gegevens worden gebruikt om de dienst uit te kunnen voeren. De gegevens worden opgeslagen op servers van een derde partij."
              "\n\n\nRegistratie gebruik app"
                  "\n\nWij leggen het gebruik van de app geannonimiseerd vast. Wij verzamelen deze gegevens voor onderzoek om zo inzicht te krijgen in het gebruik van de app.",
              style: GoogleFonts.getFont('Varela Round',
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                  color: Colors.green[700]),
            ),
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
