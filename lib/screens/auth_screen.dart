import 'package:ewasfa/widgets/background_painter.dart';
import 'package:ewasfa/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
import 'forgot_password_screen.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen through which the user can login or signup')
class AuthCard extends StatefulWidget {
  late AuthMode authMode;

  AuthCard(this.authMode);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // ignore: prefer_final_fields
  Map<String, dynamic> _authData = {
    'password': '',
    'rememberMe': false,
    'phone': '',
    'email': '',
    'fname': '',
    'lname': '',
    'gender': '',
  };

  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  late AuthMode _authMode;
  var isVisibility = true;
  var isVisibility2 = true;
  var visibilityIcon = Icons.visibility_outlined;
  var visibilityIcon2 = Icons.visibility_outlined;
  bool _rememberMe = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    _authMode = widget.authMode;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.genericError),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text(loc.okayMsg),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext ctx) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    var resp;
    try {
      print(
          "phone: ${_authData['phone']}, pw: ${_authData['password']}, remember Me:${_authData['rememberMe']}, ");

      if (_authMode == AuthMode.login) {
        resp = await Provider.of<Auth>(ctx, listen: false).login(
            _authData['phone']!.toString(),
            _authData['password']!.toString(),
            _authData['rememberMe']! as bool,
            context);
      } else {
        resp = await Provider.of<Auth>(ctx, listen: false).signup(
          _authData['email']!.toString(),
          _authData['password']!.toString(),
          _authData['rememberMe']! as bool,
          _authData['fname']!.toString(),
          _authData['lname']!.toString(),
          _authData['phone']!.toString(),
          _authData['gender']!,
          context,
        );
      }
      print(resp);

      if (resp != 0) {
        var errorMessage = AppLocalizations.of(ctx)?.authenticationFailedError;
        if (resp == 1) {
          errorMessage = AppLocalizations.of(ctx)?.phoneInUseError;
        } else if (resp == 5) {
          errorMessage = AppLocalizations.of(ctx)?.invalidPhoneError;
        } else if (resp == 10) {
          errorMessage = AppLocalizations.of(ctx)?.notExistAccErrMsg;
        } else if (resp == 7) {
          errorMessage = AppLocalizations.of(ctx)?.wrongPasswordError;
        } else if (resp == 8) {
          errorMessage = AppLocalizations.of(ctx)?.notExistAccErrMsg;
        } else if (resp == 9) {
          errorMessage = AppLocalizations.of(ctx)?.verifyPhoneError;
        }
        _showErrorDialog(errorMessage!, AppLocalizations.of(context)!);
      }
    } on HttpException catch (error) {
      var errorMessage = AppLocalizations.of(ctx)?.genericError;
      if (error.toString().contains('PHONE_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that phone.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage!, AppLocalizations.of(ctx)!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signUp;
        _controller.forward();
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
        _controller.reverse();
      });
    }
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
    final deviceSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0.sp),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: _authMode == AuthMode.signUp?0.0.h:20.h),
                    child: CustomTextFormField(
                      enabledBorder: InputBorder.none,
                      onSaved: (value) {
                        _authData['phone'] = value!;
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
                  if (_authMode == AuthMode.signUp)
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        enabledBorder: InputBorder.none,
                        onSaved: (value) {
                          _authData['fname'] = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.fnameEmptyMsg;
                          }
                          return null;
                        },
                        hintText:
                            AppLocalizations.of(context)?.first_name_label,
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  if (_authMode == AuthMode.signUp)
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        enabledBorder: InputBorder.none,
                        onSaved: (value) {
                          _authData['lname'] = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.lnameEmptyMsg;
                          }
                          return null;
                        },
                        hintText: AppLocalizations.of(context)?.last_name_label,
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  if (_authMode == AuthMode.signUp)
                    Padding(
                      padding: EdgeInsets.only(top: 20.0.h),
                      child: CustomTextFormField(
                        enabledBorder: InputBorder.none,
                        onSaved: (value) {
                          _authData['email'] = value!;
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppLocalizations.of(context)?.emailEmptyMsg;
                          }
                          if (!RegExp(
                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                              .hasMatch(value)) {
                            return AppLocalizations.of(context)?.emailFormatMsg;
                          }
                          return null;
                        },
                        hintText: AppLocalizations.of(context)?.email_label,
                        textInputType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0.h),
                    child: CustomTextFormField(
                      enabledBorder: InputBorder.none,
                      onSaved: (value) {
                        _authData['password'] = value!;
                      },
                      controller: _passwordController,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return AppLocalizations.of(context)
                              ?.password_too_short_error;
                        }
                        return null;
                      },
                      hintText: AppLocalizations.of(context)?.password_label,
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
                  // Center(
                  //   child: Visibility(
                  //     visible: _authMode == AuthMode.login,
                  //     child: Padding(
                  //       padding: const EdgeInsets.only(top: 8.0),
                  //       child: TextButton(
                  //         onPressed:
                  //             Provider.of<Auth>(context, listen: false).signGuest,
                  //         child: Text(AppLocalizations.of(context)!.guestLogin,
                  //             style: Theme.of(context)
                  //                 .textTheme
                  //                 .bodyMedium
                  //                 ?.copyWith(fontWeight: FontWeight.bold)),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: _authMode == AuthMode.signUp ? 15.0.h : 0.0),
                    child: AnimatedContainer(
                      constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.signUp ? 60 : 0,
                        maxHeight: _authMode == AuthMode.signUp ? 120 : 0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: CustomTextFormField(
                            controller: _passwordController,
                            enabledBorder: InputBorder.none,
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
                            enabled: _authMode == AuthMode.signUp,
                            onSaved: (value) {
                              _authData['password'] = value!;
                            },
                            validator: _authMode == AuthMode.signUp
                                ? (value) {
                                    if (value != _passwordController.text) {
                                      return AppLocalizations.of(context)
                                          ?.passwords_do_not_match_error;
                                    }
                                    return null;
                                  }
                                : null,
                            hintText: AppLocalizations.of(context)
                                ?.confirm_password_label,
                            textInputType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Center(
                      child: SizedBox(
                        height: 80.h,
                        child: const LoadingIndicator(
                            indicatorType: Indicator.ballBeat,
                            colors: [primarySwatch]),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(
                        top: _authMode == AuthMode.login ? 30.0.h : 15.0,
                        right: 10.w,
                        left: 10.w,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          _submit(context);
                        },
                        child: Container(
                          height: 60.h,
                          width: MediaQuery.of(context).size.width - 70,
                          decoration: BoxDecoration(
                              color: _passwordController.text.trim().isEmpty
                                  ? Colors.yellow.shade100
                                  : Colors.black87,
                              border:
                                  Border.all(color: Colors.black, width: 3)),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                  _authMode == AuthMode.login
                                      ? AppLocalizations.of(context)!
                                          .login_button_label
                                      : AppLocalizations.of(context)!
                                          .signup_button_label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: _passwordController.text
                                                  .trim()
                                                  .isEmpty
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.sp)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // CheckboxListTile(
                  //   activeColor: primarySwatch.shade500,
                  //   title: Text(AppLocalizations.of(context)!.remember_me_label,
                  //       style: Theme.of(context).textTheme.labelLarge),
                  //   value: _rememberMe,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       _rememberMe = value!;
                  //       _authData['rememberMe'] = _rememberMe;
                  //     });
                  //   },
                  // ),
                  Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: _authMode == AuthMode.login
                          ? TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ForgotPasswordScreen.routeName);
                              },
                              child: Text(
                                  AppLocalizations.of(context)!.forgotPassword,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          color: Color(0xFF828282),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.sp)),
                            )
                          : null),
                  Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: _authMode == AuthMode.login?55.w:40.w,
                              vertical:_authMode == AuthMode.login? 25.h:0.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(AppLocalizations.of(context)!.dont_have_an_account,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: Color(0xFF828282),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 17.sp)),
                          TextButton(
                            style: TextButton.styleFrom(
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                            onPressed: _switchAuthMode,
                            child: Text(
                                _authMode == AuthMode.login
                                    ? AppLocalizations.of(context)!
                                        .signup_button_label
                                    : AppLocalizations.of(context)!
                                        .login_button_label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17.sp)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';
  late AuthMode authMode;

  AuthScreen(this.authMode);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: SizedBox(
          height: deviceSize.height,
          width: deviceSize.width,
          child: GestureDetector(
            onTap: () {
              final currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 60.0, bottom: 10),
                            child: SizedBox(
                              height: 140.h,
                              child: Image.asset(
                                "lib/assets/images/logo_x0.25.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          AuthCard(authMode),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthMode {
  signUp,
  login,
  no,
}
