import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth.dart'; // Make sure correct path
import 'home_page.dart';
import 'login_register_page.dart'; // Your login page

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // show loading
        } else if (snapshot.hasData) {
          // User is logged in
          return const HomePage(isFaculty: true); 
          // 🔥 Note: Here, you can't directly know `isFaculty` from FirebaseAuth.
          // We'll fix it soon if you want to.
        } else {
          // User not logged in
          return const LoginPage();
        }
      },
    );
  }
}
