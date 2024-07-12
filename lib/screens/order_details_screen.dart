import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ewasfa/screens/app_layout_screen.dart';
import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:ewasfa/widgets/image_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../assets/app_data.dart';
import '../helpers/location_helper.dart';
import '../models/order.dart';
import '../models/pharmacy.dart';
import '../providers/branches.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';

import '../widgets/map_widget.dart';

@Category(<String>['Screens'])
@Summary(
    'The Screen through which the user can view the details of a previous order')
class PreviousOrderDetailsScreen extends StatefulWidget {
  static const routeName = '/previous_order_details';

  PreviousOrderDetailsScreen();

  @override
  State<PreviousOrderDetailsScreen> createState() =>
      _PreviousOrderDetailsScreenState();
}

class _PreviousOrderDetailsScreenState
    extends State<PreviousOrderDetailsScreen> {
  late final Order order;
  bool orderLoaded = false;
  bool imagesLoaded = false;
  List<String> images = [];
  double branchDistance = 0.0;
  bool isPickup = false;
  late final LatLng userLoc;
  late Pharmacy branch;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    order = ModalRoute.of(context)!.settings.arguments as Order;
    print("Pharmacy ID: ${order.pharmacyId}");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (order.pharmacyId != 0) {
        isPickup = true;
        final branchesProvider = Provider.of<Branches>(context, listen: false);
        final userLoc = await LocationHelper.getCurrentUserLatLng();
        branch = branchesProvider.getBranchById(order.pharmacyId);
        setState(() {
          branchDistance = LocationHelper.calculateDistance(
              userLoc.latitude,
              userLoc.longitude,
              branch.address.latitude,
              branch.address.longitude);
        });
      }
    });
    orderLoaded = true;
    getOrderImages(order);
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: orderLoaded
            ? Scaffold(
                extendBodyBehindAppBar: true,
                appBar: CustomAppBar(pageTitle: appLocalization.orderInfo,
                ),
                body: Container(
                  margin: EdgeInsets.only(top: query.size.height * 0.15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 30.0),
                                child: Text(
                                  "${appLocalization.orderId}: ${order.orderId}",
                                  style: Theme.of(context).textTheme.
                                  titleLarge ?.copyWith(
                                    color:  Colors.black,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,)
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(appLocalization.price,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            Text(
                                              "SAR ${order.price.toString()}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(appLocalization.orderStatus,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            Text(
                                              order.status,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    const Padding(padding: EdgeInsets.all(10)),
                                    Visibility(
                                        visible: order.doctorName != "",
                                        child: Column(
                                          children: [
                                            Text(appLocalization.doctorName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            Text(
                                              order.pro_description == ''
                                                  ? appLocalization.none
                                                  : order.doctorName,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            Text(
                                                appLocalization.pro_description,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                            Text(
                                              order.pro_description == ''
                                                  ? appLocalization.none
                                                  : order.pro_description,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          ],
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(appLocalization.orderNotes,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ),
                                    Text(
                                        order.notes == ''
                                            ? appLocalization.none
                                            : order.notes,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                    Visibility(
                                        visible: isPickup,
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: SizedBox(
                                                width: 250,
                                                child: ElevatedButton(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                            Icons.directions,
                                                            color:
                                                                Colors.black),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0,
                                                                  left: 8.0),
                                                          child: Text(
                                                              appLocalization
                                                                  .directionsToBranch,
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
                                                                  )),
                                                        ),
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      if (Platform.isAndroid) {
                                                        AndroidIntent
                                                            mapIntent =
                                                            AndroidIntent(
                                                                action:
                                                                    'action_view',
                                                                package:
                                                                    'com.google.android.apps.maps',
                                                                data:
                                                                    'google.navigation:q=${branch.address.latitude},${branch.address.longitude}');
                                                        mapIntent.launch();
                                                      } else {
                                                        Navigator.pushNamed(
                                                            context,
                                                            MapScreen.routeName,
                                                            arguments: {
                                                              "mode": MapMode
                                                                  .navigation,
                                                              "latLng": LatLng(
                                                                  branch.address
                                                                      .latitude,
                                                                  branch.address
                                                                      .longitude)
                                                            });
                                                      }
                                                    }),
                                              ),
                                            ),
                                            Text(
                                                "${appLocalization.far} ${branchDistance.toStringAsFixed(2)} ${appLocalization.kilometers}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(fontSize: 12)),
                                          ],
                                        ))
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  appLocalization.prescriptionImage,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: imagesLoaded
                                    ? SizedBox(
                                        height: query.size.height * 0.45,
                                        width: query.size.width * 0.95,
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: images.length,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: ClippedOfferImage(
                                                query: query,
                                                imageUrl: images[index],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Transform.scale(
                                        scale: 0.5,
                                        child: const LoadingIndicator(
                                          indicatorType: Indicator.ballBeat,
                                          colors: [primarySwatch],
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
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
              ),
      );
    });
  }

  Future<void> getOrderImages(Order oder) async {
    Logger logger = Logger();
    final url =
        "$apiUrl/show_orderimages?order_id=${order.orderId}";
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData.isEmpty) {
      return;
    }
    final List extractedImages = extractedData.values.toList()[0];
    for (int i = 0; i < extractedImages.length; i++) {
      final Map<String, dynamic> map = extractedImages[i];
      images.add(map["image"]);
      logger.d(images);
    }
    setState(() {
      imagesLoaded = true;
    });
  }
}

class ClippedOfferImage extends StatelessWidget {
  const ClippedOfferImage(
      {super.key, required this.query, required this.imageUrl});

  final MediaQueryData query;
  final imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, ZoomableImageScreen.routeName,
              arguments: [
                ZoomableImageSourceType.network,
                "$ordersImagesDirectory/$imageUrl"
              ]);
        },
        child: CachedNetworkImage(
          height: query.size.height * 0.3,
          width: query.size.width * 0.9,
          imageUrl: "$ordersImagesDirectory/$imageUrl",
          fit: BoxFit.fill,
          placeholder: (context, url) =>  Center(
              child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [primarySwatch])),
          errorWidget: (context, url, error) =>  Image.asset(
            "lib/assets/images/not_found.png",
          ),),
      ),
    );
  }
}
