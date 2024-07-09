import 'package:flutter/foundation.dart';

@Category(<String>['Models'])
@Summary('The model for custom HTTP Exception messages')
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    return message;
    // return super.toString(); // Instance of HttpException
  }
}