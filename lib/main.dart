import 'package:firebase_auth_project/pages/firebase_options.dart';
import 'package:firebase_auth_project/pages/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
  // Ensure the generated options file is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduPresence',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const WidgetTree(),  // WidgetTree as the main entry point
    );
  }
}
