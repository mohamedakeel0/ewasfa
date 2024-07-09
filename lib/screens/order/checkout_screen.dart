import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The Order Checkout Screen')

/// NOTE: UNUSED SCREEN. PLACEHOLDER TO BE IMPLEMENTED IN FUTURE UPDATES ON ADDING PAYMENT SYSTEM. 
class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return const Placeholder();
  }
}