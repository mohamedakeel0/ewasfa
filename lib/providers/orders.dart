import 'dart:convert';

import 'package:ewasfa/models/address.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

import '../assets/app_data.dart';
import '../models/order.dart';
import '../models/prescription.dart';
import '../screens/order/order_failed_screen.dart';
import '../screens/order/order_successful_screen.dart';




@Category(<String>['Providers'])
@Summary('The User Orders Provider class')
/// A class used to manage [Order] data and methods.
/// Primary Usage is to retrieve, set, add and provide [Order] data to consumer widgets throughout the app.
class Orders with ChangeNotifier {
  Logger logger = Logger();
  List<Order> userOrders = [];
  late int userId;

  /// Returns a new list containing the current userOrders
  List<Order> getUserOrders(userId) {
    return [...userOrders];
  }

  /// Used on late instantiation to set the UserId
  Orders updateUserId(int userId) {
    this.userId = userId;
    notifyListeners();
    return this;
  }

  /// User to retrieve a specific order by its [id]
  Order findById(int id) {
    return userOrders.where((order) => order.orderId == id).toList()[0];
  }

  /// Sends a request to the remote API to retrieve order data of a user and stores them as [Order] objects in the [userOrders] list. Also notifies listeners to the change in this state. 
  Future<void> fetchAndSetOrders() async {
    final url =
        '$apiUrl/user_orders?user_id=$userId'; 
    try {
      final response = await http.get(Uri.parse(url));
      if(response.body == "Too Many Attempts.")return;
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData["error"] == 1){
        return;
      }
      final List<Order> loadedOrders = [];
      for (Map<String, dynamic> map in extractedData['user_orders']) {
        loadedOrders.add(Order(
          date: map['created_at'].split(' ')[0] ?? "",
          orderId: map['id'] is int ? map['id'] : int.parse(map['id'] ?? 0),
          price: map['price'] is int ? map['price'].toDouble() :double.parse(map['price'] ?? '0.0'),
          status: map['state'] ?? 'unknown',
          notes: map['notes'] ?? '',
          prescription: Prescription(userId: userId, image: map['image'] ?? ""),
          pharmacyId: map['branch_id'] is int ? map['branch_id'] : int.parse(map['branch_id'] ?? "0"),
          userAddress: Address(
              id: 1,
              city: "",
              landmark: "",
              latitude: map['latitude'] is double ? map['latitude'] : double.parse(map['latitude'] ?? "24.774265"),
              longitude: map['longitude'] is double ? map['longitude'] : double.parse(map['longitude'] ?? "46.738586"),
              addressLine: ""),
          doctorName: map['doctor_name'] ?? "",
          promocode: map['promocode'] ?? "",
          pro_description: map['pro_description'] ?? ""
        ));
      }
      userOrders = loadedOrders;
      logger.d("Retrieved ${userOrders.length} user orders");
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }


  /// Sends a request to the remote API to submit a doctor referred Order. takes a [requestBody] that contains the data of the order, as well as a list of images to be uploaded.
  Future<void> submitDoctorOrder(
    Map<String, dynamic> requestBody,
    List<XFile> imageFiles,
    BuildContext context
  ) async {
    const url =
        '$apiUrl/make_doctorOrderdetails';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields.addAll(
          requestBody.map((key, value) => MapEntry(key, value.toString())));
      // Add the image files to the request
      for (int i = 0; i < imageFiles.length; i++) {
        var imageFile = imageFiles[i];
        request.files.add(
          await http.MultipartFile.fromPath(
            'image[]',
            imageFile.path,
            contentType: MediaType(
                'image', 'jpeg'), // Replace with the correct image content type
            filename: path.basename(imageFile.path),
          ),
        );
      }
      logger.i("Request: ${request.fields} + ${request.files}");
      final response = await request.send();
      logger
          .i("${response.statusCode} and body: ${response.request.toString()}");
      if (response.statusCode == 200) {
        // Process the response
        final responseData =
            await response.stream.transform(utf8.decoder).join();
        final parsedResponse = json.decode(responseData);

        if (parsedResponse['error'] == 0) {
          // Order inserted successfully
          final orderData = parsedResponse['order_data'];
          // Handle the order data        
          if (parsedResponse['message'] != null) {
            // Display success message to the user
            final successMessage = parsedResponse['message'];         
          }
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => OrderSuccessfulScreen()),
            ModalRoute.withName('/'),
          );
        } else {
          // Order insertion failed
          if (parsedResponse['message'] != null) {
            // Display error message to the user
            final errorMessage = parsedResponse['message'];
            // ...
          }
        }
      } else {
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => OrderFailedScreen()),
          ModalRoute.withName('/'),
        );
        // Order request failed
        // Handle the error response here if needed
      }
    } catch (error) {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => OrderFailedScreen()),
        ModalRoute.withName('/'),
      );
      rethrow;
      // Error occurred while making the order request
      // Handle the error here
    }
  }

  /// Used to add an [Order] object to the [userOrders] list. 
  void addOrder(Order order) {
    userOrders.add(order);
    notifyListeners();
  }

  /// Returns false if the [userOrders] list is empty and true otherwise. Used to avoid late initialization errors.
  bool isOrdersLoaded() {
    if (userOrders.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
