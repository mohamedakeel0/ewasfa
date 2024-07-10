import 'dart:convert';

import 'package:ewasfa/screens/reset_password.dart';
import 'package:ewasfa/widgets/background_painter.dart';
import 'package:ewasfa/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final _formKey = GlobalKey<FormState>();
  Future<void> _sendResetPasswordRequest(String phone) async {
    _isLoading=true;
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
          // if(code!=null){
            Navigator.pushNamed(context, ResetPasswordPage.routeName, arguments: {"code": code,"phone": phone} );
            _phoneController.text='';

          // }
          setState(() {
            _isLoading=false;
          });

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
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: CustomPaint(
                  painter: BackgroundPainter(),
                  child: Container(height: MediaQuery.of(context).size.height,
                    margin: EdgeInsets.only(top: query.size.height * 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding:  EdgeInsets.only(top: 120.0.h, bottom: 20),
                            child: SizedBox(
                              height: 200.h,
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
                                    .forgotPassword,
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
                              controller: _phoneController,
                              cursorColor: primarySwatch.shade500,
                              enabledBorder: InputBorder.none,
                                onChanged: (value) {
                                  setState(() {
                                    phone = value;
                                  });
                                },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)?.phoneEmptyMsg;
                                }
                                return null;
                              },
                              hintText:
                              AppLocalizations.of(context)?.phone_number_label,
                              textInputType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
              
              
                          Padding(
                            padding:  EdgeInsets.symmetric(vertical: 30.0.h),
                            child: GestureDetector(
                              onTap:
                                   () {
                                if(_formKey.currentState!.validate()                ){

                              _isLoading?null:_sendResetPasswordRequest(phone);



                                }
              
                              },
                              child: Container(
                                height: 60.h,
                                width: MediaQuery.of(context).size.width - 60,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: Colors.black, width: 3)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child:_isLoading
                                        ? CircularProgressIndicator()
                                        : Text(
                                        AppLocalizations.of(context)!.send,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17.sp)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:  EdgeInsets.symmetric(vertical: 10.0.h),
                            child: Text(
                                AppLocalizations.of(context)!.title_forget,textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp)),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }
}
