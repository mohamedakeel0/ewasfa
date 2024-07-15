
import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The Address Model Class')
class Address{
  final int id;
  final double latitude;
  final double longitude;
  late  String city;
  final String landmark;
  late  String addressLine;

  Address({  required this.id, required this.city, required this.landmark, required this.latitude, required this.longitude, required this.addressLine});
}