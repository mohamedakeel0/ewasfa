import 'dart:convert';
import 'dart:io';

import 'package:ewasfa/providers/language.dart';
import 'package:ewasfa/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';

import 'package:flutter/foundation.dart';

import '../main.dart';
import '../providers/auth.dart';

@Category(<String>['Screens'])
@Summary(
    'The Screen through which the user can enter their OTP code to acquire verification')
enum OTPState { success, failure }

class OTPScreen extends StatelessWidget {
  static const routeName = '/verify';

  OTPScreen({Key? key}) : super(key: key);

  String code = "";
  String phone = "";

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final args = ModalRoute.of(context)?.settings.arguments as List;
    code = args[0].toString();
    phone = args[1].toString();
    print(code);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Image.asset("lib/assets/images/logo_x0.5.png"),
          ),
          Flexible(
            flex: deviceSize.width > 600 ? 2 : 1,
            child: Consumer<LanguageProvider>(
              builder: (context, languageProvider, _) {
                return Localizations(
                  delegates: AppLocalizations.localizationsDelegates,
                  locale: languageProvider.currentLanguage == Language.arabic
                      ? const Locale('ar')
                      : const Locale('en'),
                  child: VerifyCard(
                      code: int.parse(code), phone: int.parse(phone)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VerifyCard extends StatefulWidget {
  final int code;
  final int phone;

  const VerifyCard({Key? key, required this.code, required this.phone})
      : super(key: key);

  @override
  _VerifyCardState createState() => _VerifyCardState();
}

class _VerifyCardState extends State<VerifyCard> {
  final _formKey = GlobalKey<FormState>();
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              keyboardType: TextInputType.number,
              maxLength: 5,
              decoration: InputDecoration(
                labelText: appLocalization.enterOTP,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                backgroundColor: primarySwatch.shade500,
                disabledBackgroundColor: primarySwatch.shade900),
            onPressed: _otp.length == 5
                ? () async {
                    final auth = Provider.of<Auth>(context, listen: false);
                    await _verifyOTP(context)?.then((value) {
                      Logger().d(value);
                      if (value == OTPState.success) {
                        auth.setPhoneVerify(true);
                        Navigator.pushNamed(context, MyHomePage.routeName);
                      }
                    });
                  }
                : null,
            child: Text(appLocalization.submit),
          ),
        ],
      ),
    );
  }

  Future? _verifyOTP(BuildContext context) {
    // Implement your OTP verification logic here
    // You can access the OTP entered by the user using _otp variable
    // You can also access the code argument passed to the AuthCard widget using widget.code
    // For example, you can compare it with a server-generated OTP

    // Dummy implementation for demonstration
    final appLocalization = AppLocalizations.of(context)!;
    if (_otp == widget.code.toString()) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appLocalization.orderSuccess),
          content: Text(appLocalization.otpSuccessful),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalization.okayMsg),
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('$apiUrl/phone_verify'),
                    body: {
                      "phone": widget.phone.toString(),
                      "code": widget.code.toString(),
                      "action": "r"
                    },
                  );
                  final responseData = json.decode(response.body);
                  if (responseData['error'] != 0) {
                    throw HttpException(responseData['error']['message']);
                  }
                  Navigator.of(ctx).pop(OTPState.success);
                } catch (error) {
                  Navigator.of(ctx).pop(OTPState.failure);
                  rethrow;
                }
              },
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appLocalization.genericError),
          content: Text(appLocalization.otpfailed),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalization.okayMsg),
              onPressed: () {
                Navigator.of(ctx).pop(OTPState.failure);
                // Return the OTPState.failure result to the signup function
              },
            ),
          ],
        ),
      );
    }
  }
}
