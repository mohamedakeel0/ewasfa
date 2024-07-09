import 'package:ewasfa/assets/app_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

import 'language.dart';

@Category(<String>['Providers'])
@Summary('The Application Theme Provider class')
/// A class that manages the application theme and provides methods to retrieve, save, and toggle the theme.
/// This class extends [ChangeNotifier] to allow for notifying listeners of changes to the theme.
/// The theme is represented by the [_isDarkMode] property, which indicates whether the dark mode is enabled or not.
/// The class provides the [currentTheme] property to retrieve the current theme based on the value of [_isDarkMode].
/// The theme is returned as a [ThemeData] object, which can be used to configure the application's UI.
/// The theme selection is stored in the device's shared preferences and retrieved using the [getCurrentTheme] method.
/// The theme is saved using the [saveCurrentTheme] method, and the theme can be toggled using the [toggleTheme] method.
/// The class can be used as a provider to notify listeners of changes to the theme. 
class AppTheme with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  Language currentLanguage = Language.english;

  AppTheme(){
    getCurrentTheme();
  }
  /// Returns the current Theme of the application. Is either [ThemeData.dark()] or [ThemeData.light()] depending on user selection. Also sets font family to "Cairo" if the language is arabic
  ThemeData get currentTheme => _isDarkMode
      ? ThemeData.dark().copyWith(
          colorScheme: ThemeData.dark().colorScheme.copyWith(),
          textTheme: currentLanguage == Language.arabic? Typography().white.apply(fontFamily: 'Cairo'): Typography().white,          
        )
      : ThemeData.light().copyWith(
          colorScheme: ThemeData.light().colorScheme.copyWith(),
          textTheme:  currentLanguage == Language.arabic? Typography().black.apply(fontFamily: 'Cairo'): Typography().black,
        );

  /// Retrieves and sets the Current user-selected theme from the phone's [SharedPreferences] if present. If not, assumes light theme mode. Also sets language to change font in case of arabic language.
  Future<void> getCurrentTheme() async {
    Logger logger = Logger();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getString("theme") == "dark" ? true : false;
    String lang = prefs.getString("language") ?? "na";
    currentLanguage =
        lang == "Language.arabic" ? Language.arabic : Language.english;
    logger.d("Retrieved Theme: ${_isDarkMode ? "Dark" : "Light"}");
    notifyListeners();
  }

  /// Saves the current theme into the phone's [SharedPreferences]. 
  Future<void> saveCurrentTheme(String theme) async {
    Logger logger = Logger();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("theme", _isDarkMode ? "dark" : "light");
    notifyListeners();
  }

  void toggleLanguage(){
    if(currentLanguage == Language.english) {
      currentLanguage = Language.arabic;
    } else{
      currentLanguage = Language.english;
    }
  }
  /// Used to toggle the theme data from Light to Dark or Dark to Light depending on current state and User Selection
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
