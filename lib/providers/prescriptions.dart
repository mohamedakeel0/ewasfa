import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../assets/app_data.dart';
import '../models/order.dart';
import '../models/prescription.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Providers'])
@Summary('The User Prescriptions Provider class')
/// NOTE: UNUSED CLASS. TO BE USED AS A PLACEHOLDER FOR FUTURE IMPLEMENTATION OF PRESCRIPTION HANDLING
/// 
/// A class used to manage [Prescription] data and methods.
/// Primary Usage is to retrieve, set, add and provide [Prescription] data to consumer widgets throughout the app.
class Prescriptions with ChangeNotifier {
  List<Prescription> userPrescriptions = [];
  List<Order> userOrders = [];
  late int userId;

  /// Returns the current [userPrescriptions] list in a new list
  List<Prescription> getUserPrescriptions(userId) {
    return [...userPrescriptions];
  }

  /// Used on instantiation to initialize userId
  Prescriptions updateUserId(int userId){
    this.userId = userId;
    return this;
  }

  /// Returns a specific [Prescription] based on its [image] property
  Prescription findByImage(String image) {
    return userPrescriptions
        .where((prescription) => prescription.image == image)
        .toList()[0];
  }

  /// Retrieves orders of a user from db. Extracts image data and sets unique images as prescriptions
  Future<void> fetchAndSetPrescriptions() async {
    final url =
        '$apiUrl/user_orders?user_id=$userId'; // TODO
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData =
          json.decode(response.body) as List<Map<String, dynamic>>; // TODO
      if (extractedData.isEmpty) {
        return;
      }
      final List<Prescription> loadedPrescriptions = [];
      for (Map<String, dynamic> map in extractedData) {
        map.forEach((orderID, orderData) {
          if (!loadedPrescriptions.contains(orderData['image'])) {
            loadedPrescriptions.add(Prescription(
              userId: userId,
              image: orderData['image'],
            ));
          }
        });
      }
      userPrescriptions = loadedPrescriptions;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  /// Utility function used to add a [Prescription] object to the [userPrescriptions] list. Also notifies listeners to the change in this state.
  void addPrescription(Prescription prescription) {
    userPrescriptions.add(prescription);
    notifyListeners();
  }

  ///Returns false if the [userPrescriptions] list is empty and true otherwise. Used to avoid late initialization errors.
  bool isPrescriptionsLoaded() {
    if (userPrescriptions == null || userPrescriptions.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
