import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:ewasfa/screens/add_new_address.dart';
import 'package:ewasfa/screens/order/order_failed_screen.dart';
import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:ewasfa/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../../assets/app_data.dart';
import '../../helpers/location_helper.dart';
import '../../models/address.dart';
import '../../models/pharmacy.dart';
import '../../providers/addresses.dart';
import '../../providers/auth.dart';
import '../../providers/branches.dart';
import 'order_successful_screen.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The screen through which the patient can make a new order')
class NewOrderScreen extends StatefulWidget {
  static const routeName = '/new_order';

  const NewOrderScreen({Key? key}) : super(key: key);

  @override
  _NewOrderScreenState createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  List<XFile> _images = [];
  final picker = ImagePicker();
  final TextEditingController _promoCodeController = TextEditingController();
  String _deliveryType = 'store';
  Address? _selectedAddress;
  late int userid;
  bool _branchesPickup = true;
  bool _branchSelected = false;
  bool _branchesLoaded = false;
  int _selectedIndex = -1;
  late Pharmacy selectedPharmacy;
  Map<Pharmacy, double> distBranches = {};
  List<Pharmacy> branches = [];
  LatLng userLatLng = LatLng(0.0, 0.0);
  Branches? branchesProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Execute setState after the widget has completely built
      branchesProvider ??= Provider.of<Branches>(context, listen: false);
      if (branchesProvider != null) {
        if (branchesProvider!.isBranchesLoaded()) {
          final List<Pharmacy> retBranches = branchesProvider!.getBranches();
          setState(() {
            branches = retBranches;
          });
          if (userLatLng == const LatLng(0.0, 0.0)) {
            LocationHelper.getCurrentUserLatLng().then((value) {              
              if (value != const LatLng(0.0, 0.0)) {
                setState(() {
                  userLatLng = value;
                  branchesProvider?.sortBranchesByDistance(userLatLng);
                  branchesProvider?.calculateBranchDistances(userLatLng);
                  var distances = branchesProvider?.getDistancesFromUser();
                  distBranches = distances!;
                  if (distBranches.isNotEmpty) {
                    _branchesLoaded = true;
                  }
                });
              }
            });
          }
        } else {
          branchesProvider?.fetchBranches();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer2<Auth, LanguageProvider>(
      builder: (context, authProvider, languageProvider, _) {
        userid = authProvider.userId;
        return Localizations(
            delegates: AppLocalizations.localizationsDelegates,
            locale: languageProvider.currentLanguage == Language.arabic
                ? const Locale('ar')
                : const Locale('en'),
            child: Scaffold(
                extendBodyBehindAppBar: true,
                appBar: CustomAppBar(pageTitle: appLocalization.newOrder),
                body: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Container(
                          margin: EdgeInsets.only(top: query.size.height * 0.1),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _showImageSourceSheet,
                                  child: SizedBox(
                                      width: double.infinity,
                                      height: 200,
                                      child: _images.isEmpty
                                          ? const Icon(Icons.add_a_photo,
                                              size: 50)
                                          : CustomScrollView(
                                              slivers: [
                                                SliverGrid(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                  ),
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                    (BuildContext context,
                                                        int index) {
                                                      if (index <
                                                          _images.length) {
                                                        final image =
                                                            _images[index];
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              InkWell(
                                                                onTap: () => Navigator.pushNamed(
                                                                    context,
                                                                    ZoomableImageScreen
                                                                        .routeName,
                                                                    arguments: [
                                                                      ZoomableImageSourceType
                                                                          .file,
                                                                      image.path
                                                                    ]),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image: FileImage(
                                                                          File(image
                                                                              .path)),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child:
                                                                    IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      _images.remove(
                                                                          image);
                                                                    });
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .grey,
                                                                    shadows: [
                                                                      Shadow(
                                                                          blurRadius:
                                                                              2,
                                                                          offset: const Offset(
                                                                              0,
                                                                              1),
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(0.7))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      } else {
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1.0,
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                              Icons
                                                                  .add_a_photo),
                                                        );
                                                      }
                                                    },
                                                    childCount:
                                                        _images.length + 1,
                                                  ),
                                                ),
                                              ],
                                            )),
                                ),
                                const SizedBox(height: 20),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Visibility(
                                            visible: _images.isNotEmpty,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              child: Text(appLocalization
                                                  .selectAddressBranch),
                                            )),
                                        TextFormField(
                                            controller: _promoCodeController,
                                            decoration: InputDecoration(
                                              labelText:
                                                  appLocalization.promocode,
                                              border:
                                                  const OutlineInputBorder(),
                                            )),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: RadioListTile(
                                                title: Text(appLocalization
                                                    .pickFromStore),
                                                value: 'store',
                                                groupValue: _deliveryType,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _branchesPickup = true;
                                                    _deliveryType =
                                                        value as String;
                                                  });
                                                },
                                              ),
                                            ),
                                            Expanded(
                                              child: RadioListTile(
                                                title: Text(
                                                    appLocalization.delivery),
                                                value: 'delivery',
                                                groupValue: _deliveryType,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedIndex = -1;
                                                    _branchesPickup = false;
                                                    _branchSelected = false;
                                                    _deliveryType =
                                                        value as String;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                            visible: _images.isEmpty,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              child: Text(appLocalization
                                                  .addPrescription),
                                            )),
                                        Visibility(
                                          visible: _deliveryType == 'delivery',
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      showAddressSheet(
                                                          appLocalization);
                                                    },
                                                    child: Text(
                                                      appLocalization
                                                          .chooseAddress,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      final args = await Navigator
                                                              .of(context)
                                                          .pushNamed(
                                                              NewAddressScreen
                                                                  .routeName)
                                                          .then((value) =>
                                                              value as Address);
                                                      setState(() {
                                                        _selectedAddress = args;
                                                      });
                                                    },
                                                    child: Text(
                                                        appLocalization
                                                            .addNewAddress,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black,
                                                            )),
                                                  ),
                                                ],
                                              ),
                                              if (_selectedAddress != null)
                                                SizedBox(
                                                  width: query.size.width * 0.9,
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 20),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    appLocalization
                                                                        .city,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                Text(
                                                                    _selectedAddress
                                                                            ?.city ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    appLocalization
                                                                        .addressLine,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: languageProvider.currentLanguage ==
                                                                            Language
                                                                                .arabic
                                                                        ? const EdgeInsets.only(
                                                                            right:
                                                                                50.0)
                                                                        : const EdgeInsets.only(
                                                                            left:
                                                                                50.0),
                                                                    child: Text(
                                                                        _selectedAddress?.addressLine ??
                                                                            "",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .bodyMedium),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    appLocalization
                                                                        .landmark,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        )),
                                                                Text(
                                                                    _selectedAddress
                                                                            ?.landmark ??
                                                                        "",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyMedium),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            _images.isNotEmpty,
                                                        child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium
                                                                        ?.copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.black,
                                                                        ),
                                                                    backgroundColor:
                                                                        primarySwatch
                                                                            .shade500),
                                                            onPressed: () {
                                                              if (_selectedAddress !=
                                                                  null) {
                                                                // Get the necessary details for the request
                                                                int userId =
                                                                    userid;
                                                                //String imagePath = _images?.first.path ?? '';
                                                                String
                                                                    promoCode =
                                                                    _promoCodeController
                                                                        .text;
                                                                bool
                                                                    isDelivery =
                                                                    _deliveryType ==
                                                                        'delivery';
                                                                int addressId =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .id
                                                                        : 0;
                                                                String address =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .addressLine
                                                                        : '';
                                                                String city =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .city
                                                                        : '';
                                                                double
                                                                    longitude =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .longitude
                                                                        : 0.0;
                                                                double
                                                                    latitude =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .latitude
                                                                        : 0.0;
                                                                String
                                                                    landmark =
                                                                    isDelivery
                                                                        ? _selectedAddress!
                                                                            .landmark
                                                                        : '';
                                                                int referredUserId =
                                                                    0;

                                                                // Create the request body
                                                                Map<String,
                                                                        dynamic>
                                                                    requestBody =
                                                                    {
                                                                  'user_id':
                                                                      userId,
                                                                  'promo_code':
                                                                      promoCode,
                                                                  'delivery': 1,
                                                                  'address_id':
                                                                      addressId,
                                                                  'address':
                                                                      address,
                                                                  'city': city,
                                                                  'long':
                                                                      longitude,
                                                                  'lat':
                                                                      latitude,
                                                                  'land_mark':
                                                                      landmark,
                                                                  'refered':
                                                                      referredUserId,
                                                                };

                                                                makeOrderRequest(
                                                                    requestBody,
                                                                    _images);
                                                              }
                                                            },
                                                            child: Text(
                                                                appLocalization
                                                                    .placeOrder,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleMedium
                                                                    ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black,
                                                                    ))),
                                                      )
                                                    ],
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: _branchSelected &&
                                              _images.isNotEmpty,
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  textStyle: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                  backgroundColor:
                                                      primarySwatch.shade500),
                                              onPressed: () {
                                                int userId = userid;
                                                //String imagePath = _images?.first.path ?? '';
                                                String promoCode =
                                                    _promoCodeController.text;
                                                int referredUserId = 0;
                                                Map<String, dynamic>
                                                    requestBody = {
                                                  'user_id': userId,
                                                  'promo_code': promoCode,
                                                  'address_id': selectedPharmacy
                                                      .address.id,
                                                  'branch_id':
                                                      selectedPharmacy.id,
                                                  'address': selectedPharmacy
                                                      .address.addressLine,
                                                  'city': selectedPharmacy
                                                      .address.city,
                                                  'long': selectedPharmacy
                                                      .address.longitude,
                                                  'lat': selectedPharmacy
                                                      .address.latitude,
                                                  'land_mark': selectedPharmacy
                                                      .address.landmark,
                                                  'refered': referredUserId,
                                                };
                                                makeOrderRequest(
                                                    requestBody, _images);
                                              },
                                              child: Text(
                                                  appLocalization.placeOrder,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ))),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                    visible: _branchesPickup,
                                    child: Builder(builder: (
                                      context,
                                    ) {
                                      // If branches are retrievable, sort them by distance to user and retrieve them.
                                      if (branches.isEmpty) {
                                        return Center(
                                            child: Text(
                                                appLocalization.noBranchesMsg));
                                      } else {
                                        return Center(
                                          child: SizedBox(
                                            width: query.size.width * 0.9,
                                            height: query.size.height * 0.3,
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: branches.length,
                                              itemBuilder: (context, index) {
                                                final pharmacy =
                                                    branches[index];
                                                final name = languageProvider
                                                            .currentLanguage ==
                                                        Language.arabic
                                                    ? pharmacy.arabicName
                                                    : pharmacy.englishName;
                                                final addressLine = pharmacy
                                                    .address.addressLine;
                                                final isSelected =
                                                    _selectedIndex == index;
                                                return Container(
                                                  alignment: Alignment.center,
                                                  height: 70,
                                                  child: ListTile(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    leading: const Icon(
                                                        Icons.local_pharmacy),
                                                    trailing: branches[index]
                                                                .address
                                                                .latitude ==
                                                            0.0
                                                        ? null
                                                        : SizedBox(
                                                            width: 90,
                                                            child: Visibility(
                                                              visible: userLatLng != const LatLng(0.0,0.0),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 50,
                                                                    width: 100,
                                                                    child: Center(
                                                                      child: Flex(
                                                                          direction:
                                                                              Axis.vertical,
                                                                          children: [
                                                                            Expanded(
                                                                              child: IconButton(
                                                                                  padding: EdgeInsets.zero,
                                                                                  icon: const Icon(Icons.directions),
                                                                                  onPressed: () {
                                                                                    if (Platform.isAndroid) {
                                                                                      AndroidIntent mapIntent = AndroidIntent(action: 'action_view', package: 'com.google.android.apps.maps', data: 'google.navigation:q=${branches[index].address.latitude},${branches[index].address.longitude}');
                                                                                      mapIntent.launch();
                                                                                    } else {
                                                                                      Navigator.pushNamed(context, MapScreen.routeName, arguments: {
                                                                                        "mode": MapMode.navigation,
                                                                                        "latLng": LatLng(branches[index].address.latitude, branches[index].address.longitude)
                                                                                      });
                                                                                    }
                                                                                  }),
                                                                            ),
                                                                            _branchesLoaded
                                                                                ? Expanded(
                                                                                    child: Text("${appLocalization.far} ${distBranches.values.elementAt(index).toStringAsFixed(2)} ${appLocalization.kilometers}", style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
                                                                                  )
                                                                                : Container()
                                                                          ]),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                    tileColor: !isSelected
                                                        ? Theme.of(context)
                                                            .listTileTheme
                                                            .tileColor
                                                        : primarySwatch
                                                            .shade900,
                                                    title: Text(name,
                                                        style: !isSelected
                                                            ? Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.copyWith(
                                                                    color: Colors
                                                                        .black)),
                                                    subtitle: Text(addressLine,
                                                        style: !isSelected
                                                            ? Theme.of(context)
                                                                .textTheme
                                                                .bodySmall
                                                            : Theme.of(context)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: Colors
                                                                        .black)),
                                                    onTap: () {
                                                      setState(() {
                                                        {
                                                          _branchSelected =
                                                              true;
                                                          _selectedIndex =
                                                              index; // Update selected index
                                                          selectedPharmacy =
                                                              branches[index];
                                                        }
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    }))
                              ]))),
                )));
      },
    );
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
                          _images.add(pickedImage);
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
                      final pickedImages = await picker.pickMultiImage();
                      setState(() {
                        _images = pickedImages;
                      });
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

  Future<XFile> _resizeImage(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final originalImage = img.decodeImage(bytes);

    const desiredImageSize = 200; // Change this to your desired image size

    final resizedImage = img.copyResize(originalImage!,
        width: desiredImageSize, height: desiredImageSize);
    final resizedBytes = img.encodeJpg(resizedImage);

    final resizedFile = await file.writeAsBytes(resizedBytes);
    return XFile(resizedFile.path);
  }

  void showAddressSheet(AppLocalizations appLocalization) {
    final query = MediaQuery.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Consumer<Addresses>(
          builder: (context, addressesData, child) {
            if (!addressesData.isInitialized) {
              return const LoadingIndicator(
                  indicatorType: Indicator.ballBeat, colors: [primarySwatch]);
            }
            List<Address> addresses = addressesData.getaddresses();
            return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.7, // 70% of the screen height
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        appLocalization.chooseAddress,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        Address address = addresses[index];
                        return ListTile(
                          title:
                              Text("${address.addressLine}, ${address.city}"),
                          subtitle: Text(address.landmark),
                          onTap: () {
                            setState(() {
                              _selectedAddress = address;
                              Navigator.pop(context);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveAddress(Address enteredAddress) {
    setState(() {
      _selectedAddress = enteredAddress;
    });
  }

  void makeOrderRequest(
      Map<String, dynamic> requestBody, List<XFile> imageFiles) async {
    print(imageFiles[0].path);
    const url = '$apiUrl/make_userOrderdetails';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(
          requestBody.map((key, value) => MapEntry(key, value.toString())));

      // Add the image files to the request
      for (int i = 0; i < imageFiles.length; i++) {
        var imageFile = imageFiles[i];

        final imageStream = http.ByteStream(imageFile.openRead());
        final imageLength = await imageFile.length();
        final imageUpload = http.MultipartFile(
          'image[]',
          imageStream,
          imageLength,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(imageUpload);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        // Process the response
        final responseData =
            await response.stream.transform(utf8.decoder).join();
        final parsedResponse = json.decode(responseData);

        if (parsedResponse['error'] == 0) {
          // Order inserted successfully
          final orderData = parsedResponse['order_data'];
          // Handle the order data
          // ...

          if (parsedResponse['message'] != null) {
            // Display success message to the user
            final successMessage = parsedResponse['message'];
            print(successMessage);
            // ...
          }
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => OrderSuccessfulScreen()),
            ModalRoute.withName('/'),
          );
        } else {
          // Order insertion failed
          if (parsedResponse['message'] != null) {
            // Display error message to the user
            final errorMessage = parsedResponse['message'];
            print(errorMessage);
            // ...
          }
        }
      } else {
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => OrderFailedScreen()),
          ModalRoute.withName('/'),
        );
        // Order request failed
        // Handle the error response here if needed
      }
    } catch (error) {
      rethrow;
      // Error occurred while making the order request
      // Handle the error here
    }
  }
}
