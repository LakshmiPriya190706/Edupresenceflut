import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_register_page.dart'; // your existing login page

class FacultyDashboard extends StatefulWidget {
  @override
  _FacultyDashboardState createState() => _FacultyDashboardState();
}

class _FacultyDashboardState extends State<FacultyDashboard> {
  String searchQuery = '';
  bool isAscending = true;
  late Stream<QuerySnapshot> facultyStream;

  Color primaryColor = Color.fromARGB(255, 129, 72, 153); // Deep purple
  Color cardColor = Color(0xFFF3E5F5);    // Light background
  Color buttonColor = Color(0xFF6A1B9A);  // Darker purple

  @override
  void initState() {
    super.initState();
    facultyStream = getFacultyStream();
  }

  Stream<QuerySnapshot> getFacultyStream() {
    return FirebaseFirestore.instance.collection('staff_details').snapshots();
  }

  Future<void> refreshFacultyData() async {
    setState(() {
      facultyStream = getFacultyStream();
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search Faculty...',
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: buttonColor),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value.toLowerCase();
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: refreshFacultyData,
                        icon: Icon(Icons.refresh, color: Colors.white),
                        tooltip: 'Refresh',
                      ),
                      IconButton(
                        onPressed: logout,
                        icon: Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Sort Dropdown
            Padding(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sort: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  DropdownButton<bool>(
                    dropdownColor: Colors.white,
                    value: isAscending,
                    items: [
                      DropdownMenuItem(value: true, child: Text('A - Z')),
                      DropdownMenuItem(value: false, child: Text('Z - A')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        isAscending = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Faculty List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: facultyStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: primaryColor));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No faculty found'));
                  }

                  var facultyList = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  facultyList.sort((a, b) {
                    final nameA = (a.data() as Map<String, dynamic>)['name'] ?? '';
                    final nameB = (b.data() as Map<String, dynamic>)['name'] ?? '';
                    return isAscending
                        ? nameA.compareTo(nameB)
                        : nameB.compareTo(nameA);
                  });

                  return RefreshIndicator(
                    onRefresh: refreshFacultyData,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      itemCount: facultyList.length,
                      itemBuilder: (context, index) {
                        final data = facultyList[index].data() as Map<String, dynamic>;

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: buttonColor.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurpleAccent.withOpacity(0.2),
                                blurRadius: 8,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              data['name'] ?? 'Unnamed',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: buttonColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.apartment, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Department: ${data['department']?.toString().trim() ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.room, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Room No: ${data['room']?.toString().trim().isEmpty ?? true ? 'N/A' : data['room'].toString().trim()}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 18, color: Colors.grey[700]),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Availability: ${data['availability']?.toString().trim() ?? 'N/A'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),


                            isThreeLine: true,
                          ),

                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}