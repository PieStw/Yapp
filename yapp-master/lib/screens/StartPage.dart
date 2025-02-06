import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yapp/components/drawer.dart';
import 'package:yapp/screens/HomePage.dart';
import 'package:yapp/screens/NewPostPage.dart';
import 'package:yapp/screens/ProfilePage.dart';
import 'package:yapp/screens/SearchPage.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Widget> get _widgetOptions {
    if (_auth.currentUser != null) {
      return <Widget>[
        const Home(),
        const PostPage(),
        const Search(),
        Profile(uid: _auth.currentUser!.uid, myProfile: true),
      ];
    } else {
      return <Widget>[
        const Home(),
        const PostPage(),
        const Search(),
        const Center(child: Text('User not logged in')),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          if (_auth.currentUser != null)
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'New Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
