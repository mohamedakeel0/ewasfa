import 'dart:convert';

import 'package:ewasfa/screens/reset_password.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../assets/app_data.dart';
import '../providers/language.dart';
import '../providers/user_data.dart';
import '../widgets/custom_app_bar.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen through which the user can send a forget password request')
class ForgotPasswordScreen extends StatefulWidget {
  static const routeName = '/forgot_password';

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}


class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  late String phone;

  Future<void> _sendResetPasswordRequest(String phone) async {
    try {
      // Set the API endpoint URL
      final url =
          Uri.parse('$apiUrl/forget_password');

      // Create the request body
      final requestBody = {
        'phone': phone,
      };

      // Make the API request
      final response = await http.post(url, body: requestBody);

      // Parse the response body
      final responseData = json.decode(response.body);

      // Process the response
      if (response.statusCode == 200) {
        // Successful response
        // Access the data from the response
        final code = responseData['code'];
        final error = responseData['error'];
        final message = responseData['message'];

        Navigator.pushNamed(context, ResetPasswordPage.routeName, arguments: {"code": code,"phone": phone} );

        // Do something with the data
        print('Code: $code');
        print('Error: $error');
        print('Message: $message');
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
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(
              pageTitle: appLocalization.forgotPassword,
            ),
            body: Container(
              margin: EdgeInsets.only(top: query.size.height * 0.05),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                        cursorColor: primarySwatch.shade500,
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.phone_number_label,
                        ),
                        onChanged: (value) {
                          setState(() {
                            phone = value;
                          });
                        }),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                          backgroundColor: primarySwatch.shade500),
                      onPressed: _isLoading
                          ? null
                          : () {
                              _sendResetPasswordRequest(phone);
                            },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(AppLocalizations.of(context)!.resetPassword,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )),
                    ),
                  ],
                ),
              ),
            )));
  }
}
