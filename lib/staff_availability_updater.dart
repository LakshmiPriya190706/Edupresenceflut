import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'timetable_data.dart'; // Your timetable with room numbers

class StaffAvailabilityUpdater {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _timer;

  void startAutoUpdate() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      updateAllStaffAvailability();
    });

    // Immediate update once when app starts
    updateAllStaffAvailability();
  }

  void dispose() {
    _timer?.cancel();
  }

  Future<void> updateAllStaffAvailability() async {
    final now = DateTime.now();
    final day = DateFormat('EEEE').format(now);
    final time = TimeOfDay.now();
    final slot = _findCurrentSlot(time);

    staffTimetables.forEach((email, timetable) async {
      String status = "Free"; // Default status
      String? roomFromTimetable;

      if (slot != null && timetable[day]?.containsKey(slot) == true) {
        final slotData = timetable[day]![slot];
        status = slotData?["status"] ?? "Free";
        roomFromTimetable = slotData?["room"];
      }

      // Check if the staff is logged in (by checking if "room" field was updated recently)
      final docSnapshot = await _firestore.collection('staff_details').doc(email).get();
      bool isStaffLoggedIn = false;

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('last_updated')) {
          final lastUpdated = (data['last_updated'] as Timestamp).toDate();
          final difference = now.difference(lastUpdated);
          // Assume if last update was within last 2 minutes => staff is active (logged in)
          isStaffLoggedIn = difference.inMinutes <= 2;
        }
      }

      Map<String, dynamic> updateData = {
        'availability': status,
        'last_updated': DateTime.now(),
      };

      if (!isStaffLoggedIn) {
        // Only if staff not actively logged in, update room number from timetable
        updateData['room'] = roomFromTimetable?.trim() ?? "";


      }
      
      await _firestore.collection('staff_details').doc(email).set(updateData, SetOptions(merge: true));
    });
  }

  String? _findCurrentSlot(TimeOfDay time) {
    final minutes = time.hour * 60 + time.minute;

    if (minutes >= 480 && minutes < 530) return "8:00-8:50";
    if (minutes >= 560 && minutes < 610) return "9:20-10:10";
    if (minutes >= 610 && minutes < 660) return "10:10-11:00";
    if (minutes >= 660 && minutes < 710) return "11:00-11:50";
    if (minutes >= 770 && minutes < 820) return "12:40-1:30";
    if (minutes >= 820 && minutes < 865) return "1:30-2:15";
    if (minutes >= 865 && minutes < 2000) return "2:15-3:00";


    return null;
  }
}