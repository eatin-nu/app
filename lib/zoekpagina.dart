import 'dart:async';
import 'package:flutter/material.dart';
import 'db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';
import 'package:google_fonts/google_fonts.dart';

class Zoekpagina extends StatefulWidget {
  final Plaats plaats;
  final Map<int, Keuken> keukens;

  @override
  Zoekpagina({Key key, this.plaats, this.keukens}) : super(key: key);

  // @override
  _ZoekpaginaState createState() => _ZoekpaginaState();
}

class _ZoekpaginaState extends State<Zoekpagina> {
  Future<List<Restaurant>> restaurants;
  int keukenFilter = -1;

  @override
  void initState() {
    super.initState();
    restaurants = DatabaseHelper.instance.fetchRestaurants(plaats: this.widget.plaats);
  }

  void pasFilterToe(int filterOp) {
    keukenFilter = filterOp;
    restaurants = DatabaseHelper.instance.fetchRestaurants(plaats: this.widget.plaats, filterKeuken: filterOp);
  }

  @override
  Widget build(BuildContext context) {
    List<Keuken> keukens = this.widget.keukens.values.toList();
    keukens.sort((a,b) => a.naam.compareTo(b.naam));
    keukens.insert(0, Keuken(id: -1, naam: "Alle keukens"));

    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurants in ${widget.plaats.naam}"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DropdownButton<int>(
            value: keukenFilter,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (int newValue) {
              setState(() {
                pasFilterToe(newValue);
              });
            },
            items: keukens.map<DropdownMenuItem<int>>((Keuken value) {
              return DropdownMenuItem<int>(
                value: value.id,
                child: Row(children:[
                  //Image.memory(value.icon, height: 18),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${value.naam}"),
                  ), ]),
              );
            }).toList(),
          ),
          Expanded(
            child: FutureBuilder(
              future: this.restaurants,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("Oeps, er is iets mis gegaan!");
                }
                if (snapshot.hasData) {
                  List<Restaurant> restaurants = snapshot.data;

                  var children = restaurants.map((e) {
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
                            Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Image.memory(this.widget.keukens[e.keukenId].icon, height: 18),
                            ),
                            Text(
                              "${e.naam}",
                              style: GoogleFonts.getFont('Varela Round',
                                  fontWeight: FontWeight.w200, fontSize: 19),
                            ),
                          ],
                        ));
                  }).toList();

                  if (children.length > 0) {
                    return ListView(children: children);
                  } else {
                    return Text("Geen resultaten gevonden");
                  }
                } else {
                  return Text("Bezig met laden...");
                }
              },
            ),
          ),
        ],
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