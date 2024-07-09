
import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The Address Model Class')
class Address{
  final int id;
  final double latitude;
  final double longitude;
  final String city;
  final String landmark;
  final String addressLine;

  Address({  required this.id, required this.city, required this.landmark, required this.latitude, required this.longitude, required this.addressLine});
}