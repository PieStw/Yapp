import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/post.dart';
import 'package:yapp/screens/ProfilePage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _db = DatabaseService();
  List<Post> _posts = [];
  bool _isLoading = true;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    List<Post> posts = await _db.getPostsFromFollowed();
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<String?> _getProfileImageUrl(String uid) async {
    final userProfile = await _db.getUserProfile(uid);
    return userProfile?.photoUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadPosts,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _posts.isEmpty
              ? Center(
            child: Text(
              'Attualmente non segui nessuno.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          )
              : ListView.builder(
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
                        Row(
                          children: [
                            FutureBuilder<String?>(
                              future: _getProfileImageUrl(post.uid),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    radius: 20,
                                    child: const Icon(Icons.person, size: 20),
                                  );
                                }

                                final imageUrl = snapshot.data;
                                return CircleAvatar(
                                  backgroundImage: imageUrl != null
                                      ? NetworkImage(imageUrl)
                                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                                  backgroundColor: Colors.grey[300],
                                  radius: 20,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Profile(uid: post.uid, myProfile: false),
                                    ),
                                  );
                                },
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
                                  icon: const Icon(Icons.favorite_border),
                                  color: post.likedBy.contains(_auth.currentUser!.uid)
                                      ? Colors.red
                                      : Colors.black,
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
                                const SizedBox(width: 2),
                                Text(
                                  '${post.likeCount} Like',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Comments',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Altri dettagli',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
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
    );
  }
}
