// ignore_for_file: use_build_context_synchronously


import 'package:ewasfa/providers/user_data.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../assets/app_data.dart';
import '../../providers/orders.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen that displays the details of the Doctor Referred Order')
class DoctorOrderDetailsScreen extends StatefulWidget {
  static const routeName = '/doctor_order_details';

  @override
  _DoctorOrderDetailsScreenState createState() =>
      _DoctorOrderDetailsScreenState();
}

class _DoctorOrderDetailsScreenState extends State<DoctorOrderDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late List<XFile> _arguments;
  late int user_id;
  bool imagesloaded = false;
  Logger logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _arguments = ModalRoute.of(context)!.settings.arguments as List<XFile>;
    imagesloaded = true;
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _doctorNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Perform submission logic here
      String phoneNumber = _phoneNumberController.text;
      String doctorName = _doctorNameController.text;
      String description = _descriptionController.text;
      Map<String, dynamic> requestBody = {
        "user_id": user_id,
        "name": doctorName,
        "phone": phoneNumber,
        "pro_description": description,
      };
      Provider.of<Orders>(context).submitDoctorOrder(requestBody, _arguments, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final userProvider = Provider.of<UserData>(context, listen: false);
    final appLocalization = AppLocalizations.of(context)!;
    user_id = userProvider.userId;
    return imagesloaded
        ? Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
            return Localizations(
              delegates: AppLocalizations.localizationsDelegates,
              locale: languageProvider.currentLanguage == Language.arabic
                  ? const Locale('ar')
                  : const Locale('en'),
              child: Scaffold(
                appBar:
                    CustomAppBar(pageTitle: appLocalization.makeDoctorOrder),
                extendBodyBehindAppBar: true,
                body: Container(
                  margin: EdgeInsets.only(top: query.size.height * 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: appLocalization.patientPhoneNumber,
                              hintText: appLocalization.enterPatientNumber,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return appLocalization.enterPatientNumber;
                              }
                              // You can add more specific validation logic here if needed
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _doctorNameController,
                            decoration: InputDecoration(
                              labelText: appLocalization.patientName,
                              hintText: appLocalization.enterPatientName,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return appLocalization.pleaseEnterPatientName;
                              }
                              // You can add more specific validation logic here if needed
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText:
                                  appLocalization.prescriptionDescription,
                              hintText:
                                  appLocalization.enterPrescriptionDescription,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                    backgroundColor: primarySwatch.shade500),
                                onPressed: _submitOrder,
                                child: Text(appLocalization.submitOrder,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                              ),
                              const SizedBox(
                                height: 20,
                                width: 20,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                    backgroundColor: primarySwatch.shade500),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(appLocalization.back,
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
                  ),
                ),
              ),
            );
          })
        : Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      colors: [primarySwatch]),
                ],
              ),
            ),
          );
  }
}
