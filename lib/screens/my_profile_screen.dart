import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ewasfa/screens/auth_screen.dart';
import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:ewasfa/widgets/address_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';


import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/user.dart';
import '../providers/auth.dart';
import '../providers/language.dart';
import '../providers/user_data.dart';
import '../assets/app_data.dart';
import '../widgets/custom_app_bar.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The My Profile Screen')
class MyProfileScreen extends StatefulWidget {
  static const routeName = '/profile';

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isEditMode = false;
  User _editedUser = User(
      email: "",
      firstName: "",
      gender: "",
      image: "",
      lastName: "",
      phone: "",
      userId: -1,
      userRank: "");
  final _formKey = GlobalKey<FormState>();
  late XFile image;
  bool isImageChanged = false;
  final picker = ImagePicker();

  @override
  void initState() {
    final userData = Provider.of<UserData>(context, listen: false);
    userData.fetchAndSetUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);
    final userData = Provider.of<UserData>(context);
    final auth = Provider.of<Auth>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (!userData.isInitialized) {
      // Return a loading indicator or placeholder widget while the data is being initialized
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            pageTitle: appLocalization.myProfile,
          ),
          body: Center(
            child: Transform.scale(
              scale: 0.5,
              child: const LoadingIndicator(
                  indicatorType: Indicator.ballBeat, colors: [primarySwatch]),
            ),
          ),
        ),
      );
    }
    final user = userData.user;

    return Localizations(
      delegates: AppLocalizations.localizationsDelegates,
      locale: languageProvider.currentLanguage == Language.arabic
          ? const Locale('ar')
          : const Locale('en'),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(actions: [],
          pageTitle: appLocalization.myProfile,
          leading: Container(
            color: Colors.white,
            width: 20.w,
          ),
          isLogOut: true,
        ),
        body: Container(
          margin: EdgeInsets.only(top: query.size.height * 0.05),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: SizedBox(
                  height: query.size.height * 0.9,
                  width: query.size.height * 0.9,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ZoomableImageScreen.routeName,
                                      arguments: [
                                        ZoomableImageSourceType.network,
                                        "$userImagesDirectory/${user.image}"
                                      ]);
                                },
                                child: CircleAvatar(
                                  radius: 80,
                                  foregroundImage: isImageChanged
                                      ? Image.file(File(image.path)).image
                                      : user.image == ""
                                          ? Image.asset(
                                                  "lib/assets/images/user_placeholder.jpg")
                                              .image
                                          : CachedNetworkImageProvider(
                                              "$userImagesDirectory/${user.image}",
                                            ),
                                ),
                              ),
                              Visibility(
                                visible: _isEditMode,
                                child: CircleAvatar(
                                  backgroundColor: primarySwatch.shade500,
                                  radius: 19,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.photo_camera,
                                      color: Color(0xFF303030),
                                    ),
                                    onPressed: () {
                                      _showImageSourceSheet();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(
                                  appLocalization.firstName,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                subtitle: _isEditMode
                                    ? TextFormField(
                                        initialValue: user.firstName,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return appLocalization
                                                .fnameEmptyMsg;
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            _editedUser.firstName = value!;
                                          });
                                        },
                                      )
                                    : Text(user.firstName),
                              ),
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(
                                  appLocalization.lastName,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                subtitle: _isEditMode
                                    ? TextFormField(
                                        initialValue: user.lastName,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return appLocalization
                                                .lnameEmptyMsg;
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            _editedUser.lastName = value!;
                                          });
                                        },
                                      )
                                    : Text(user.lastName),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email),
                                title: Text(
                                  appLocalization.email,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                subtitle: _isEditMode
                                    ? TextFormField(
                                        initialValue: user.email,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!RegExp(
                                                  r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                              .hasMatch(value)) {
                                            return AppLocalizations.of(context)
                                                ?.emailFormatMsg;
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            _editedUser.email = value!;
                                          });
                                        },
                                      )
                                    : Text(user.email),
                              ),
                              ListTile(
                                leading: const Icon(Icons.book),
                                title: Text(
                                  appLocalization.addressBook,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AddressBookWidget.routeName),
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: 40.0.h),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(

                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(

                                            backgroundColor: Colors.white,
                                            title: Text(appLocalization.deleteAccount,

                                            ),
                                            content: Text(
                                                appLocalization.sureDeleteAccount),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text(appLocalization.back
                                                ,      style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                      color: Colors.yellow.shade700,
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                              ),
                                              TextButton(
                                                child: Text(appLocalization.confirm_delete,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                      color: Colors.red,
                                                      fontSize: 15.sp,
                                                      fontWeight: FontWeight.w400),
                                                ),
                                                onPressed: () async {
                                                  userData.deleteAccount();
                                                  auth.logout(context);
                                            // Close the dialog
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 60.h,
                                      width: MediaQuery.of(context).size.width - 70,
                                      decoration: BoxDecoration(
                                          color:  Colors.red,
                                       ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                              appLocalization.deleteAccount,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                  color:  Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 17.sp)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: query.size.height * 0.05),
                child: Align(
                  alignment: languageProvider.currentLanguage == Language.arabic
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          icon: Icon(_isEditMode ? Icons.check : Icons.edit),
                          onPressed: _isEditMode
                              ? () {
                                  _saveChanges(appLocalization);
                                }
                              : () {
                                  _toggleEditMode();
                                },
                        ),
                      ),
                      Visibility(
                          visible: _isEditMode,
                          child: IconButton(
                              onPressed: () {
                                _toggleEditMode();
                              },
                              icon: const Icon(Icons.cancel))),
                    ],
                  ),
                ),
              ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _saveChanges(AppLocalizations appLocalization) async {
    final userData = Provider.of<UserData>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final jsonData = {
        'user_id': "${userData.user.userId}",
        'first_name': _editedUser.firstName,
        'last_name': _editedUser.lastName,
        'phone': userData.user.phone,
        'email': _editedUser.email,
        'gender': _editedUser.gender,
      };
      userData.updateProfile(isImageChanged, image, jsonData, appLocalization);
    }
    _toggleEditMode();
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 120,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.selectSource,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        textStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                        backgroundColor: primarySwatch.shade500),
                    onPressed: () async {
                      final pickedImage = await picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (pickedImage != null) {
                        setState(() {
                          image = pickedImage;
                          isImageChanged = true;
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                    label: Text(AppLocalizations.of(context)!.camera,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        textStyle:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                ),
                        backgroundColor: primarySwatch.shade500),
                    onPressed: () async {
                      final pickedImage =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedImage != null) {
                        setState(() {
                          isImageChanged = true;
                          image = pickedImage;
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.photo_album, color: Colors.black),
                    label: Text(AppLocalizations.of(context)!.gallery,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
