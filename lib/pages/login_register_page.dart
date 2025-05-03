import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth.dart';
import '../pages/home_page.dart'; // Make sure this import points to your actual HomePage file

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool isFaculty = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Navigate to HomePage with user role info
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(isFaculty: isFaculty)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );

      // Navigate to HomePage with user role info
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(isFaculty: isFaculty)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _title() {
    return const Text(
      'EduPresence',
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _write() {
    return const Text(
      'Hi, login here',
      style: TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
    );
  }

  Widget _image() {
    return Column(
      children: [
        Image.network(
          'https://media.istockphoto.com/id/1345875024/vector/searching-knowledge-concept.jpg?s=612x612&w=0&k=20&c=7RNNoMO5TE-YRZkafXXLXkqDTEgJ4mAvx7JcUrE73LI=',
          height: 80,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _entryField(String title, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Please enter a valid email and password!',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        color: Colors.red,
      ),
    );
  }

  Widget _roleToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Login as: "),
        Radio<bool>(
          value: true,
          groupValue: isFaculty,
          onChanged: (value) {
            setState(() {
              isFaculty = value!;
            });
          },
        ),
        const Text("Faculty"),
        Radio<bool>(
          value: false,
          groupValue: isFaculty,
          onChanged: (value) {
            setState(() {
              isFaculty = value!;
            });
          },
        ),
        const Text("Student"),
      ],
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        textStyle: const TextStyle(fontSize: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin
          ? (isFaculty ? 'Login as Faculty' : 'Login as Student')
          : 'Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: const Color.fromARGB(255, 129, 72, 153),
        foregroundColor: Colors.white,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTXqVBf4oEVl51n_p4pKOD7SgvR4G2U5cds6w&s',
              height: 50,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _write(),
              _image(),
              _entryField('Email', _controllerEmail),
              _entryField('Password', _controllerPassword),
              _roleToggle(),
              _errorMessage(),
              const SizedBox(height: 20),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }
}