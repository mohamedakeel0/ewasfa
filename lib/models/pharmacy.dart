import 'package:ewasfa/models/address.dart';
import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The Pharmacy Model class')
class Pharmacy{
  final int id;
  final String arabicName;
  final String englishName;
  final Address address;
  
  Pharmacy({required this.id, required this.arabicName, required this.englishName, required this.address});
}