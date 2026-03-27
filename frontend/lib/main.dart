import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'firebase_options.dart';

bool isFirebaseConfigured = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    isFirebaseConfigured = true;
  } catch (_) {
    // Allow app to run for UI development before FlutterFire is configured.
    isFirebaseConfigured = false;
  }
  runApp(const SnailTaxiApp());
}
