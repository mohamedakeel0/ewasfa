import 'dart:convert';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../assets/app_data.dart';
import '../models/http_exception.dart';
import 'package:logger/logger.dart';

import '../screens/verify_code.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Providers'])
@Summary('The user Authentication state Provider class')

/// Provider class for authentication data and methods.
/// This class provides an app-wide authentication state [auth] that indicates if a user is authenticated or not. Additionally, it handles user signup and redirects new users OTP verification on signup.
class Auth with ChangeNotifier {
  /// The main output of this class. [auth] is used to determine if a user is currently authenticated or not throughout the whole app. If false, the user is logged out. If true, the user is authenticated and is logged into the app's main screens.
  bool auth = false;
  bool subauth = false;
  bool phoneVerify = false;


  /// [guest] is used when a user decides to login as a guest. It is used to check if the user is actually logged in as guest when trying to access account-specific features like making an order.
  bool guest = false;
  late int _userId;
  late String _userRank;
  var logger = Logger();
  late int code;

  /// Returns true if user is authenticated. False if not.
  bool get isAuth {
    return auth;
  }

  bool get isGuest {
    return guest;
  }

  /// Returns the current user's rank, whether it's Doctor or User
  String get userRank {
    return _userRank;
  }

  /// Returns the current user's [userId]
  int get userId {
    return _userId;
  }

