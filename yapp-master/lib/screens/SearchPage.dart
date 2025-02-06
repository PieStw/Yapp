import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/user.dart';
import 'package:yapp/screens/ProfilePage.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<UserProfile> _searchResults = [];
  final _db = DatabaseService();

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) {
      return;
    }

    try {
      List<UserProfile> results = await _db.getUsersProfile(_searchController.text);

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nella ricerca: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by nickname',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _performSearch,
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(
                child: Text('No users found'),
              )
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: user.photoUrl.isNotEmpty
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(user.photoUrl),
                    )
                        : const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: ElevatedButton(
                      onPressed: () {
                        if (user.uid == FirebaseAuth.instance.currentUser!.uid) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Profile(uid: user.uid, myProfile: true),
                            ),
                          );
                        }
                        else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Profile(uid: user.uid, myProfile: false),
                            ),
                          );
                        }
                      },
                      child: Icon(Icons.arrow_forward),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
