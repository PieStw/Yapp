import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/auth/storage_service.dart';

class Register extends StatefulWidget {
  final void Function()? onTap;
  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password2 = TextEditingController();


  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isPasswordValid2 = true;


  bool isPasswordValid2() {
    if(_password.text == _password2.text && _password2.text.isNotEmpty){
      return true;
    }
    return false;
  }


  bool isPasswordValid() {
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(_password.text);
  }


  bool isEmailValid() {
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(_email.text);
  }

  final _auth = FirebaseAuth.instance;
  final _db = DatabaseService();

  Future<void> createUser() async {
    try {
      await _auth.createUserWithEmailAndPassword(email: _email.text, password: _password.text);

    }on FirebaseAuthException catch (e) {
      print(e);
    }
    await _db.createUser(name: _name.text, email: _email.text);


  }


  void register() {

    setState(() {
      _isEmailValid = isEmailValid();
      _isPasswordValid = isPasswordValid();
      _isPasswordValid2 = isPasswordValid2();
    });

    if(_isEmailValid && _isPasswordValid && _isPasswordValid2){
      createUser();
    }
  }


  @override
  Widget build(BuildContext context) {

    Color? borderColorEmail = _isEmailValid ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
    Color? borderColorPassword = _isPasswordValid ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
    Color? borderColorPassword2 = _isPasswordValid2 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;

    Color? textColorEmail = _isEmailValid ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onError;
    Color? textColorPassword = _isPasswordValid ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onError;
    Color? textColorPassword2 = _isPasswordValid2 ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onError;


    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 75.0),
                child: const Image(
                    image: AssetImage('images/signup.png'), height: 400),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _name.text = value;
                      });
                    },
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
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
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() {
                        _isEmailValid = isEmailValid();
                      });
                    }
                  },
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _email.text = value;
                      });
                    },
                    style: TextStyle(color: textColorEmail),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: textColorEmail),
                      filled: true,
                      fillColor: borderColorEmail,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: borderColorEmail,
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
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() {
                        _isPasswordValid = isPasswordValid();
                      });
                    }
                  },
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _password.text = value;
                      });
                    },
                    style: TextStyle(color: textColorPassword),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: textColorPassword),
                      filled: true,
                      fillColor: borderColorPassword,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: borderColorPassword,
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
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      setState(() {
                        _isPasswordValid2 = isPasswordValid2();
                      });
                    }
                  },
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _password2.text = value;
                      });
                    },
                    style: TextStyle(color: textColorPassword2),
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(color: textColorPassword2),
                      filled: true,
                      fillColor: borderColorPassword2,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: borderColorPassword2,
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
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  onPressed: () {
                    register();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(250, 45),
                  ),
                  child: Text('Register',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 20)),
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Already have an account? ',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18)),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text('Login',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}