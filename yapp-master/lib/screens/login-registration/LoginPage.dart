import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/auth_service.dart';
import 'package:yapp/screens/login-registration/Recover.dart';

class Login extends StatefulWidget {
  final void Function()? onTap;

  const Login({super.key, required this.onTap});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isEmailValid = true;

  bool isEmailValid() {
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(_email.text);
  }

  final _auth = FirebaseAuth.instance;

  Future<void> sigIn() async {
    try {
      await _auth.signInWithEmailAndPassword(email: _email.text, password: _password.text);
    }on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  void login() {
    setState(() {
      _isEmailValid = isEmailValid();
      if(_isEmailValid ){
        sigIn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: const FlutterLogo(size: 60.0),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: const Image(image: AssetImage('images/login.png'), height: 400),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  child: TextField(
                    controller: _email,
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.tertiary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                  child: TextField(
                    controller: _password,
                    obscureText: true,
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.tertiary,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(250, 45),
                      ),
                      child: Text('Login',
                          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text('Or ',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: IconButton(
                        onPressed: () {Auth().signInGoogle();},
                        icon: const Image(
                            image: AssetImage('images/googleIcon.png'),
                            height: 40),
                        color: Colors.red),
                  ),
                ],
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 40.0, left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Don\'t have an account? ',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text('Sign up',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Did you forget your password? ',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Recover()));
                        },
                        child: Text('Recover',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}