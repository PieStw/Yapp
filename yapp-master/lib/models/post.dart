import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';


class Post{
  final String id;
  final String uid;
  final String username;
  final String text;
  final String imageUrl;
  final Timestamp timestamp;
  late int likeCount;
  final List<String> likedBy;
  final List<String> comments;


  Post({
    required this.id,
    required this.uid,
    required this.username,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy,
    required this.comments
  });



  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      id: doc.id,
      uid: doc['uid'],
      username: doc['username'],
      text: doc['text'],
      imageUrl: doc['imageUrl'],
      timestamp: doc['timestamp'],
      likeCount: doc['likeCount'],
      likedBy: List<String>.from(doc['likedBy'] ?? []),
      comments: List<String>.from(doc['comments'] ?? [])
    );
  }


  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'username': username,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likedBy': likedBy,
      'comments': comments
    };
  }









}


