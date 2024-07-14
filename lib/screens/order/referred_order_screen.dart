import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ewasfa/providers/user_data.dart';
import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:ewasfa/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../assets/app_data.dart';
import '../../helpers/location_helper.dart';
import '../../models/address.dart';
import '../../models/pharmacy.dart';
import '../../providers/addresses.dart';
import '../../providers/branches.dart';
import '../../widgets/map_widget.dart';
import '../add_new_address.dart';
import 'order_failed_screen.dart';
import 'order_successful_screen.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen through which the user can make a referred Order')
class ReferredOrderScreen extends StatefulWidget {
  static const routeName = '/referred_order';

  @override
  _ReferredOrderScreenState createState() => _ReferredOrderScreenState();
}

class _ReferredOrderScreenState extends State<ReferredOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  Map<String, dynamic>? _orderData;
  bool _isLoading = false;
  bool _isApiResponseSuccess = false; // New variable to track API response
  String _deliveryType = 'store';
  Address? _selectedAddress;
  late int userid;
  final TextEditingController _promoCodeController = TextEditingController();
  bool _branchesPickup = true;
  bool _branchesLoaded = false;
  bool _branchSelected = false;
  int _selectedIndex = -1;
  bool orderSelected = false;
  late Pharmacy selectedPharmacy;
  Map<Pharmacy, double> distBranches = {};
  List<Pharmacy> branches = [];
  LatLng userLatLng = LatLng(0.0, 0.0);
  Branches? branchesProvider;

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
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      print(int.parse(_codeController.text));
      final url = Uri.parse(
          '$apiUrl/show_orderById?order_id=${int.parse(_codeController.text)}');
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          setState(() {
            orderSelected = true;
            _orderData = {
              'id': responseData['order_data'][0]['id'],
              'state': responseData['order_data'][0]['state'],
              'first_name': responseData['patient_order'][0]['first_name'],
              'last_name': responseData['patient_order'][0]['last_name'],
              'phone': responseData['patient_order'][0]['phone'],
              'land_mark': responseData['patient_order'][0]['land_mark'],
              'delivery': responseData['patient_order'][0]['delivery'],
              'address': responseData['patient_order'][0]['address'],
              'city_arabicname': responseData['patient_order'][0]
                  ['city_arabicname'],
              'branch': responseData['patient_order'][0]['branch'],
              'longitude': responseData['patient_order'][0]['longitude'],
              'latitude': responseData['patient_order'][0]['latitude'],
              'image': responseData['order_details'],
            };
            print((_orderData!['image'][0]['image']));

            _isApiResponseSuccess =
                true; // Set the flag to true for successful response          
          });
        } else {
          // Request failed, handle the error
          _isApiResponseSuccess =
              false; // Set the flag to false for failed response
          orderSelected = false;
        }
      } catch (error) {
        // An error occurred, handle the exception
        print(error);
        _isApiResponseSuccess = false; // Set the flag to false for error
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildOrderDetailsCard(AppLocalizations appLocalization) {
    if (_orderData == null) {
      return Container();
    }

    final orderDetails = _orderData;
    final images = _orderData!['image'];
    List<String> imageLinks = [];
    for (var image in images) {
      imageLinks.add("$ordersImagesDirectory/${image['image']}");
    }
    return Card(color: Colors.white,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            appLocalization.reviewOrder,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        if (imageLinks != null && imageLinks.isNotEmpty)
          CarouselSlider(
              items: imageLinks
                  .map((item) => GestureDetector(
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: ClipRRect(
                    borderRadius:
                    const BorderRadius.all(Radius.circular(5.0)),
                    child: Stack(
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: item,
                          placeholder: (context, url) => const Center(
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballPulseSync,
                                colors: [primaryswatchAccent],
                              )),
                          imageBuilder: (context, imageProvider) =>
                              Container(
                                width: 1000.0,
                                decoration: BoxDecoration(
                                  color: const Color(0x00000000),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(200, 0, 0, 0),
                                  Color.fromARGB(0, 0, 0, 0)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pushNamed(
                      context, ZoomableImageScreen.routeName,
                      arguments: [
                        ZoomableImageSourceType.network,
                        item
                      ]);
                  try {} catch (e) {}
                },
              ))
                  .toList(),
              options: CarouselOptions()),
        SizedBox(height: 40.h,
          child: ListTile(
            trailing:  Text('${appLocalization.orderStatus}: ${orderDetails!['state']}'),
            title: Expanded(child: Text('${appLocalization.orderId}: ${orderDetails!['id']}')),
          ),
        ),
        ListTile(
          title: Text(
              '${appLocalization.pro_description}: ${orderDetails['pro_description']}'),
          trailing: Text(
              '${appLocalization.price}: ${orderDetails['price'] ?? 'N/A'}'),
        ),
        // ListTile(
        //   title: Text('Delivery: ${orderDetails['delivery']}'),
        //   subtitle: Text('Doctor ID: ${orderDetails['doctor_id']}'),
        // ),
        // Display images

      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);
    return Consumer2<LanguageProvider, UserData>(
        builder: (context, languageProvider, userProvider, _) {
      userid = userProvider.userId;
      return Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: languageProvider.currentLanguage == Language.arabic
              ? const Locale('ar')
              : const Locale('en'),
          child: Scaffold(backgroundColor: Colors.white,
            extendBodyBehindAppBar: true,
            appBar: CustomAppBar(pageTitle: appLocalization.referredOrder),
            body: Container(color: Colors.white,
                height:orderSelected? query.size.height:565.h,
                margin: orderSelected? EdgeInsets.only(top: query.size.height * 0.088):EdgeInsets.zero,
                child: Padding(
                    padding:  EdgeInsets.all(orderSelected?0.0:16.0),
                    child: Form(
                      key: _formKey,
                      child: Visibility(
                        visible: !orderSelected,
                        replacement: SingleChildScrollView(
                          child: SizedBox(
                            height: query.size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [

                                const SizedBox(height: 16.0),
                                if (_isLoading)
                                  const LoadingIndicator(
                                      indicatorType: Indicator.ballBeat,
                                      colors: [primarySwatch])
                                else if (orderSelected)
                                  SizedBox(
                                      height: query.size.height * 0.9,
                                      child: ListView(
                                          padding: EdgeInsets.zero,
                                          children: [
                                            _buildOrderDetailsCard(
                                                appLocalization),
                                            Card(color: Colors.white,
                                              child: Padding(
                                                padding:
                                                     EdgeInsets
                                                        .only(bottom: 15.h,right: 15.w,left: 15.w),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Visibility(
                                                        visible:
                                                            _isApiResponseSuccess,
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                                  .only(
                                                              top: 10.0,
                                                              bottom:
                                                                  10.0),
                                                          child: Text(
                                                              appLocalization
                                                                  .selectAddressBranch),
                                                        )),
                                                    TextFormField(
                                                        controller:
                                                            _promoCodeController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              appLocalization
                                                                  .promocode,
                                                          border:
                                                              const OutlineInputBorder(),
                                                        )),
                                                    const SizedBox(
                                                        height: 20),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                              RadioListTile(
                                                            title: Text(
                                                                appLocalization
                                                                    .pickFromStore,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyMedium),
                                                            value:
                                                                'store',
                                                            groupValue:
                                                                _deliveryType,
                                                            onChanged:
                                                                (value) {
                                                              setState(
                                                                  () {
                                                                _branchesPickup =
                                                                    true;
                                                                _deliveryType =
                                                                    value
                                                                        as String;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child:
                                                              RadioListTile(
                                                            title: Text(
                                                                appLocalization
                                                                    .delivery,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .bodyMedium),
                                                            value:
                                                                'delivery',
                                                            groupValue:
                                                                _deliveryType,
                                                            onChanged:
                                                                (value) {
                                                              setState(
                                                                  () {
                                                                _selectedIndex =
                                                                    -1;
                                                                _branchesPickup =
                                                                    false;
                                                                _branchSelected =
                                                                    false;
                                                                _deliveryType =
                                                                    value
                                                                        as String;
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    // Visibility(
                                                    //     visible:
                                                    //         _isApiResponseSuccess,
                                                    //     child: Padding(
                                                    //       padding: const EdgeInsets
                                                    //               .only(
                                                    //           top: 10.0,
                                                    //           bottom:
                                                    //               10.0),
                                                    //       child: Text(
                                                    //           appLocalization
                                                    //               .addPrescription),
                                                    //     )),
                                                    Visibility(
                                                      visible:
                                                          _deliveryType ==
                                                              'delivery',
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        primarySwatch.shade500),
                                                                onPressed:
                                                                    () {
                                                                  showAddressSheet(
                                                                      appLocalization);
                                                                },
                                                                child: Text(
                                                                    appLocalization.chooseAddress,
                                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.black,
                                                                        )),
                                                              ),
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    backgroundColor:
                                                                        primarySwatch.shade500),
                                                                onPressed:
                                                                    () {
                                                                  Navigator.of(context)
                                                                      .pushNamed(NewAddressScreen.routeName);
                                                                },
                                                                child: Text(
                                                                    appLocalization.addNewAddress,
                                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.black,
                                                                        )),
                                                              ),
                                                            ],
                                                          ),
                                                          if (_selectedAddress !=
                                                              null) ...[
                                                            const SizedBox(
                                                                height:
                                                                    20),
                                                            Text(
                                                                '${appLocalization.city} ${_selectedAddress?.city}'),
                                                            const SizedBox(
                                                                height:
                                                                    8),
                                                            Text(
                                                                '${appLocalization.addressLine} ${_selectedAddress?.addressLine}'),
                                                            const SizedBox(
                                                                height:
                                                                    8),
                                                            Text(
                                                                '${appLocalization.landmark} ${_selectedAddress?.landmark}'),
                                                            ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.black,
                                                                        ),
                                                                    backgroundColor: primarySwatch.shade500),
                                                                onPressed: () async {
                                                                  if (_selectedAddress !=
                                                                      null) {
                                                                    // Get the necessary details for the request
                                                                    int userId =
                                                                        userid;
                                                                    //String imagePath = _images?.first.path ?? '';
                                                                    String
                                                                        promoCode =
                                                                        _promoCodeController.text;
                                                                    bool
                                                                        isDelivery =
                                                                        _deliveryType == 'delivery';
                                                                    int addressId = isDelivery
                                                                        ? _selectedAddress!.id
                                                                        : 0;
                                                                    String address = isDelivery
                                                                        ? _selectedAddress!.addressLine
                                                                        : '';
                                                                    String city = isDelivery
                                                                        ? _selectedAddress!.city
                                                                        : '';
                                                                    double longitude = isDelivery
                                                                        ? _selectedAddress!.longitude
                                                                        : 0.0;
                                                                    double latitude = isDelivery
                                                                        ? _selectedAddress!.latitude
                                                                        : 0.0;
                                                                    String landmark = isDelivery
                                                                        ? _selectedAddress!.landmark
                                                                        : '';
                                                                    int referredUserId =
                                                                        1;

                                                                    // Create the request body
                                                                    Map<String, dynamic>
                                                                        requestBody =
                                                                        {
                                                                      'user_id': userId,
                                                                      // 'image': imagePath,
                                                                      'promo_code': promoCode,
                                                                      'delivery': isDelivery ? 1 : 0,
                                                                      'address_id': addressId,
                                                                      'address': address,
                                                                      'city': city,
                                                                      'long': longitude,
                                                                      'lat': latitude,
                                                                      'land_mark': landmark,
                                                                      'refered': referredUserId,
                                                                    };

                                                                    makeOrderRequest(requestBody,
                                                                        _orderData!['image']);
                                                                  }
                                                                },
                                                                child: Text(appLocalization.placeOrder,
                                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                          fontWeight: FontWeight.bold,
                                                                          color: Colors.black,
                                                                        ))),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _branchSelected &&
                                                              _isApiResponseSuccess,
                                                      child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                    color:
                                                                        Colors.black,
                                                                  ),
                                                              backgroundColor: primarySwatch.shade500),
                                                          onPressed: () async {
                                                            int userId =
                                                                userid;
                                                            String
                                                                promoCode =
                                                                _promoCodeController
                                                                    .text;
                                                            int referredUserId =
                                                                1;
                                                            Map<String,
                                                                    dynamic>
                                                                requestBody =
                                                                {
                                                              'user_id':
                                                                  userId,
                                                              'promo_code':
                                                                  promoCode,
                                                              'delivery':
                                                                  1,
                                                              'address_id':
                                                                  selectedPharmacy
                                                                      .address
                                                                      .id,
                                                              'address': selectedPharmacy
                                                                  .address
                                                                  .addressLine,
                                                              'city': selectedPharmacy
                                                                  .address
                                                                  .city,
                                                              'long': selectedPharmacy
                                                                  .address
                                                                  .longitude,
                                                              'lat': selectedPharmacy
                                                                  .address
                                                                  .latitude,
                                                              'land_mark': selectedPharmacy
                                                                  .address
                                                                  .landmark,
                                                              'refered':
                                                                  referredUserId,
                                                            };
                                                            makeOrderRequest(
                                                                requestBody,
                                                                _orderData![
                                                                    'image']);
                                                          },
                                                          child: Text(appLocalization.placeOrder,
                                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                    color:
                                                                        Colors.black,
                                                                  ))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                                visible:
                                                    _branchesPickup,
                                                child: Consumer<
                                                        Branches>(
                                                    builder: (context,
                                                        branchesProvider,
                                                        _) {
                                                  return Builder(
                                                      builder: (
                                                    context,
                                                  ) {
                                                    if (branchesProvider
                                                        .isBranchesLoaded()) {
                                                      final List<
                                                              Pharmacy>
                                                          branches =
                                                          branchesProvider
                                                              .getBranches();
                                                      if (branches
                                                          .isEmpty) {
                                                        return Center(
                                                            child: Text(
                                                                appLocalization
                                                                    .noBranchesMsg));
                                                      } else {
                                                        return Center(
                                                          child:
                                                              Padding(
                                                            padding: const EdgeInsets
                                                                    .only(
                                                                top:
                                                                    10.0),
                                                            child:
                                                                Container(color: Colors.white,
                                                              width: query
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              height: query
                                                                      .size
                                                                      .height *
                                                                  0.3,
                                                              child: ListView
                                                                  .builder(physics: NeverScrollableScrollPhysics(),
                                                                padding:
                                                                    EdgeInsets.zero,
                                                                itemCount:
                                                                    branches.length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  final pharmacy =
                                                                      branches[index];
                                                                  final name = languageProvider.currentLanguage == Language.arabic
                                                                      ? pharmacy.arabicName
                                                                      : pharmacy.englishName;
                                                                  final addressLine = pharmacy
                                                                      .address
                                                                      .addressLine;
                                                                  final isSelected =
                                                                      _selectedIndex == index;
                                                                  return Container(
                                                                    clipBehavior: Clip
                                                                        .antiAliasWithSaveLayer,
                                                                    decoration: BoxDecoration(
                                                                      color: !isSelected
                                                                          ? Theme.of(context)
                                                                          .listTileTheme
                                                                          .tileColor
                                                                          : primarySwatch
                                                                          .shade400,
                                                                      borderRadius:
                                                                      BorderRadius.circular(
                                                                          20.sp),
                                                                    ),
                                                                    alignment: Alignment.center,
                                                                    height: 80.h,
                                                                    child: ListTile(
                                                                      leading:
                                                                          const Icon(Icons.local_pharmacy),
                                                                      trailing: branches[index].address.latitude == 0.0
                                                                          ? null
                                                                          : SizedBox(
                                                                              width: 90,
                                                                              child: Visibility(
                                                                                visible: userLatLng != const LatLng(0.0, 0.0),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      height: 50,
                                                                                      width: 100,
                                                                                      child: Center(
                                                                                        child: Flex(direction: Axis.vertical, children: [
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
                                                                          ? Theme.of(context).listTileTheme.tileColor
                                                                          : primarySwatch.shade900,
                                                                      title:
                                                                          Text(name, style: !isSelected ? Theme.of(context).textTheme.bodyLarge : Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black)),
                                                                      subtitle:
                                                                          Text(addressLine, style: !isSelected ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black)),
                                                                      onTap:
                                                                          () {
                                                                        setState(() {
                                                                          {
                                                                            _branchSelected = true;
                                                                            _selectedIndex = index; // Update selected index
                                                                            selectedPharmacy = branches[index];
                                                                          }
                                                                        });
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      return Center(
                                                        child: Transform
                                                            .scale(
                                                          scale: 0.5,
                                                          child: const LoadingIndicator(
                                                              indicatorType:
                                                                  Indicator.ballBeat,
                                                              colors: [
                                                                primarySwatch
                                                              ]),
                                                        ),
                                                      );
                                                    }
                                                  });
                                                }))
                                          ]))else SizedBox()
                              ],
                            ),
                          ),
                        ),
                        child:  Padding(
                          padding:  EdgeInsets.only(top: 330.h,),
                          child: Container(


                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(15.sp),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 5,
                                  blurRadius: 4,
                                  offset: Offset(0,
                                      2), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(top: 15.0.h,right: 20.w,left: 20.w
                                  ),
                                  child: CustomTextFormField(
                                    enabledBorder:  OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10.sp),
                                                                borderSide: BorderSide(

                                    color:Colors.black.withOpacity(0.4),
                                    width: 2.5.sp )),
                                    controller: _codeController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return appLocalization.enterCode;
                                      }
                                      return null;
                                    },
                                    hintText:
                                    appLocalization.enterCode,
                                    textInputType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization: TextCapitalization.words,
                                  ),
                                ),

                                Padding(
                                  padding:  EdgeInsets.only(right: 10.0.w,left:10.0.w,top:15.0.h  ),
                                  child: GestureDetector(
                                    onTap: _submitForm,
                                    child: Container(
                                      height: 60.h,
                                      width: MediaQuery.of(context).size.width - 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15.sp),
                                          color: Colors.black,
                                          border: Border.all(color: Colors.black, width: 3)),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                              appLocalization.submit,
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

                              ],
                            ),
                          ),
                        ),
                      ),
                    ))),
          ));
    });
  }

  Future<List<Pharmacy>> getBranches() async {
    List<Pharmacy> pharmacies = [];
    const url = "$apiUrl/show_branches";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;

        if (extractedData.isEmpty) {
          return [];
        }
        final List extractedOffers = extractedData.values.toList()[0];
        for (int i = 0; i < extractedOffers.length; i++) {
          final Map<String, dynamic> map = extractedOffers[i];
          pharmacies.add(Pharmacy(
              address: Address(
                  addressLine: map["address"] ?? "",
                  city: "Jeddah",
                  id: -1,
                  landmark: "",
                  latitude: double.parse(map["latitude"] ?? "0.0"),
                  longitude: double.parse(map["longitude"] ?? "0.0")),
              arabicName: map["a_name"] ?? "",
              englishName: map["E_name"] ?? "",
              id: map["id"]));
        }
        _branchesLoaded = true;
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (error) {
      rethrow;
    }

    return pharmacies;
  }

  void showAddressSheet(AppLocalizations appLocalization) {
    final query = MediaQuery.of(context);
    showModalBottomSheet(
      context: context,
      // isScrollControlled: true,
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

  void makeOrderRequest(Map<String, dynamic> requestBody, imageData) async {
    // Create a multipart request for image upload
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/make_userOrderdetails'),
    );
    // Add other form fields

    request.fields.addAll(
        requestBody.map((key, value) => MapEntry(key, value.toString())));

    for (var image in imageData) {
      final response =
          await http.get(Uri.parse("$ordersImagesDirectory/${image['image']}"));
      final imageDateProcessed = response.bodyBytes;
      // Add the image file to the request
      request.files.add(http.MultipartFile.fromBytes(
          'image[]', imageDateProcessed,
          filename: image['image']));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        // Process the response
        final responseData = await response.stream.bytesToString();

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
      print(error);
      // Error occurred while making the order request
      // Handle the error here
    }
  }

  void _saveAddress(Address enteredAddress) {
    setState(() {
      _selectedAddress = enteredAddress;
    });
  }

  void showBottomSheet(AppLocalizations appLocalization) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<Addresses>(
          builder: (context, addressesData, child) {
            if (!addressesData.isInitialized) {
              return const LoadingIndicator(
                  indicatorType: Indicator.ballBeat, colors: [primarySwatch]);
            }
            List<Address> addresses = addressesData.getaddresses();
            var userid = addressesData.userId;

            // Create a list of ListTile widgets for each address.
            List<ListTile> listTiles = addresses.map((address) {
              return ListTile(
                title: Text(address.landmark),
                subtitle: Text(address.addressLine),
                onTap: () {
                  setState(() {
                    _selectedAddress = address;
                    Navigator.pop(context);
                  });
                },
              );
            }).toList();

            return SizedBox(
              height: 250,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      appLocalization.chooseAddress,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ...listTiles,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
