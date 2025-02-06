import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yapp/screens/SettingsPage.dart';
import 'package:yapp/themes/theme_provider.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final _auth = FirebaseAuth.instance;

  Future<void> logOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.tertiary,
      child: Column(
        children: [
          AppBar(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            automaticallyImplyLeading: false,
          ),
          const SizedBox(height: 20),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => ListTile(
              title: const Text("Dark Mode"),
              trailing: CupertinoSwitch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Settings()));
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                logOut();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Theme.of(context).colorScheme.secondary,
                minimumSize: const Size(250, 45),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _auth.currentUser?.email ?? 'No email',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
