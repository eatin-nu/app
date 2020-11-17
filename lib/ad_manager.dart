import 'package:firebase_admob/firebase_admob.dart';

Future<void> init_admob() {
  return FirebaseAdMob.instance.initialize(appId: "ca-app-pub-8551541803046868~9879621220");
}

