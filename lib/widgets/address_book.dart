import 'package:ewasfa/providers/language.dart';
import 'package:ewasfa/screens/add_new_address.dart';
import 'package:ewasfa/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:provider/provider.dart';
import '../assets/app_data.dart';
import '../helpers/location_helper.dart';
import '../models/address.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/addresses.dart';
import 'custom_app_bar.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Addresses book screen')
class AddressBookWidget extends StatefulWidget {
  static const routeName = '/address_book';
  @override
  _AddressBookWidgetState createState() => _AddressBookWidgetState();
}

class _AddressBookWidgetState extends State<AddressBookWidget> {
  late TextEditingController _addressController;
  late TextEditingController _landmarkController;
  late TextEditingController _cityController;
  LatLng selectedLocation = LatLng(0.0, 0.0);
  int? editableIndex;
  var addressData = {
    "landmark": "",
    "id": "",
    "address": "",
    "city": "",
    "latitude": 0.0,
    "longitude": 0.0,
  };

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
    _cityController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addressesProvider = Provider.of<Addresses>(context);
    final userAddresses = addressesProvider.getaddresses();
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: languageProvider.currentLanguage == Language.arabic
              ? const Locale('ar')
              : const Locale('en'),
          child: Scaffold(
            extendBodyBehindAppBar: false,
            appBar: CustomAppBar(
              pageTitle: appLocalization.addressBook,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed(NewAddressScreen.routeName);
                  },
                )
              ],
            ),
            body: Container(
              // Customize the appearance of the address book widget
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: userAddresses.length,
                itemBuilder: (context, index) {
                  final address = userAddresses[index];
                  return Card(
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildTitle(address, index),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSubtitle(address, index),
                          ),
                        ],
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildTrailing(address, index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle(Address address, int index) {
    final bool isEditable = editableIndex != null && editableIndex == index;
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final appLocalization = AppLocalizations.of(context)!;
        return isEditable
            ? _buildEditableText(
                address.addressLine, address.city, address.landmark)
            : SizedBox(
              height: 75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Text(
                        appLocalization.city,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        address.city,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
            );
      },
    );
  }

  void _useLocationData() async {
    if (addressData["longitude"] != 0.0 && addressData["latitude"] != 0.0) {
      final retrievedAddress = await LocationHelper.getPlaceAddress(
          addressData["latitude"] as double,
          addressData["longitude"] as double);
      final retrievedCity = await LocationHelper.getPlaceCity(
          addressData["latitude"] as double,
          addressData["longitude"] as double);

      setState(() {
        addressData["address"] = retrievedAddress;
        _addressController.text = retrievedAddress;
        addressData["city"] = retrievedCity;
        _cityController.text = retrievedCity;
        print("Retrieved: ${retrievedAddress} and ${retrievedCity}");
        print(
            "Controllers: ${_addressController.text} and ${_cityController.text}");
      });
    }
  }

  Widget _buildSubtitle(Address address, int index) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final appLocalization = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditable(index)) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                              appLocalization.addressLine,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 2,
                              address.addressLine,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        appLocalization.landmark,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Flex(direction: Axis.horizontal, children: [
                        Expanded(
                          child: Text(
                            maxLines: 2,
                            address.landmark,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTrailing(Address address, int index) {
    final addressesProvider = Provider.of<Addresses>(context, listen: false);
    final appLocalization = AppLocalizations.of(context)!;

    return isEditable(index)
        ? SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        // Submit edited data
                        if (addressData["landmark"].toString() == "" &&
                            addressData["address"].toString() == "" &&
                            addressData["latitude"].toString() == "0.0" &&
                            addressData["longitude"].toString() == "0.0" &&
                            addressData["city"].toString() == "") {
                          setState(() {
                            editableIndex = null;
                            selectedLocation = const LatLng(0.0, 0.0);
                          });
                        } else {
                          try {
                            await addressesProvider.updateAddress(
                                landMark: addressData["landmark"].toString(),
                                address: addressData["address"].toString(),
                                id: address.id.toString(),
                                latitude: addressData["latitude"].toString(),
                                longitude: addressData["longitude"].toString(),
                                city: addressData["city"].toString(),
                                appLocalization: appLocalization);
                            setState(() {
                              editableIndex = null;
                              selectedLocation = const LatLng(0.0, 0.0);
                            });
                          } catch (error) {
                            rethrow;
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        // Cancel editing
                        setState(() {
                          editableIndex = null;
                          selectedLocation = const LatLng(0.0, 0.0);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Enable editing
                  setState(() {
                    editableIndex = index;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Handle delete
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(appLocalization.delete),
                      content: Text(
                        appLocalization.sure_delete,
                      ),
                      actions: [
                        TextButton(
                          child: Text(appLocalization.cancel),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        TextButton(
                          child: Text(appLocalization.confirm_delete),
                          onPressed: () async {
                            try {
                              await addressesProvider.deleteAddress(
                                  address.id, appLocalization);
                              Navigator.of(ctx).pop();
                            } catch (error) {
                              rethrow;
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
  }

  bool isEditable(int index) {
    return editableIndex != null && editableIndex == index;
  }

  Widget _buildEditableText(
    String initialAddress,
    String initialCity,
    String initialLandmark,
  ) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final appLocalization = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalization.city,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                addressData["city"] = newValue;
              },
            ),
            const SizedBox(height: 8),
            Text(
              appLocalization.addressLine,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                addressData["address"] = newValue;
              },
            ),
            const SizedBox(height: 8),
            Text(
              appLocalization.landmark,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                addressData["landmark"] = newValue;
              },
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        onPressed: () async {
                          final location = await Navigator.pushNamed(
                              context, MapScreen.routeName,
                              arguments: {
                                "mode": MapMode.pickLocation,
                              }) as LatLng;
                          if (location.latitude != 0.0) {
                            addressData["latitude"] = location.latitude;
                            addressData["longitude"] = location.longitude;
                          }
                          setState(() {
                            selectedLocation = location;
                          });
                        },
                        icon: const Icon(Icons.location_on)),
                    TextButton(
                        onPressed: () async {
                          final location = await Navigator.pushNamed(
                              context, MapScreen.routeName,
                              arguments: {
                                "mode": MapMode.pickLocation,
                              }) as LatLng?;
                          if (location?.latitude != 0.0 && location != null) {
                            addressData["latitude"] = location.latitude;
                            addressData["longitude"] = location.longitude;
                          }
                          setState(() {
                            selectedLocation = location!;
                          });
                        },
                        child: Text(
                          appLocalization.selectLocation,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                  ],
                ),
                Visibility(
                  visible: selectedLocation.latitude != 0.0,
                  child: TextButton(
                    onPressed: _useLocationData,
                    child: Text(appLocalization.useLocationData,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primarySwatch.shade500,
                            )),
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }
}
