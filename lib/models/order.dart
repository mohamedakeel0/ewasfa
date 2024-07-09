
import 'package:flutter/foundation.dart';

import 'package:ewasfa/models/address.dart';
import 'package:ewasfa/models/prescription.dart';


@Category(<String>['Models'])
@Summary('The User Order Model Class')
// TODO: Retrieve enum of order statuses from old codebase
// enum OrderStatus {
//   pending,
//   processing,
//   ready,
//   outForDelivery,
//   pickedUp,
//   delivered,
//   cancelled,
// }

class Order{
  final int orderId;
  final String doctorName;
  final String promocode;
  final Prescription prescription;
  final int pharmacyId;
  final Address userAddress;
  final String date;
  final String notes;
  String status = 'unknown';
  double price = 0;
  final String pro_description;



  Order({required this.pro_description, required this.date, required this.notes, required this.price, required this.orderId, required this.doctorName, required this.prescription, required this.pharmacyId, required this.userAddress, required this.promocode,required this.status });
}