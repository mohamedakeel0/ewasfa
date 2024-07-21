import 'dart:convert';

import 'package:ewasfa/assets/app_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../models/http_exception.dart';
import 'package:logger/logger.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/address.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Providers'])
@Summary('The Addresses Provider class')
/// A class that manages addresses and provides CRUD operations for interacting with the remote API.
/// This class extends [ChangeNotifier] to allow for notifying listeners of changes to the addresses list.
/// The [addresses] list stores the addresses fetched from the remote API, and [userId] represents the user ID associated with the addresses.
/// The class provides methods for fetching addresses, adding new addresses, deleting addresses, and updating existing addresses.
class Addresses with ChangeNotifier {
  Logger logger = Logger();
  /// Whether the list of addresses was initialized. Used primarily to avoid Late initialization Errors
  bool _isInitialized = false;

  late int userId;
  List<Address> addresses = [];
  bool get isInitialized => _isInitialized;

  /// Returns the currently fetched addresses
  List<Address> getaddresses() {
    return [...addresses];
  }

  /// Used to update the [userId] of this class after login or logout.
  /// [userId] is used in this class in multiple methods to perform CRUD operations and notifies all listeners of this class's state.
  Addresses updateUserId(int userId) {
    this.userId = userId;
    notifyListeners();
    return this;
  }

  /// Used to retrieve a single address by its [id]
  Address findById(int id) {
    return addresses.where((address) => address.id == id).toList()[0];
  }

  /// Retrieves Addresses of a user from the remote API. Stores the retrieved addresses as [Address] objects in the [addresses] list and notifies all listeners of this class's state.
  Future<void> fetchAndSetAddresses() async {
    final url = '$apiUrl/user_address?user_id=$userId';
    try {
      final response = await http.get(Uri.parse(url));
      logger.d(response.body);
      if(response.body == "Too Many Attempts."){                
        return;
        }        
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData["error"] == 1) {
        addresses = [];
      } else {
        final List<Address> loadedAddresss = [];
        final List extractedAddresses = extractedData.values.toList()[0];

        for (int i = 0; i < extractedAddresses.length; i++) {
          final Map<String, dynamic> addressData = extractedAddresses[i];
          loadedAddresss.add(Address(
            id: addressData['id'] ?? -1,
            latitude: (addressData['latitude'] is double ||  addressData['latitude'] is int ) ? addressData['latitude'].toDouble() : double.parse(addressData['latitude'] ?? "24.774265"),
            longitude: (addressData['longitude'] is double ||  addressData['longitude'] is int) ? addressData['longitude'].toDouble() : double.parse(addressData['longitude'] ?? "46.738586"),
            city: addressData['city_arabicname'] ?? "Jeddah",
            landmark: addressData['land_mark'] ?? "",
            addressLine: addressData['address'] ?? "",
          ));
        }
        addresses = loadedAddresss;
      }
      _isInitialized = true;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }


  /// Adds a new address to the remote API. On success, displays a locale-aware toast indicating success of the operation
  Future<int> addAddress(Address address, AppLocalizations appLocalization) async {
    const url = '$apiUrl/Add_address';
    try {
      final response = await http.post(Uri.parse(url), body: {
        "land_mark": address.landmark.toString(),
        "address": address.addressLine.toString(),
        "user_id": userId.toString(),
        "latitude": address.latitude.toString(),
        "longitude": address.longitude.toString(),
        "city": address.city.toString()
      });
      logger.e(response.body);
      if(response.statusCode ==200){
        addresses.add(address);
        notifyListeners();
        Fluttertoast.showToast(msg: appLocalization.addressAddedMsg,toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,);
        final responseData = json.decode(response.body);
        int newId = responseData["data"]["id"];
        return newId;
      }
      else{
        return -1;
      }
    } catch (error) {            
      rethrow;
    }
    
  }

  /// Deletes an address from the remote API. On success, displays a locale-aware toast indicating success of the operation. Requires the [addressId] which is the stored id of the address in the remote API and [appLocalization] to create locale-aware toast messages
  Future<void> deleteAddress(int addressId, AppLocalizations appLocalization) async {
    final url = '$apiUrl/delete_address?id=$addressId';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Address successfully deleted
        Fluttertoast.showToast(msg: appLocalization.addressDeletedMsg,toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,);

        addresses.removeWhere((address) => address.id == addressId);
        notifyListeners();
      } else {
        throw HttpException('Failed to delete address');
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Updates an existing address to the remote API. On success, displays a locale-aware toast indicating success of the operation. Requires all components of the [Address] and [appLocalization] to create locale-aware toast messages
  Future<void> updateAddress({
    required String landMark,
    required String address,
    required String id,
    required String latitude,
    required String longitude,
    required String city,
    required AppLocalizations appLocalization
  }) async {
    final url = '$apiUrl/update_address';
    logger.d("${landMark}, ${address}, ${id}, $latitude, $longitude, $city");
    try {
      final response = await http.post(Uri.parse(url), body: {
        "land_mark": landMark,
        "address": address,
        "id": id,
        "latitude": latitude,
        "longitude": longitude,
        "city": city,
      });
      if (response.statusCode == 200) {
        // Address successfully updated
        Fluttertoast.showToast(
          msg: appLocalization.addressUpdatedMsg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        final updatedAddressIndex =
        addresses.indexWhere((address) => address.id == int.parse(id));
        if (updatedAddressIndex != null && updatedAddressIndex >= 0) {
          addresses[updatedAddressIndex] = Address(
            id: int.parse(id),
            latitude: double.parse(latitude),
            longitude: double.parse(longitude),
            city: city,
            landmark: landMark,
            addressLine: address,
          );
          notifyListeners();
        }
      } else {
        throw HttpException('Failed to update address');
      }
    } catch (error) {
      rethrow;
    }
  }


  /// Whether the addresses list is empty or not.
  bool isAddresssLoaded() {
    if (addresses.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
