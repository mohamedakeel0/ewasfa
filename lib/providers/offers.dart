import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../assets/app_data.dart';
import '../models/offer.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Providers'])
@Summary('The Offers & Promotions Provider class')

enum OfferMode { Pharmacy, Clinic }
/// A class to manage and offers & promotions data and methods.
/// Primary usage is to retrieve, store and filter offer data on whether the data refers to a [Pharmacy] or [Clinic] offer.
class Offers with ChangeNotifier {
  /// whether offers were successfully loaded from the remote API. Primarily used to avoid late initialization errors.
  bool offersLoaded = false;
  Logger logger = Logger();
  List<Offer> offers = [];

  List<Offer> getOffers() {
    return [...offers];
  }

  Offers(){
    fetchAndSetOffers();
  }

  /// Returns either pharmacy or clinic offers based on the boolean input. True = pharmacy. False = clinic
  List<Offer> getTypedOffers(bool offerType) {
    List<Offer> typedOffers = [];
    for (Offer offer in offers) {
      if (offer.typeisPharmacy == offerType) {
        typedOffers.add(offer);
      }
    }
    return typedOffers;
  }

  Offer findById(int id) {
    return offers.where((offer) => offer.offerId == id).toList()[0];
  }

  /// Retrieves offers from db and stores them in offers List
  Future<void> fetchAndSetOffers() async {
    String offerType = 'pharmacy';
    try {
      final List<Offer> loadedOffers = [];
      for (int i = 0; i < 2; i++) {
        (i == 0) ? offerType = 'pharmacy' : offerType = 'clinic';
        String url = '$apiUrl/show_$offerType';
        final response = await http.get(Uri.parse(url));
        if (response.body == "Too Many Attempts.") return;
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;
        if (extractedData["error"] == 1) {
          return;
        }
        final List extractedOffers = extractedData.values.toList()[0];
        for (int i = 0; i < extractedOffers.length; i++) {
          final Map<String, dynamic> map = extractedOffers[i];
          loadedOffers.add(Offer(
              offerId: map["id"],
              arabicName: map['arabic_name'] ?? '',
              englishName: map['english_name'] ?? '',
              image: map['image'] ?? '',
              priceAfter: map['offer_price'] is int ? map['offer_price'].toDouble() : double.parse(map['offer_price'] ?? "0.0"),
              priceBefore: map['price_before'] is int ? map['price_before'].toDouble() : double.parse(map['price_before'] ?? "0.0"),
              offerStartDate: map['offer_start_date'] ?? "",
              offerEndDate: map['offer_end_date'] ?? "",
              offerArrange:
                  int.parse(map['offer_arrange'] ?? "${loadedOffers.length}"),
              typeisPharmacy: (map['type'] == 'p') ? true : false));
        }
        offers = loadedOffers;

      }
      offersLoaded = true;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  /// Adds an [Offer] object to the offers list and notifies listeners. Unused utility function
  void addOffer(Offer offer) {
    offers.add(offer);
    notifyListeners();
  }

  /// Returns whether or not offers were successfully loaded from the remote API
  bool isOffersLoaded() {
    return offersLoaded;
  }
}
