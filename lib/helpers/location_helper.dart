import 'dart:convert';
import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:logger/logger.dart';

import '../assets/app_data.dart';
import 'package:flutter/foundation.dart';

@Category(<String>['Helpers'])
@Summary(
    'A class that provides helper methods for dealing with Google Maps API')

/// Helper class for location-based methods
const piRadian = 0.017453292519943295; // Pi in radians
const earthDi2 = 12742; // twice the Earth's radius in kilometers
const maxDist = 9999999.0;

class LocationHelper {
  /// takes [latitude] and [longitude] doubles and returns a link to a static map image
  static String generateLocationPreviewImage(
      {required double latitude, required double longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$latitude,$longitude&key=$googleApiKey';
  }

  /// takes [latitude] and [longitude] doubles and returns a string corresponding to that place's address
  static Future<String> getPlaceAddress(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'][0]['formatted_address'];
  }

  /// takes [latitude] and [longitude] doubles and returns a string corresponding to that place's city
  static Future<String> getPlaceCity(double lat, double lng) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body)['results'][0]['address_components'][4]
        ['long_name'];
  }

  /// Uses the Haversine formula that calculates the distance between two points on a sphere, such as the Earth. The formula takes into account the latitude and longitude
  /// coordinates of the two points. Breakdown of the steps involved:
  /// 1- Convert the latitude and longitude differences from degrees to radians
  /// 2- Calculate an intermediate value [a]:
  ///   - Calculate the cosine of the difference in latitude divided by 2 [dLatHalf]
  ///   - Calculate the cosine of the difference in longitude divided by 2 [dLongHalf]
  ///   - multiply [1- dLongHalf] by the cosine of latitude1 in radians and cosine of latitude2 in radians then add it to [dLatHalf]
  /// 3- Calculate the distance by getting the square root of [a] then computing its arcsine then multiplying the result by [earthDi2]
  /// Reference: https://en.wikipedia.org/wiki/Haversine_formula
  static double calculateDistance(lat1, lng1, lat2, lng2) {
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * piRadian) / 2 +
        c(lat1 * piRadian) *
            c(lat2 * piRadian) *
            (1 - c((lng2 - lng1) * piRadian)) /
            2;
    var result = earthDi2 * asin(sqrt(a));
    return result;
  }

  /// Returns the current user's location in [LatLng] format
  static Future<LatLng> getCurrentUserLatLng() async {
    var state = await getPermissionState();
    print("Service & Permission State: $state");
    final locData = await Location().getLocation();
    if(state == false)
    {
      return const LatLng(0.0, 0.0);
    }

    return LatLng(locData.latitude!, locData.longitude!);
  }

  /// Returns the Current user location in [Location] format
  static Future<LocationData> getCurrentUserLocation() async =>
      await Location().getLocation();

  /// Returns whether the location service & the permissions required are acquired or not.
  static Future<bool> getPermissionState() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    List allowedPermissions = [
      PermissionStatus.granted,
      PermissionStatus.grantedLimited
    ];

    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      print("Location Service Disabled");
      return false;
    }

    permissionGranted = await location.hasPermission();
    if (!allowedPermissions.contains(permissionGranted)) {
      print("Location Permission not granted. ");
      permissionGranted = await location.requestPermission();
      if (!allowedPermissions.contains(permissionGranted)) {
        return false;
      }
    }
    return true;
  }
}
