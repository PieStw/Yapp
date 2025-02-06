import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yapp/auth/storage_service.dart';
import 'package:yapp/models/comment.dart';
import 'package:yapp/models/post.dart';
import 'package:yapp/models/user.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = StorageService();


  Future<void> createUser({required String? name, required String? email}) async {
    String uid = _auth.currentUser!.uid;
    if(email != null) {
      String username = email.split('@')[0];
      String basicImageUrl = await _storage.getBasicImageUrl();
      name ??= username;
      UserProfile user = UserProfile(
          uid: uid,
          email: email,
          name: name,
          photoUrl: basicImageUrl,
          username: username,
          bio: '',
          followedBy: [],
          following: []
      );
      final UserMap = user.toMap();
      await _db.collection('users').doc(uid).set(UserMap);
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return UserProfile.fromDocument(doc);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getUserFollower(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return UserProfile.fromDocument(doc).followedBy;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getUserFollowing(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      return UserProfile.fromDocument(doc).following;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<UserProfile>> getUsersProfile(String username) async {
    try {

      QuerySnapshot snapshot = await _db.collection('users').get();

      List<QueryDocumentSnapshot> matchingUsers = snapshot.docs.where((doc) {
        String storedUsername = doc['username'];
        return storedUsername.contains(username);
      }).toList();

      return matchingUsers.map((doc) => UserProfile.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching user profiles: $e');
    }
  }

  Future<void> updateUserProfile({File? image, required String username, required String bio}) async {

    String uid = _auth.currentUser!.uid;
    UserProfile? user = await getUserProfile(uid);

    String imageUrl = user!.photoUrl;

    List<Post> posts;

    if(user.username != username) {
      posts = await getUserPosts(uid);
      for(Post post in posts) {
          await updatePostUserName(post.id, username);
      }
    }

    if (image != null) {
      if (imageUrl != await _storage.getBasicImageUrl()) {
        await _storage.deleteImage(imageUrl);
      }

      imageUrl = await _storage.uploadImg(image); // Attendi che la funzione restituisca una String
    }


    UserProfile updatedUser = UserProfile(
      uid: user.uid,
      email: user.email,
      name: user.name,
      photoUrl: imageUrl,
      username: username,
      bio: bio,
      following: user.following,
      followedBy: user.followedBy,
    );

    Map<String, dynamic> userMap = updatedUser.toMap();
    await _db.collection('users').doc(uid).update(userMap);
  }

  Future<void> updatePostUserName(String postId, String newUserName) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'username': newUserName,
    });
  }

  Future<void> updatePostImageUser(String postId, String newImagePic) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'userImageUrl': newImagePic,
    });
  }

  Future<void> followUser(String uid) async {
    String currentUid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
    DocumentSnapshot currentUserDoc = await _db.collection('users').doc(currentUid).get();

    UserProfile user = UserProfile.fromDocument(userDoc);
    UserProfile currentUser = UserProfile.fromDocument(currentUserDoc);

    List<String> following = currentUser.following;
    List<String> followedBy = user.followedBy;

    if (!following.contains(uid)) {
      following.add(uid);
      followedBy.add(currentUid);
    } else {
      following.remove(uid);
      followedBy.remove(currentUid);
    }

    await _db.collection('users').doc(currentUid).update({
      'following': following,
    });

    await _db.collection('users').doc(uid).update({
      'followedBy': followedBy,
    });
  }

  Future<void> unFollowUser(String uid) async {
    String currentUid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();
    DocumentSnapshot currentUserDoc = await _db.collection('users').doc(currentUid).get();

    UserProfile user = UserProfile.fromDocument(userDoc);
    UserProfile currentUser = UserProfile.fromDocument(currentUserDoc);

    List<String> following = currentUser.following;
    List<String> followedBy = user.followedBy;

    if (following.contains(uid)) {
      following.remove(uid);
      followedBy.remove(currentUid);
    }

    await _db.collection('users').doc(currentUid).update({
      'following': following,
    });

    await _db.collection('users').doc(uid).update({
      'followedBy': followedBy,
    });
  }

  Future<void> createPost({required String message, File? image}) async {

    String uid = _auth.currentUser!.uid;
    UserProfile? user = await getUserProfile(uid);

    String imageUrl = '';

    if (image != null) {
      imageUrl = await _storage.uploadImg(image);
    }

    Post newPost = Post(
        id: '',
        uid: user!.uid,
        username: user.username,
        text: message,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: [],
        comments: []
    );

    Map<String, dynamic> postMap = newPost.toMap();
    await _db.collection('posts').add(postMap);
  }

  Future<void> updatePost(String postId, String text) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).update({
      'text': text,
    });
  }

  Future<List<Post>> getPostsFromFollowed() async {
    String uid = _auth.currentUser!.uid;
    List<String>? following = (await getUserProfile(uid))?.following;

    List<Post> posts = [];

    for (String userId in following!) {
      List<Post> userPosts = await getUserPosts(userId);
      posts.addAll(userPosts);
    }

    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return posts;
  }

  Future<List<Post>> getUserPosts(String userId) async {

    QuerySnapshot snapshot = await _db.collection('posts').where('uid', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
  }

  Future<void> likePost(String postId) async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot postDoc = await _db.collection('posts').doc(postId).get();
    Post post = Post.fromDocument(postDoc);

    List<String> likedBy = post.likedBy;
    int likeCount = post.likeCount;

    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
      likeCount--;
    } else {
      likedBy.add(uid);
      likeCount++;
    }

    await _db.collection('posts').doc(postId).update({
      'likedBy': likedBy,
      'likeCount': likeCount,
    });
  }

  Future<void> deletePost(Post post) async {
    await _storage.deleteImage(post.imageUrl);
    await _db.collection('posts').doc(post.id).delete();
  }

  Future<void> createComment({required String text, required String postId}) async {
    String uid = _auth.currentUser!.uid;

    Comment comment = Comment(
        id: '',
        uid: uid,
        postId: postId,
        text: text,
        timestamp: Timestamp.now(),
        likeCount: 0,
        likedBy: []
    );

    final CommentMap = comment.toMap();
    await _db.collection('comments').doc(uid).set(CommentMap);
  }
}


