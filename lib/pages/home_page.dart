import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'faculty_dashboard.dart';

class HomePage extends StatefulWidget {
  final bool isFaculty;

  const HomePage({Key? key, required this.isFaculty}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  Timer? trackingTimer;
  final NetworkInfo _info = NetworkInfo();

  final Map<String, String> bssidToRoom = {
    "44:d1:fa:77:ff:8e": "C-001",
    "44:d1:fa:77:fd:1a": "C-002",
    "30:de:4b:83:61:bb": "C-003",
    "44:d1:fa:77:e1:c3": "C-101",
    "44:d1:fa:77:e1:c4": "C-101",
    "9c:53:22:21:ce:56": "C-102",
    "9c:53:22:21:ce:3f": "C-103",
    "5c:62:8b:55:be:65": "C-304",
    "be:55:db:b1:5a:43": "Home",
  };

  @override
  void initState() {
    super.initState();
    requestPermissions();
    if (widget.isFaculty) {
      startWiFiTracking();
    }
  }

  @override
  void dispose() {
    trackingTimer?.cancel();
    super.dispose();
  }

  Future<void> requestPermissions() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print("✅ Location permission granted.");
    } else {
      print("❌ Location permission denied.");
    }
  }

  void startWiFiTracking() {
    trackingTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (user == null) {
        print("⚠ No user found.");
        return;
      }

      final bssid = await _info.getWifiBSSID();
      print("📡 Detected BSSID: ${bssid ?? 'No Wi-Fi connected'}");

      String? wifiRoom;
      bool isLoggedIn = false;

      if (bssid != null) {
        final lowerBssid = bssid.toLowerCase();
        if (bssidToRoom.containsKey(lowerBssid)) {
          wifiRoom = bssidToRoom[lowerBssid];
          if (wifiRoom != "Home") {
            isLoggedIn = true;
          }
        }
      }

      String? finalRoom;

      if (isLoggedIn) {
        // 🔥 If staff is online, use Wi-Fi detected room
        finalRoom = wifiRoom ?? 'Unknown';
      } else {
        // 🛠 If staff is offline, fetch room from Firestore timetable
        DocumentSnapshot<Map<String, dynamic>> staffDoc = await FirebaseFirestore.instance
            .collection('staff_details')
            .doc(user!.email)
            .get();

        if (staffDoc.exists) {
          final data = staffDoc.data();
          finalRoom = data?['room'] ?? 'Data Not Available';
        } else {
          finalRoom = 'Data Not Available';
        }
      }

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('staff_details')
          .doc(user!.email)
          .set({
        'room': finalRoom,
        'loggedIn': isLoggedIn,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ Firestore updated: room=$finalRoom, loggedIn=$isLoggedIn");
    });
  }

  @override
  Widget build(BuildContext context) {
    return FacultyDashboard();
  }
}