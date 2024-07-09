import 'dart:async';
import 'dart:math';

import 'package:ewasfa/providers/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../assets/app_data.dart';
import '../helpers/location_helper.dart';
import 'custom_app_bar.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('A widget that allows the user to select their location')
class MapScreen extends StatefulWidget {
  static const String routeName = "/map_screen";
  late LatLng navToLocation;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapMode _mapMode = MapMode.pickLocation;
  Map<PolylineId, Polyline> polylines = {};
  final Completer<GoogleMapController?> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  LatLng curLocation = LatLng(23.075, 72.56667),
      destination = LatLng(23.075, 72.56667);
  Marker? sourceMarker, destinationMarker;
  late LatLng _pickedLocation;
  bool locationAcquired = false;
  late TextEditingController addressController;
  Location location = Location();
  late StreamSubscription<LocationData> locationSubscriber;
  bool permissionState = false;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    permissionState = await LocationHelper.getPermissionState();
    if (permissionState == false)
    {
      setState(() {
        _pickedLocation = curLocation;
        locationAcquired = true;
      });
    }
    var argsList =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _pickedLocation = await LocationHelper.getCurrentUserLatLng();
    if (_pickedLocation != null) {
      addressController.text = await LocationHelper.getPlaceAddress(
          _pickedLocation.latitude, _pickedLocation.longitude);
      setState(() {
        locationAcquired = true;
        if (argsList['mode'] == MapMode.navigation) {
          _mapMode = MapMode.navigation;
          destination = argsList['latLng'] as LatLng;
          setNavigation();
          addMarker();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(builder: (context, themeProvider, _) {
      return Scaffold(
          appBar: CustomAppBar(
            pageTitle: "Location",
            actions: locationAcquired
                ? <Widget>[
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        Navigator.of(context).pop(_pickedLocation);
                      },
                    )
                  ]
                : null,
          ),
          body: locationAcquired
              ? Stack(
                  children: [
                    _mapMode == MapMode.navigation
                        ? GoogleMap(
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: false,
                            polylines: Set<Polyline>.of(polylines.values),
                            initialCameraPosition: CameraPosition(
                              target: curLocation,
                              zoom: 16,
                            ),
                            markers: {sourceMarker!, destinationMarker!},
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          )
                        : GoogleMap(
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                _pickedLocation.latitude,
                                _pickedLocation.longitude,
                              ),
                              zoom: 16,
                            ),
                            onTap: _mapMode == MapMode.pickLocation
                                ? _selectLocation
                                : null,
                            markers: ({
                              Marker(
                                markerId: const MarkerId('m1'),
                                position: _pickedLocation,
                              ),
                            }),
                          ),
                    LayoutBuilder(builder: (context, constraints) {
                      return Visibility(
                          visible: _mapMode == MapMode.pickLocation,
                          child: LocationAddressTextField(
                              addressController: addressController,
                              themeProvider: themeProvider,
                              constraints: constraints));
                    }),
                  ],
                )
              : Transform.scale(
                  scale: 0.5,
                  child: const LoadingIndicator(
                      indicatorType: Indicator.ballBeat,
                      colors: [primarySwatch]),
                ));
    });
  }

  Future<void> _selectLocation(LatLng position) async {
    if (position != null) {
      addressController.text = await LocationHelper.getPlaceAddress(
          position.latitude, position.longitude);
    }
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> setNavigation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    final GoogleMapController? controller = await _controller.future;

    location.changeSettings(accuracy: LocationAccuracy.high);
    serviceEnabled = await location.serviceEnabled();
    List allowedPermissions = [
      PermissionStatus.granted,
      PermissionStatus.grantedLimited
    ];
    if (!serviceEnabled) {
      serviceEnabled =
          allowedPermissions.contains(await location.requestService());
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (!allowedPermissions.contains(permissionGranted)) {
      permissionGranted = await location.requestPermission();
      if (!allowedPermissions.contains(permissionGranted)) {
        return;
      }
    }
    if (allowedPermissions.contains(permissionGranted)) {
      var currentPosition = await location.getLocation();
      var currentLocation =
          LatLng(currentPosition.latitude!, currentPosition.longitude!);

      locationSubscriber =
          location.onLocationChanged.listen((LocationData liveLocation) {
        controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(liveLocation.latitude!, liveLocation.longitude!),
            zoom: 16)));
        if (mounted) {
          controller
              ?.showMarkerInfoWindow(MarkerId(sourceMarker!.markerId.value));
          setState(() {
            _mapMode = MapMode.navigation;
            curLocation =
                LatLng(currentLocation.latitude, currentLocation.longitude);
            sourceMarker = Marker(
                markerId: MarkerId(currentLocation.toString()),
                position:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow,
                ),
                infoWindow: InfoWindow(
                    title: double.parse(LocationHelper.calculateDistance(
                                currentLocation.latitude,
                                currentLocation.longitude,
                                destination.latitude,
                                destination.longitude)
                            .toString())
                        .toString()));
          });
          getDirections(destination);
        }
      });
    }
  }

  getDirections(LatLng dest) async {
    List<LatLng> polylineCoordinates = [];
    List<dynamic> points = [];
    await polylinePoints
        .getRouteBetweenCoordinates(
            googleApiKey,
            PointLatLng(curLocation.latitude, curLocation.longitude),
            PointLatLng(destination.latitude, destination.longitude),
            travelMode: TravelMode.walking)
        .then((result) {
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          points.add({"lat": point.latitude, 'lng': point.longitude});
        }
        addPolyline(polylineCoordinates);
      } else {
        Logger().d(result.errorMessage);
      }
    });
  }

  addPolyline(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3);
    polylines[id] = polyline;
    setState(() {});
  }

  addMarker() {
    setState(() {
      sourceMarker = Marker(
          markerId: const MarkerId('source'),
          position: curLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow));
    });
  }
}

class LocationAddressTextField extends StatelessWidget {
  const LocationAddressTextField(
      {super.key,
      required this.addressController,
      required this.themeProvider,
      required this.constraints});

  final TextEditingController addressController;
  final BoxConstraints constraints;
  final AppTheme themeProvider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: constraints.maxHeight * 0.095,
      child: Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? const Color(0xFF303030)
                      : Colors.white)),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 8.0),
              child: TextFormField(
                  maxLines: null,
                  enabled: false,
                  controller: addressController,
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

enum MapMode { navigation, pickLocation }
