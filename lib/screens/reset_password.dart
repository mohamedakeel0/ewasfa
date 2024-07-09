import 'dart:convert';

import 'package:ewasfa/screens/auth_screen.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import '../assets/app_data.dart';

@Category(<String>['Screens'])
@Summary('The Screen through which the user can enter their new password after a successful forget password request')
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
  late String _userPhone;



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
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      _otp = arguments['code'].toString();
     _userPhone = arguments['phone'].toString();

    return Scaffold(
      appBar: CustomAppBar(
        pageTitle: 'Reset Password',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Code'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading ? CircularProgressIndicator() : Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
