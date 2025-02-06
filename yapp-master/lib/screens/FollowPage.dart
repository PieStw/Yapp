import 'package:flutter/material.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/user.dart';
import 'package:yapp/screens/ProfilePage.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key, required this.follow, required this.uid});

  final bool follow;
  final String uid;

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  List<String> followList = [];
  final _db = DatabaseService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowData();
  }

  Future<void> _loadFollowData() async {
    List<String> data = [];
    if (widget.follow) {
      data = await _db.getUserFollower(widget.uid);
    } else {
      data = await _db.getUserFollowing(widget.uid);
    }
    setState(() {
      followList = data;
      isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.follow ? 'Followers' : 'Following'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : followList.isEmpty
          ? const Center(child: Text('No data found'))
          : ListView.builder(
        itemCount: followList.length,
        itemBuilder: (context, index) {
          return FutureBuilder(
            future: _db.getUserProfile(followList[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final user = snapshot.data as UserProfile;
              return ListTile(
                title: Text(user.username),
                subtitle: Text(user.name),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(uid: user.uid, myProfile: false),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

