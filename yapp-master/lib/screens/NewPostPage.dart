import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yapp/auth/database/database_service.dart';
import 'package:yapp/models/user.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  File? _selectedImage;
  final TextEditingController _text = TextEditingController();
  final _db = DatabaseService();
  final _auth = FirebaseAuth.instance;
  late Future<UserProfile?> user;

  @override
  void initState() {
    super.initState();
    user = _db.getUserProfile(_auth.currentUser!.uid);
  }

  Future _pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnedImage == null) return;
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento dell\'immagine dalla galleria')),
      );
    }
  }

  Future _pickImageFromCamera() async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnedImage == null) return;
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento dell\'immagine dalla fotocamera')),
      );
    }
  }

  void post() {
    if (_text.text.isNotEmpty) {
      _db.createPost(message: _text.text, image: _selectedImage);
      _text.clear();
      setState(() {
        _selectedImage = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa il testo e seleziona un\'immagine')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: FutureBuilder<UserProfile?>(
            future: user,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Errore nel caricamento del profilo'));
              } else {
                final userProfile = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Image.network(
                            userProfile.photoUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 50, color: Colors.grey);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _text,
                                  maxLines: null,
                                  maxLength: 200,
                                  decoration: const InputDecoration(
                                    hintText: "Cosa c'è di nuovo?",
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Immagine selezionata:',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 330,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : const Center(
                                  child: Text(
                                    "Seleziona un'immagine",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImageFromGallery,
                                    icon: const Icon(Icons.image),
                                    label: const Text("Galleria"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: _pickImageFromCamera,
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text("Fotocamera"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "Chiunque può rispondere e aggiungere citazioni",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: ElevatedButton(
                                  onPressed: post,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    backgroundColor: Colors.deepPurple,
                                  ),
                                  child: const Text('Pubblica', style: TextStyle(color: Colors.white),),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
