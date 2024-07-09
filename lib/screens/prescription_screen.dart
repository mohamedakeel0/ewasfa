import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../assets/app_data.dart';
import '../providers/auth.dart';
import '../providers/orders.dart';
import '../providers/prescriptions.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Prescription History screen')
/// NOTE: UNUSED SCREEN. TO BE ADDED IN FUTURE UPDATES ON ADDING PRESCRIPTION FUNCTIONALITY
class PrescriptionsHistoryScreen extends StatelessWidget {
  static const routeName = '/prescriptions';
  @override
  Widget build(BuildContext context) {
    final prescriptionsProvider = Provider.of<Prescriptions>(context);
    // TODO: After changing the Prescriptions provider, change the implementation below so that it doesn't need the Auth provider
    final authProvider = Provider.of<Auth>(context);
    final ordersProvider = Provider.of<Orders>(context);
    final userOrders = ordersProvider.getUserOrders(authProvider.userId);
    prescriptionsProvider.fetchAndSetPrescriptions();
    final userPrescriptions = prescriptionsProvider.getUserPrescriptions(authProvider.userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primarySwatch.shade400,
        centerTitle: true,
        title: const Text('Prescriptions History'),
      ),
      body: Container(        
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
          ),
          itemCount: userPrescriptions.length,
          itemBuilder: (context, index) {
            final prescription = userPrescriptions[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    "$ordersImagesDirectory/${prescription.image}",
                    loadingBuilder: (context, child, loadingProgress) => const LoadingIndicator(indicatorType: Indicator.ballBeat, colors: [primarySwatch]),
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.medication_rounded),
                    fit: BoxFit.cover,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("TODO: ADD PRESCRIPTION DATE HERE"
                      // prescription.,
                      // textAlign: TextAlign.center,
                      // style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
