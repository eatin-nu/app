import 'dart:async';
import 'dart:ffi';
import 'package:eatin/kies_locatie/gps_selector.dart';
import 'package:flutter/material.dart';
import 'db.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:core';
import 'package:google_fonts/google_fonts.dart';
import 'zoekpagina.dart';
import 'kies_locatie/address_selector.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
    throw error;
  });
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eatin',
      navigatorObservers: [observer],
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
          textTheme:
              GoogleFonts.varelaRoundTextTheme(Theme.of(context).textTheme)),
      home: MyHomePage(title: 'EatIn', observer: observer),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.observer}) : super(key: key);

  final String title;
  final FirebaseAnalyticsObserver observer;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Plaats>> plaatsen;
  Future<Map<int, Keuken>> keukens;

  SelectedAddress _address = null;

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
                this
                    .widget
                    .observer
                    .analytics
                    .logEvent(name: "bekijk_over_ons");
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
                this
                    .widget
                    .observer
                    .analytics
                    .logEvent(name: "bekijk_aanmelden");
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
                this
                    .widget
                    .observer
                    .analytics
                    .logEvent(name: "bekijk_privacy_statement");
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
      body:
      // Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Column(
      //       children: [
      //         Text("Hoi,\n\n We hebben je locatie nodig om te zien welke restaurants er in de buurt zijn"),
      //         Row(
      //           children: [
      //             Expanded(
      //               child: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: AddressSelector(
      //                   onAddressSelected: (address) {
      //                     this.setState(() {
      //                       this._address = address;
      //                     });
      //                   },
      //                 ),
      //               ),
      //             )
      //           ],
      //         ),
      //         ElevatedButton(
      //           onPressed: this._address == null ? null : () {
      //             print("Ajeto");
      //           },
      //           child: Text("Kies!"),
      //         ),
      //         Divider(),
      //         Text("Of gebruik je GPS locatie"),
      //         ElevatedButton(onPressed: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => GpsSelector(),
      //               ));
      //         },
      //         child: Text("Gebruik mijn locatie"))
      //       ],
      //     ),
      //   ),
      // ),
      Center(
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
                                            observer: this.widget.observer,
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
            FlatButton(onPressed: () => {

            }, child: Text("Of deel je GPS locatie"),
            ),
          ],
        ),
      ),
    );
  }
}
