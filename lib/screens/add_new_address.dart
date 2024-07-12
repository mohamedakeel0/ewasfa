import 'package:ewasfa/providers/addresses.dart';
import 'package:ewasfa/widgets/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';
import '../helpers/location_helper.dart';
import '../models/address.dart';
import '../providers/language.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/map_widget.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen through which the user can add a new address')
class NewAddressScreen extends StatefulWidget {
  static const routeName = '/add_new_address';
  @override
  _NewAddressScreenState createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  String addressLine = '';
  String tempAddress = '';
  String landmark = '';
  String city = '';
  LatLng? selectedLocation;
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _landmarkController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _navigateToMapScreen() async {
    final result =
        await Navigator.of(context).pushNamed(MapScreen.routeName, arguments: {
      "mode": MapMode.pickLocation,
    }) as LatLng;
    if (result != null) {
      final retrievedAddress = await LocationHelper.getPlaceAddress(
          result.latitude, result.longitude);
      tempAddress = retrievedAddress;
      setState(() {
        // final formattedAdd = retrievedAddress.split(",")..removeAt(0);
        // addressLine = formattedAdd.join(",").trim();
        selectedLocation = result;
      });
    }
  }

  void _useLocationData() async {
    if (selectedLocation != null) {
      final retrievedAddress = await LocationHelper.getPlaceAddress(
          selectedLocation!.latitude, selectedLocation!.longitude);
      final retrievedCity = await LocationHelper.getPlaceCity(
          selectedLocation!.latitude, selectedLocation!.longitude);
      setState(() {
        addressLine = retrievedAddress;
        _addressController.text = addressLine;
        city = retrievedCity;
        _cityController.text = city;
      });
    }
  }

  Future<int> _addNewAddressReturnId(Address newAddress,
      AppLocalizations appLocalization, addressesProvider) async {
    return await addressesProvider.addAddress(newAddress, appLocalization);
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);

    final appLocalization = AppLocalizations.of(context)!;
    return Consumer2<LanguageProvider, Addresses>(
        builder: (context, languageProvider, addressesProvider, _) {
      int nextId = addressesProvider.isAddresssLoaded()
          ? addressesProvider.getaddresses().length + 1
          : 1;
      return Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: languageProvider.currentLanguage == Language.arabic
              ? const Locale('ar')
              : const Locale('en'),
          child: Scaffold(
            appBar: CustomAppBar(
              pageTitle: appLocalization.addNewAddress,
            ),
            body: CustomPaint(
              painter: BackgroundPainter(),
              child: Container(
                height: query.size.height,
                width: query.size.width,

                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200.h,
                          child: Image.asset(
                            "lib/assets/images/logo_x0.25.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                        // Address Line TextFormField
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          onChanged: (value) {
                            setState(() {
                              addressLine = value;
                            });
                          },
                          decoration: InputDecoration(
                              labelText: appLocalization.addressLine),
                        ),
                        // Landmark TextFormField
                        TextFormField(
                          controller: _landmarkController,
                          onChanged: (value) {
                            setState(() {
                              landmark = value;
                            });
                          },
                          decoration: InputDecoration(
                              labelText: appLocalization.landmark),
                        ),
                        // City TextFormField
                        TextFormField(
                          controller: _cityController,
                          onChanged: (value) {
                            setState(() {
                              city = value;
                            });
                          },
                          decoration:
                              InputDecoration(labelText: appLocalization.city),
                        ),
                         SizedBox(height: 50.h),
                        GestureDetector(
                          onTap: _navigateToMapScreen,
                          child: Container(
                            height: 60.h,
                            width: MediaQuery.of(context).size.width - 80,
                            decoration: BoxDecoration(
                                color:  Colors.black,
                                border: Border.all(color: Colors.black, width: 3)),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                    appLocalization.selectLocation,
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

                        const SizedBox(height: 16),
                        Text(
                          selectedLocation == null
                              ? appLocalization.selectLocationToProceed
                              : tempAddress,
                        ),
                        const SizedBox(height: 16),
                        if (selectedLocation != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: primarySwatch.shade500),
                                onPressed: () {
                                  // Validate the address data and selectedLocation
                                  if (_validateAddressData() &&
                                      selectedLocation != null) {
                                    addressLine = _addressController.text;
                                    city = _cityController.text;
                                    landmark = _landmarkController.text;
                                    Logger().d(
                                        "$nextId, $addressLine, $landmark, $city, ${selectedLocation!.latitude}, ${selectedLocation!.longitude}");
                                    // Create a new Address object with the entered data and selectedLocation
                                    Address newAddress = Address(
                                      id: nextId,
                                      addressLine: addressLine,
                                      landmark: landmark,
                                      city: city,
                                      latitude: selectedLocation!.latitude,
                                      longitude: selectedLocation!.longitude,
                                    );
                                    // Save the new address to the database
                                    // or pass it back to the previous screen
                                    addressesProvider
                                        .addAddress(newAddress, appLocalization)
                                        .then((value) {
                                      Address updatedAddress = Address(
                                          addressLine: newAddress.addressLine,
                                          city: newAddress.city,
                                          id: value,
                                          landmark: newAddress.landmark,
                                          latitude: newAddress.latitude,
                                          longitude: newAddress.longitude);
                                      Navigator.pop(context, updatedAddress);
                                    });
                                  }
                                },
                                child: Text(appLocalization.submit,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        )),
                              ),
                              Visibility(
                                visible: selectedLocation != null,
                                child: TextButton(
                                  onPressed: _useLocationData,
                                  child: Text(appLocalization.useLocationData,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: primarySwatch.shade500,
                                          )),
                                ),
                              )
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ));
    });
  }

  bool _validateAddressData() {
    // Perform any necessary validations
    // Return true if the data is valid, false otherwise
    // You can check if required fields are filled, etc.
    return true;
  }
}
