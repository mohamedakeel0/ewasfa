import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../assets/app_data.dart';

@Category(<String>['Providers'])
@Summary('The App Language Provider class')
enum Language { english, arabic }

/// A class used to provide and manage the app's [Language].
/// Primary usage is to Retrieve, update and save user selected Language to the SharedPreferences and the remote API
class LanguageProvider with ChangeNotifier {
  LanguageProvider(){
    getCurrentLanguage();
  }
  Language _currentLanguage = Language.arabic;

  Language get currentLanguage => _currentLanguage;

  /// Sets the current [_currentLanguage] to the user-saved [Language] if found in the phone's [SharedPreferences]
  Future<void> getCurrentLanguage() async {
    Logger logger = Logger();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString("language") ?? "na";
    _currentLanguage =
        lang == "Language.english" ? Language.english : Language.arabic;
    logger.d(
        "Retrieved Language: ${_currentLanguage.toString()} from code $lang");
    notifyListeners();
  }

  /// Saves the user's preference of [Language] to the phone's [SharedPreferences]
  void saveLanguagePreference(Language language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language.toString());
  }

  /// Sends an API request to change the API's incoming messages locale. Additionally, changes the [_currentLanguage] as per user Selection and notifies listeners.
  Future<void> changeLanguage(Language language, userId) async {
        const url = "$apiUrl/change_language";
    Map<String, dynamic> requestBody = {
      "user_id": userId.toString(),
      "lang": language == Language.arabic ? "ar" : "en",
    };
    Logger logger = Logger();
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields.addAll(
        requestBody.map((key, value) => MapEntry(key, value.toString())));
    logger.d(request.toString());
    final response = await request.send();
    logger.d(response.toString());
    final responseData = await response.stream.transform(utf8.decoder).join();
    final parsedResponse = json.decode(responseData);
    if (parsedResponse['message'] != null) {
      // Display success message to the user
      final msg = parsedResponse['message'];
      logger.d(msg);
    }
    _currentLanguage = language;
    notifyListeners();
  }
}
