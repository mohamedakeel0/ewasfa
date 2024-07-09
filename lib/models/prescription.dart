
import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The Prescription Model class')
class Prescription {
  final int userId;
  final String image;

  const Prescription({required this.userId, required this.image});
}
