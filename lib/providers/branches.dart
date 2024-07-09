import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../assets/app_data.dart';
import '../helpers/location_helper.dart';
import '../models/address.dart';
import '../models/pharmacy.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Providers'])
@Summary('The Pharmacy Branches Provider class')

/// A class that manages [Pharmacy] branches data. Its primary usage is to retrieve and store remotely stored branch data from the remote API
class Branches with ChangeNotifier {
  Branches() {
    fetchBranches();
  }

  /// Whether or not branches are loaded. Used primarily to avoid late initialization errors
  bool _branchesLoaded = false;

  List<Pharmacy> _branches = [];

  bool isBranchesLoaded() => _branchesLoaded;

  bool isBranchesEmpty() => _branches.isEmpty;

  Map<Pharmacy, double> _distancesFromUser = {};

  Map<Pharmacy, double> getDistancesFromUser() => _distancesFromUser;

  List<Pharmacy> getBranches() => _branches;

  /// Sends a request to the remote API to fetch branches data. If successful, retrieves and stores branches data in the [_branches] list. Throws an [Exception] if an error occurs.
  /// Notifies listeners after completing request response parsing.
  Future<void> fetchBranches() async {
    Logger().d("Fetching Branches");
    List<Pharmacy> pharmacies = [];
    const url = "$apiUrl/show_branches";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.body == "Too Many Attempts.") return;
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData["error"] == 1) {
        return;
      }
      if (response.statusCode == 200) {
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        final List extractedOffers = extractedData.values.toList()[0];
        for (int i = 0; i < extractedOffers.length; i++) {
          final Map<String, dynamic> map = extractedOffers[i];
          pharmacies.add(Pharmacy(
              address: Address(
                  addressLine: map["address"] ?? "",
                  city: "Jeddah",
                  id: -1,
                  landmark: "",
                  latitude: (map['latitude'] is double ||  map['latitude'] is int )? map['latitude'].toDouble() : double.parse(map['latitude'] ?? "24.774265"),
                  longitude: (map['longitude'] is double ||  map['longitude'] is int)? map['longitude'].toDouble() : double.parse(map['longitude'] ?? "46.738586"),),
              arabicName: map["a_name"] ?? "",
              englishName: map["E_name"] ?? "",
              id: map["id"] ?? -1));
        }
        if (pharmacies.isNotEmpty) {
          _branches = pharmacies;
          _branchesLoaded = true;
          notifyListeners();
        }
      } else {
        throw Exception('Failed to fetch branches');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Returns a branch by passing its id
  Pharmacy getBranchById(int id) {
    if (!_branchesLoaded) {
      Exception();
    }
    if (_branches.where((branch) => branch.id == id).isEmpty) {
      Exception();
    }
    return _branches.where((branch) => branch.id == id).first;
  }

  /// Sorts the branches list by distance to the user, ascendingly (least distance comes first).
  void sortBranchesByDistance(LatLng userLoc) {
    double userLatitude = userLoc.latitude;
    double userLongitude = userLoc.longitude;
    _branches.sort((a, b) {
      final double distanceA = LocationHelper.calculateDistance(
        userLatitude,
        userLongitude,
        a.address.latitude,
        a.address.longitude,
      );
      final double distanceB = LocationHelper.calculateDistance(
        userLatitude,
        userLongitude,
        b.address.latitude,
        b.address.longitude,
      );
      // If either branch has latitude/longitude of 0.0, place it at the end of the list
      if (a.address.latitude == 0.0 || a.address.longitude == 0.0) {
        return 1;
      } else if (b.address.latitude == 0.0 || b.address.longitude == 0.0) {
        return -1;
      }
      return distanceA.compareTo(distanceB);
    });
    print("Sorted Branches");
    notifyListeners();
  }

  /// Calculates Branch Distances from User and places them in the [_distancesFromUser] map
  void calculateBranchDistances(LatLng userLoc) {
    double userLatitude = userLoc.latitude;
    double userLongitude = userLoc.longitude;
    for (Pharmacy branch in _branches) {
      _distancesFromUser[branch] = LocationHelper.calculateDistance(
        userLatitude,
        userLongitude,
        branch.address.latitude,
        branch.address.longitude,
      );
    }
    print("Calculated Distances of Branches: ${_distancesFromUser.toString()}");
    notifyListeners();
  }
}
