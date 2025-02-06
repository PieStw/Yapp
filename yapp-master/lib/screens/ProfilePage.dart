import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/post.dart';
import 'package:yapp/models/user.dart';
import 'package:yapp/screens/CommentPage.dart';
import 'package:yapp/screens/FollowPage.dart';

class Profile extends StatefulWidget {
  final String uid;
  final bool myProfile;

  const Profile({super.key, required this.uid, required this.myProfile});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String username = 'Loading...';
  late String name = 'Loading...';
  late String bio = 'Loading...';
  late String profileImageUrl =
      'https://via.placeholder.com/150';
  List<Post> posts = [];
  late List<String> following = [];
  late String followingCount = '0';
  late List<String> followers = [];
  late String followersCount = '0';


  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;
  late Future<UserProfile?> user;

  @override
  void initState() {
    super.initState();
    _loadProfileData(widget.uid);
  }

  void deletePost(Post post) {
    _db.deletePost(post);
    setState(() {
      posts.remove(post);
    });
  }

  Future<void> _editPost(Post post) async {
    TextEditingController textController =
    TextEditingController(text: post.text);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica Post'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Modifica il testo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {

                await _db.updatePost(post.id, textController.text);
                Navigator.of(context).pop();
                _loadProfileData(widget.uid);
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadProfileData(String uid) async {
    user = _db.getUserProfile(uid);
    UserProfile? userProfile = await user;
    List<Post> userPosts = await _db.getUserPosts(uid);

    setState(() {
      if (userProfile != null) {
        name = userProfile.name;
        username = userProfile.username;
        bio = userProfile.bio;
        profileImageUrl = userProfile.photoUrl;
        following = userProfile.following;
        followers = userProfile.followedBy;
        followingCount = following.length.toString();
        followersCount = followers.length.toString();
      }
      posts = userPosts;
    });
  }

  Future<void> _refreshPosts() async {
    await _loadProfileData(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profilo di $name'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueGrey, width: 3),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome e Username
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@$username',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Bio
                      Text(
                        bio,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.people, size: 20, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    child: Text('$followingCount Seguiti', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                    onPressed: () { Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => FollowPage(uid: widget.uid, follow: false))); },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.people_alt_outlined, size: 20, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    child: Text('$followersCount Seguaci', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                    onPressed: () { Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => FollowPage(uid: widget.uid, follow: true))); },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),

                          if (!widget.myProfile && _auth.currentUser != null)
                            followers.contains(_auth.currentUser!.uid)
                                ? ElevatedButton(
                              onPressed: () async {
                                await _db.unFollowUser(widget.uid);

                                setState(() {
                                  followers.remove(_auth.currentUser!.uid);
                                  followersCount = (int.parse(followersCount) - 1).toString();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              child: const Text('Smetti di seguire', style: TextStyle(fontSize: 14)),
                            )
                                : ElevatedButton(
                              onPressed: () async {
                                await _db.followUser(widget.uid);

                                setState(() {
                                  followers.add(_auth.currentUser!.uid);
                                  followersCount = (int.parse(followersCount) + 1).toString();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 20,
                                ),
                              ),
                              child: const Text('Segui', style: TextStyle(fontSize: 14)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(profileImageUrl),
                                  backgroundColor: Colors.grey[300],
                                  radius: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    post.username,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.myProfile)
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      if (value == 'Modifica') {
                                        _editPost(post);
                                      } else if (value == 'Elimina') {
                                        deletePost(post);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem(
                                          value: 'Modifica',
                                          child: Text('Modifica'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Elimina',
                                          child: Text('Elimina'),
                                        ),
                                      ];
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post.text,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              maxLines: post.imageUrl.isNotEmpty ? 2 : 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (post.imageUrl.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.imageUrl,
                                  height: 520,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.favorite_border),
                                      color: post.likedBy.contains(_auth.currentUser!.uid) ? Colors.red : Colors.black,
                                      onPressed: () {
                                        _db.likePost(post.id);
                                        setState(() {
                                          post.likedBy.contains(_auth.currentUser!.uid)
                                              ? post.likedBy.remove(_auth.currentUser!.uid)
                                              : post.likedBy.add(_auth.currentUser!.uid);

                                          post.likeCount += post.likedBy.contains(_auth.currentUser!.uid) ? 1 : -1;
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${post.likeCount} Like',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.comment),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(builder: (context) => CommentPage()));
                                      },
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Comments',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
