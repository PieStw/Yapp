import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/user.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File? _selectedImage;
  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;
  late Future<UserProfile?> user;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    }
  }

  void _loadUserProfile() {
    user = _db.getUserProfile(_auth.currentUser!.uid);
    user.then((userProfile) {
      if (userProfile != null) {
        _username.text = userProfile.username ?? '';
        _bio.text = userProfile.bio ?? '';
        setState(() {});
      }
    });
  }

  Future<void> _updateProfile() async {
    if (_selectedImage != null || _username.text.isNotEmpty || _bio.text.isNotEmpty) {
      await _db.updateUserProfile(
        image: _selectedImage,
        username: _username.text,
        bio: _bio.text,
      );

      _loadUserProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profilo aggiornato con successo!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila tutti i campi richiesti')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica Profilo'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureBuilder<UserProfile?>(
            future: user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Errore: ${snapshot.error}');
              } else if (snapshot.hasData) {
                final userProfile = snapshot.data;
                if (userProfile != null) {
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 300,
                          width: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 4),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              userProfile.photoUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton.icon(
                              onPressed: _pickImageFromGallery,
                              icon: const Icon(Icons.photo),
                              label: const Text(
                                'Scegli una foto',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: _pickImageFromCamera,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text(
                                'Scatta una foto',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          controller: _username,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          controller: _bio,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size(250, 50),
                            elevation: 5,
                          ),
                          child: const Text(
                            'Modifica Profilo',
                            style: TextStyle(fontSize: 18, color: Colors.white),

                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Text('Nessun profilo trovato');
                }
              } else {
                return const Text('Nessun dato disponibile');
              }
            },
          ),
        ),
      ),
    );
  }
}
