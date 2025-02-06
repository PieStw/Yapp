import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/login_or_register.dart';
import 'package:yapp/screens/StartPage.dart';
import 'package:yapp/screens/login-registration/VerifyEmail.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.hasData){
              if(snapshot.data!.emailVerified) {
                return const Start();
              }else{
                  return const Verify();
                }
            }else{
              return const LoginOrRegister();
            }
          }),
    );
  }
}

