import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';
import '../models/user.dart';

@Category(<String>['Providers'])
@Summary('The User Profile Data Provider class')

/// A class used to manage and provide user data and its implementation.
/// Used primarily to retrieve, update, store and provide user profile data to its consumers throughout the app.
class UserData with ChangeNotifier {
  /// Whether user data has been completely fetched from the remote API. used primarily to avoid late initialization errors
  bool _isInitialized = false;

  late int userId;
  late String userRank;
  late User user;
  Logger logger = Logger();

  bool get isInitialized => _isInitialized;

  User get userData {
    return user;
  }

  /// Used to update the object's [userId] and [userRank]. Used after instantiation.
  UserData updateUserIdRank(int userId, String userRank) {
    this.userId = userId;
    this.userRank = userRank;
    if(userId!=-1){
      fetchAndSetUserData();
    }
    return this;
  }

  /// Delete Account function. 
  Future<void> deleteAccount() async {
    try {
      final response = await http.post(
        Uri.parse("$apiUrl/delete_user?user_id=$userId"),
      );
      final responseData = json.decode(response.body);
      logger.i(responseData);
      if (responseData['error'] != 0) {}
    } catch (error) {
      rethrow;
    }
  }

  /// Sends a request to the remote API to update user profile including or excluding profile [image].
  /// On success, displays a toast message and notifies listeners.
  Future<void> updateProfile(bool isImageChanged, image, jsonData,
      AppLocalizations appLocalization) async {
    if (isImageChanged) {
      // Create a multipart request for image upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/update_profile'),
      );
      // Add other form fields
      final imageFile = File(image.path);
      request.fields.addAll(jsonData.map((key, value) => MapEntry(key, value)));

      // Add the image file to the request
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final imageUpload = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(imageUpload);

      // Send the request and handle the response
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (data['error'] == 0) {
        // Success
        logger.d(data['message']);
      } else {
        // Error
        logger.d('Error: ${data['message']}');
      }
    } else {
      // Send a POST request without the image
      Logger().d(jsonData);
      final response = await http.post(
        Uri.parse('$apiUrl/update_profile'),
        body: jsonData,
      );
      final responseData = response.body;
      final data = json.decode(responseData);
      if (data['error'] == 0) {
        // Success
        logger.d(data['message']);
        Fluttertoast.showToast(
          msg: appLocalization.profileUpdate,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        // Error
        logger.d('Error: ${data['message']}');
      }
    }
  }

  /// Sends a request to retrieve and store User Data from the remove API.
  /// On success, notifies listeners.
  /// On failure, rethrows the error
  Future<void> fetchAndSetUserData() async {
    final url = '$apiUrl/show_user?user_id=$userId';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);

      if (extractedData == null) {
        return;
      }
      var userData = extractedData["user_data"][0];
      Logger().d(userData);
      user = User(
        userId: userData["id"] ?? userId,
        firstName: userData["first_name"] ?? "",
        lastName: userData["last_name"] ?? "",
        phone: userData["phone"] ?? "",
        email: userData["email"] ?? "",
        image: userData["image"] ?? "",
        gender: userData["gender"] ?? "",
        userRank: userRank,
      );
      logger.d("User Data Retrieved and stored");
      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
