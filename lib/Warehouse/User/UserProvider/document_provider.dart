import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
class PhotoProvider extends ChangeNotifier {
  File? _pancardPhoto;
  File? _selfieOfOwnerPhoto;
  File? _aadharCardFrontPhoto;
  File? _aadharCardBackPhoto;
  File? get frontPhoto => _pancardPhoto;
  File? get backPhoto => _selfieOfOwnerPhoto;
  File? get aadharPhotoFront => _aadharCardFrontPhoto;
  File? get aadharPhotoBack => _aadharCardBackPhoto;

  void updatePanPhoto(File? photo) {
    _pancardPhoto = photo;
    notifyListeners();
  }

  void selfieOfOwnerPhotoUpdate(File? photo) {
    _selfieOfOwnerPhoto = photo;
    notifyListeners();
  }

  void aadharCardPhotoFront(File? photo) {
    _aadharCardFrontPhoto = photo;
    notifyListeners();
  }

  void aadharCardPhotoback(File? photo) {
    _aadharCardBackPhoto = photo;
    notifyListeners();
  }

  bool get arepancardPhotosUploaded => _pancardPhoto != null;
  bool get areselfiePhotosUploaded => _selfieOfOwnerPhoto != null;
  bool get areFrontAadharUploaded => _aadharCardFrontPhoto != null;
  bool get areBackAadharUploaded => _aadharCardBackPhoto != null;

  Future<bool> uploadPhotos(String phone) async {
    try {
      final uri = Uri.parse('https://xpacesphere.com/api/Register/OwnerRegistr');
      var request = http.MultipartRequest('POST', uri);
      final photos = {
        'PanCard': _pancardPhoto,
        'Selfie': _selfieOfOwnerPhoto,
        'AadharCard': _aadharCardFrontPhoto,
        'AadharCard': _aadharCardBackPhoto,
      };
      for (var entry in photos.entries) {
        final fieldName = entry.key;
        final photo = entry.value;
        if (photo is File) {
          var file = await http.MultipartFile.fromPath(
            fieldName,
            photo.path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(file);
        }
      }
      request.fields['MobileNumber'] = phone;
      if (request.files.isNotEmpty) {
        var response = await request.send();
        if (kDebugMode) {
          print("API response status code: ${response.statusCode}");
          print("API response status code: ${response.request}");
        }
        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('Upload successful');
          }
          return true;
        } else {
          if (kDebugMode) {
            print('Upload failed with status code: ${response.statusCode}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          print('No photos to upload');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred during upload: $e');
      }
      return false;
    }
  }

}