  /// Used for registration or login depending on the [urlSegment] entry
  /// Also calls [_autoLogout] and notifies all listeners once the user's been authenticated.
  /// ## Case 1: Login:
  /// Sends a login request to the remote api with the user's [phone] and [password]. Throws an [HttpException] if an error occurs.
  /// Also redirects user to OTP verification page if they have not yet completed OTP verification.
  /// On success, saves user credentials and [rememberMe] choice to the phone's [SharedPreferences] and sets [auth] to true, and notifies listeners to proceed into the app.
  /// ## Case 2: Signup
  /// Sends a regesteration request to the remote api with the user's provided [phone], [password], [fname], [lname], [email] and [gender] to the remote API. Throws an [HttpException] if an error occurs.
  /// On success, saves user credentials and [rememberMe] choice to the phone's [SharedPreferences] and sets [auth] to true, and notifies listeners to proceed into the app.
  Future<int> _authenticate(
      String phone, String password, bool rememberMe, String urlSegment,
      {String? fname,
      String? lname,
      String? email,
      String? gender,
      BuildContext? ctx}) async {
    final appLocalization = AppLocalizations.of(ctx!)!;
    if (urlSegment == 'login') {
      String url = '$apiUrl/$urlSegment';
      logger.d("Logging in to $url ... with credentials $phone & $password");
      try {
        final response = await http.post(
          Uri.parse(url),
          body: {"phone": phone, "passwords": password},
        );
        final responseData = json.decode(response.body);
        logger.i(responseData);
        if (responseData['error'] != 0) {
          if (responseData['error'] == 9) {
            checkVerified(ctx, phone);
            return 9;
          } else {
            if(response.statusCode == 500){
              return 10;
            }
            return int.parse(responseData['error'].toString() ?? '-1');
          }
        }
        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          // Save email and password to shared preferences
          await prefs.setString('phone', phone);
          await prefs.setString('password', password);
        } else {
          // Clear email and password from shared preferences
          await prefs.remove('phone');
          await prefs.remove('password');
        }

        final userData = json.encode(
          {
            'userId': responseData['user_data']['id'],
            "user_rank": responseData['user_data']['state'].toString(),
            'firstLogin': DateTime.now().toIso8601String(),
          },
        );
        _userId = int.parse(responseData['user_data']['id'].toString());
        checkOrSendToken(_userId);
        _userRank = responseData['user_data']['state'].toString();
        logger.i("Auth Obtained UserId: $_userId with rank $_userRank");
        prefs.setString('userData', userData);
        auth = true;
        guest = false;
        notifyListeners();
        return 0;
      } catch (error) {
        rethrow;
      }
    } else {
      logger.d("Signing up...");
      String url = "$apiUrl/$urlSegment";
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final body = {
        "first_name": fname,
        "last_name": lname,
        "password": password,
        "phone": phone,
        "email": email,
        "gender": gender,
        "firebase_token": fcmToken,
      };
      logger.d(body);
      try {
        final response = await http.post(Uri.parse(url), body: body);
        final responseData = json.decode(response.body);

        if (responseData['error'] != 0) {
          if (responseData['error'] == 1) {
            return 1;
          } else if (responseData['error'] == 5) {
            return 5;
          } else {
            throw -1;
          }
        }

        final prefs = await SharedPreferences.getInstance();
        if (rememberMe) {
          // Save email and password to shared preferences
          await prefs.setString('phone', phone);
          await prefs.setString('password', password);
        } else {
          // Clear email and password from shared preferences
          await prefs.remove('phone');
          await prefs.remove('password');
        }

        final userData = json.encode(
          {
            'userId': responseData['user_data']['id'],
            "user_rank": responseData['user_data']['state'].toString(),
            'firstLogin': DateTime.now().toIso8601String(),
          },
        );
        _userId = int.parse(responseData['user_data']['id'].toString());
        checkOrSendToken(_userId);
        _userRank = responseData['user_data']['state'].toString();
        logger.i("Auth Obtained UserId: $_userId with rank $_userRank");
        prefs.setString('userData', userData);
        code = responseData['code'];
        notifyListeners();
        return 0;
      } catch (error) {
        logger.d('test $error');
        throw HttpException(appLocalization!.genericError);
      }
    }
  }

  void signGuest() {
    auth = true;
    guest = true;
    notifyListeners();
  }

  void setPhoneVerify(bool state) {
    phoneVerify = state;
    if (subauth) {
      auth = true;
    }
    notifyListeners();
  }



  /// Used to call authenticate, ordering a signup. After input validation, navigates user to OTP verification page. If successful, completes registration process and notifies listeners
  Future<int> signup(
      String email,
      String password,
      bool rememberMe,
      String fname,
      String lname,
      String phone,
      String gender,
      BuildContext context) async {
    var resp = await _authenticate(phone.toString(), password.toString(), rememberMe, 'regesteration',
        fname: fname.toString(), lname: lname.toString(), email: email.toString(), gender: gender, ctx: context);
    if (resp != 0) {
      logger.d(resp);
      return resp;
    }
    subauth = true;
    await Navigator.pushNamed(context, OTPScreen.routeName,
        arguments: [code, phone]);
    if (phoneVerify == true) {
      auth = true;
      notifyListeners();
      return 0;
    } else {
      return -1;
    }
  }

  /// Used to call authenticate, ordering a login
  Future<int> login(
      String email, String password, bool rememberMe, BuildContext ctx) async {
    return await _authenticate(email.toString(), password.toString(), rememberMe, 'login', ctx: ctx);
  }

  /// Sends a request to the remote API to check if the [verify_state] property of the user is ['r'] indicating that they haven't completed OTP Verification.
  /// If they haven't, redirects the user to the OTP Verification screen to continue OTP verification and sends another request to the remote API to resend the OTP to the user's phone via SMS
  Future<bool> checkVerified(BuildContext context, String phone) async {
    final url = "$apiUrl/get_verify_state?phone=$phone";
    logger.d(url);
    final response = await http.get(Uri.parse(url));
    final responseData = json.decode(response.body);
    Logger().d(responseData);
    if (responseData['verify_state'].toString() == 'r') {
      final urlVerify = "$apiUrl/resend_OTP?phone=$phone";
      String otpCode = "";
      {
        final response = await http.get(Uri.parse(urlVerify));
        final responseData = json.decode(response.body);
        logger.d("Retrieving Stored token = ${responseData.toString()}");
        if (response.statusCode == 200) {
          otpCode = responseData["code"];
          print(otpCode);
        }
      }
      subauth = true;
      notifyListeners();
      Navigator.pushNamed(context, OTPScreen.routeName,
          arguments: [otpCode, phone]);
      return false;
    } else
      return true;
  }

  /// Checks whether there are user credentials in the phone's [SharedPreferences],
  /// returns true if user credentials and data were found. Returns false otherwise
  Future<bool> tryAutoLogin(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs!.containsKey('userData')) {
      logger.d('Auth: SharedPreferences has no userdata');
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData') ?? '') as Map<String, dynamic>;
    _userId = int.parse(extractedUserData['userId'].toString());
    _userRank = extractedUserData['user_rank'].toString();
    final email = prefs.getString('email');
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');
    if (email != null && password != null) {
      await _authenticate(email, password, true, 'login', ctx: ctx);
    } else {
      return false;
    }
    if (_userId != null) {
      checkOrSendToken(_userId);
    }
    if (phone == null) {
      var state = await checkVerified(ctx, phone!);
      if (state) {
        auth = true; // Set the authentication state to true
        notifyListeners();
        return true;
      }
      else{
        return false;
      }
    } else {
      return false;
    }
  }

  /// Sends a request to the remote API to retrieve current remotely stored FCM Token. Also check if the current remotely stored FCM token is the same as the one fetched on the phone.
  /// If they are not the same, sends another request to the remote API to change the stored FCM token, to allow the API to send FCM notifications to the phone.
  Future<void> checkOrSendToken(int userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    logger.d("Retrieved Token: $fcmToken");
    final url = "$apiUrl/get_token?user_id=$userId";
    logger.d(url);
    final response = await http.get(Uri.parse(url));
    final responseData = json.decode(response.body);
    logger.d("Retrieving Stored token = ${responseData.toString()}");
    if (response.statusCode == 200) {
      final userData = responseData['user_data'];
      final token = userData['firebase_token'] ?? "";
      if (token == null || token != fcmToken) {
        const url = "$apiUrl/set_token";
        final response = await http.post(
          Uri.parse(url),
          body: {
            "user_id": userId.toString(),
            "firebase_token": fcmToken.toString()
          },
        );
        final responseData = json.decode(response.body);
        logger.i("$responseData");
        if (responseData['error'] != 0) {
          throw HttpException(responseData['error']['message']);
        }
      } else {
        logger.d(token);
      }
    } else {}
  }

  /// Clears authentication data from the app and SharedPreferences, then notifies listeners, causing logout
  Future<void> logout() async {
    _userId = -1;
    auth = false;
    subauth = false;
    phoneVerify = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  /// Returns the user authentication token if it's not expired or nonexistent
  // String? get token {
  //   if (_expiryDate.isAfter(DateTime.now()) && auth != null) {
  //     return auth;
  //   }
  //   return null;
  // }

  /// A timer that runs till the expiry datetime of the token. On expiry, it forces logout
  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer?.cancel();
  //   }
  //   final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }
}
