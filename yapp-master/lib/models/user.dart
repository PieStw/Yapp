import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfile{
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final String username;
  final String bio;
  final List<String> following;
  final List<String> followedBy;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.following,
    required this.followedBy
  });

  factory UserProfile.fromDocument(DocumentSnapshot doc){
    return UserProfile(
      uid: doc['uid'],
      email: doc['email'],
      name: doc['name'],
      photoUrl: doc['photoUrl'],
      username: doc['username'],
      bio: doc['bio'],
      following: List<String>.from(doc['following'] ?? []),
      followedBy: List<String>.from(doc['followedBy'] ?? [])
    );
  }


  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'username': username,
      'bio': bio,
      'following': following,
      'followedBy': followedBy
    };
  }









}


