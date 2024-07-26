import 'package:ewasfa/screens/auth_screen.dart';
import 'package:ewasfa/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashAuthScreen extends StatefulWidget {
  const SplashAuthScreen({Key? key}) : super(key: key);
  static const routeName = '/splash_auth';

  @override
  State<SplashAuthScreen> createState() => _SplashAuthScreenState();
}

class _SplashAuthScreenState extends State<SplashAuthScreen> {
  AuthMode authMode=AuthMode.login;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: CustomPaint(
          painter: BackgroundPainter(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 20),
                child: SizedBox(
                  height: 300.h,
                  child: Image.asset(
                    "lib/assets/images/logo_x4.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0.h),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      authMode=AuthMode.signUp;
                    });
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AuthScreen(AuthMode.signUp)));
                  },
                  child: Container(
                    height: 60.h,
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                        color: authMode==AuthMode.signUp? Colors.black: Colors.yellow.shade100,
                        border: Border.all(color: Colors.black, width: 3)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                            AppLocalizations.of(context)!.signup_button_label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: authMode!=AuthMode.signUp? Colors.black: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17.sp)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0.h),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      authMode=AuthMode.login;
                    });
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AuthScreen(AuthMode.login)));
                  },
                  child: Container(
                    height: 60.h,
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                        color:authMode==AuthMode.login? Colors.black: Colors.yellow.shade100,
                        border: Border.all(color: Colors.black, width: 3)),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                            AppLocalizations.of(context)!.login_button_label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color:authMode==AuthMode.login? Colors.white: Colors.black,
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
    );
  }
}
