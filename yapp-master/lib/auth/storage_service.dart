import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';


class StorageService with ChangeNotifier{
  List<String> _imageUrls = [];

  bool _isLoading = false;
  bool _isUploading = false;

  String downloadUrl = "";

  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;


  Future<void> fetchImages() async {
    _isLoading = true;
    final ListResult result = await FirebaseStorage.instance.ref('uploaded_images/').listAll();

    final urls = await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    _imageUrls = urls;

    _isLoading = false;

    notifyListeners();

  }

  Future<String> getBasicImageUrl() async {
    try {
      String filePath = 'basicUser.png';

      Reference ref = FirebaseStorage.instance.ref(filePath);

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Errore durante il recupero dell\'URL dell\'immagine: $e');
      return '';
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      _imageUrls.remove(url);
      final String path = extractPathFromUrl(url);
      await FirebaseStorage.instance.ref(path).delete();
      notifyListeners();
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String encodedPath = uri.pathSegments.last;
    return Uri.decodeComponent(encodedPath);
  }

  Future<String> uploadImg(File? image) async {
    _isUploading = true;
    notifyListeners();

    if (image == null) {
      _isUploading = false;
      notifyListeners();
      return "";
    }

    try {
      String filePath = 'uploaded_images/${DateTime.now()}.png';
      await FirebaseStorage.instance.ref(filePath).putFile(image);
      downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
      _imageUrls.add(downloadUrl);
    } catch (e) {
      print(e);
    }


    _isUploading = false;
    notifyListeners();
    return downloadUrl;
  }


}