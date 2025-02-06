import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/auth_service.dart';

class Recover extends StatefulWidget {
  const Recover({super.key});

  @override
  State<Recover> createState() => _RecoverState();
}

class _RecoverState extends State<Recover> {

  final TextEditingController _email = TextEditingController();
  bool _isEmailValid = true;

  bool isEmailValid() {
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(_email.text);
  }

  final Auth _auth = Auth();

  void recoverPassword() async {
    try {
      await _auth.recoverPassword(_email.text);
    }on FirebaseAuthException catch (e) {
      print(e);
    }
  }


  void recover() {
    setState(() {
      _isEmailValid = isEmailValid();
      if(_isEmailValid ){
        recoverPassword();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recover Password'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Recover Password',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _email,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                recoverPassword();
              },
              child: const Text('Recover'),
            ),
          ),
        ],
      ),
    );
  }
}
