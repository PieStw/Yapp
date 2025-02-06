import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';


class Comment{
  final String id;
  final String uid;
  final String postId;
  final String text;
  final Timestamp timestamp;
  late int likeCount;
  final List<String> likedBy;


  Comment({
    required this.id,
    required this.uid,
    required this.postId,
    required this.text,
    required this.timestamp,
    required this.likeCount,
    required this.likedBy
  });



  factory Comment.fromDocument(DocumentSnapshot doc){
    return Comment(
        id: doc.id,
        uid: doc['uid'],
        text: doc['text'],
        postId: doc['postId'],
        timestamp: doc['timestamp'],
        likeCount: doc['likeCount'],
        likedBy: List<String>.from(doc['likedBy'] ?? [])
    );
  }


  Map<String, dynamic> toMap(){
    return {
      'uid': uid,
      'text': text,
      'postId': postId,
      'timestamp': timestamp,
      'likeCount': likeCount,
      'likedBy': likedBy
    };
  }









}


