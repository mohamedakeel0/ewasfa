// ignore_for_file: use_build_context_synchronously

import 'package:ewasfa/screens/app_layout_screen.dart';
import 'package:ewasfa/screens/order/doctor_make_order_details.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../assets/app_data.dart';
import '../../main.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen through which the doctor makes an order')
class DoctorMakeOrderScreen extends StatefulWidget {
  static const routeName = '/doctor_make_order';
  const DoctorMakeOrderScreen({super.key});

  @override
  State<DoctorMakeOrderScreen> createState() => _DoctorMakeOrderScreenState();
}

class _DoctorMakeOrderScreenState extends State<DoctorMakeOrderScreen> {
  final picker = ImagePicker();
  List<XFile>? _images;
  Logger logger = Logger();
  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
          appBar: CustomAppBar(pageTitle: appLocalization.doctorOrder),
          extendBodyBehindAppBar: true,
          body: Container(
            margin: EdgeInsets.only(top: query.size.height * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  appLocalization.selectSource,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                backgroundColor: primarySwatch.shade500),
                            onPressed: () async {
                              final pickedImage = await picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (pickedImage != null) {
                                setState(() {
                                  _images = [pickedImage];
                                  logger.d(_images);
                                });
                                Navigator.of(context).pushNamed(
                                    DoctorOrderDetailsScreen.routeName,
                                    arguments: _images);
                              } else {
                                showCustomErrorDialog(context, appLocalization);
                              }
                            },
                            icon: const Icon(Icons.camera),
                            label: Text(appLocalization.camera,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    )),
                          ),
                          const SizedBox(height: 20, width: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade700,
                                    ),
                                backgroundColor: primarySwatch.shade500),
                            onPressed: () async {
                              final pickedImages =
                                  await picker.pickMultiImage();
                              if (pickedImages != null) {
                                setState(() {
                                  _images = pickedImages;
                                });
                                Navigator.of(context).pushNamed(
                                    DoctorOrderDetailsScreen.routeName,
                                    arguments: _images);
                              } else {
                                showCustomErrorDialog(context, appLocalization);
                              }
                            },
                            icon: const Icon(Icons.photo_album),
                            label: Text(appLocalization.gallery,
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
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                      backgroundColor: primarySwatch.shade500),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppLayoutScreen.routeName, (route) => false);
                  },
                  child: Text(
                    appLocalization.homePage,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void showCustomErrorDialog(
      BuildContext context, AppLocalizations appLocalization) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(appLocalization.noImageErrorMsg),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                  backgroundColor: primarySwatch.shade500),
              child: Text(
                AppLocalizations.of(context)!.okayMsg,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
