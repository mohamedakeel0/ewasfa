
import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The User Model class')
class User {
  int userId;
  String firstName;
  String lastName;
  String phone;
  String email;
  String image;
  String gender;
  String userRank;

  User(
      {required this.userId,
      required this.firstName,
      required this.lastName,
      required this.phone,
      required this.email,
      required this.image,
      required this.gender,
      required this.userRank});
}
