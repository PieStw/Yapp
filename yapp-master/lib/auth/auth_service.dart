import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yapp/auth/database/database_service.dart';

class Auth{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _dbInstance = FirebaseFirestore.instance;
  final _db = DatabaseService();

  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUid() => _auth.currentUser!.uid;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try{
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password);
      return userCredential;
    }on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }

  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try{
       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password);
      return userCredential;
    }on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  signInGoogle () async {

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if(googleUser == null) return;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      final userRef = _dbInstance.collection('users').doc(user.uid);
      final docSnapshot = await userRef.get();

      if (!docSnapshot.exists) {
        _db.createUser(name: user.displayName, email: user.email);

      }
    }

    return _auth.signInWithCredential(credential);
  }



  Future<void> sendEmailVerification() async {
    try{
      await _auth.currentUser?.sendEmailVerification();
    }on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

}