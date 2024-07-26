import 'dart:convert';

import 'package:ewasfa/screens/auth_screen.dart';
import 'package:ewasfa/widgets/background_painter.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:ewasfa/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../assets/app_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@Category(<String>['Screens'])
@Summary(
    'The Screen through which the user can enter their new password after a successful forget password request')
class ResetPasswordPage extends StatefulWidget {
  static const routeName = '/reset_password';

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  late String _otp;
  final _formKey = GlobalKey<FormState>();
  late String _userPhone;
  var isVisibility = true;
  var isVisibility2 = true;
  var visibilityIcon = Icons.visibility_outlined;
  var visibilityIcon2 = Icons.visibility_outlined;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    // Get the values from the text fields
    final code = _codeController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check if password and confirm password match
    if (password != confirmPassword) {
      showDialog(barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(backgroundColor: Colors.white,
          title: Text('Password Mismatch'),
          content: Text(' password and confirm password do not match.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        _isLoading = false;
      });

      return;
    }

    // Check if entered OTP matches the code
    if (code != _otp) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Incorrect OTP'),
          content: Text('The entered OTP is incorrect.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      // Set the API endpoint URL
      final url = Uri.parse('$apiUrl/Reset_password');

      // Create the request body
      final requestBody = {
        "phone": _userPhone, // Replace with the actual phone number
        "code": code,
        "password": password,
      };

      // Make the API request
      final response = await http.post(url, body: requestBody);

      // Parse the response body
      final responseData = json.decode(response.body);

      // Process the response
      if (response.statusCode == 200) {
        // Successful response
        // Access the data from the response
        final error = responseData['error'];
        final message = responseData['message'];

        // Do something with the data
        print('Error: $error');
        print('Message: $message');

        Navigator.popUntil(context, ModalRoute.withName("/"));
      } else {
        // Handle the API error
        // Access the error message from the response
        final errorMessage = responseData['message'];

        // Handle the error
        print('API Error: $errorMessage');
      }
    } catch (error) {
      // Handle any errors that occur during the API request
      print('Error: $error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void changePasswordVisibility() {
    isVisibility = !isVisibility;

    visibilityIcon =
        isVisibility ? Icons.visibility_outlined : Icons.visibility_off;
  }

  void changePasswordVisibility2() {
    isVisibility2 = !isVisibility2;

    visibilityIcon2 =
        isVisibility ? Icons.visibility_outlined : Icons.visibility_off;
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _otp = arguments['code'].toString();
    _userPhone = arguments['phone'].toString();

    return Scaffold(
      appBar: CustomAppBar(
        pageTitle: AppLocalizations.of(context)!.resetPassword,
      ),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                      child: SizedBox(
                        height: 250.h,
                        child: Image.asset(
                          "lib/assets/images/logo_x0.25.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(vertical: 15.0.h),
                      child: Text(
                          AppLocalizations.of(context)!
                              .resetPassword,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 17.sp)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        controller: _codeController,
                        cursorColor: primarySwatch.shade500,
                        enabledBorder: InputBorder.none,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.otp;
                          }
                          return null;
                        },
                        hintText: AppLocalizations.of(context)?.otp,
                        textInputType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        controller: _passwordController,
                        cursorColor: primarySwatch.shade500,
                        enabledBorder: InputBorder.none,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.new_password;
                          }
                          return null;
                        },
                        hintText: AppLocalizations.of(context)?.new_password,
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        obscureText: isVisibility,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                changePasswordVisibility();
                              });
                            },
                            icon: Icon(
                              visibilityIcon,
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        controller: _confirmPasswordController,
                        cursorColor: primarySwatch.shade500,
                        enabledBorder: InputBorder.none,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.new_password;
                          }
                          return null;
                        },
                        hintText: AppLocalizations.of(context)?.new_password,
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        obscureText: isVisibility2,
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                changePasswordVisibility2();
                              });
                            },
                            icon: Icon(
                              visibilityIcon2,
                              color: Colors.grey,
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.0.h),
                      child: GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _isLoading ? null : _resetPassword();
                          }
                        },
                        child: Container(
                          height: 60.h,
                          width: MediaQuery.of(context).size.width - 80,
                          decoration: BoxDecoration(
                              color:_confirmPasswordController.text.trim().isEmpty?Colors.yellow.shade300:Colors.black87 ,
                              border:
                                  Border.all(color: Colors.black, width: 3)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                      AppLocalizations.of(context)!
                                          .login_button_label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color:_confirmPasswordController.text.trim().isEmpty? Colors.black:Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17.sp)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
