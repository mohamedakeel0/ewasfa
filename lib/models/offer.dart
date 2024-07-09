import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The Offers & Promotions Model class')
class Offer{
  int offerId;
  String arabicName;
  String englishName;
  String image;
  double priceBefore;
  double priceAfter;
  String offerStartDate;
  String offerEndDate;
  int offerArrange;
  bool typeisPharmacy; // true --> pharmacy. false --> clinic.

  Offer({ required this.offerId, required this.arabicName, required this.englishName, required this.image, required this.priceBefore,
  required this.priceAfter, required this.offerArrange, required this.offerStartDate, required this.offerEndDate, required this.typeisPharmacy});
}