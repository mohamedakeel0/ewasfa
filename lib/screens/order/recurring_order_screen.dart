import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen through which the user can make a recurring order')
/// NOTE: UNUSED SCREEN. PLACEHOLDER TO BE IMPLEMENTED IN FUTURE UPDATES ON ADDING RECURRING ORDER FUNCTIONALITY. 
class RecurringOrderScreen extends StatefulWidget {
  static const routeName = '/recurring_order';
  const RecurringOrderScreen({super.key});

  @override
  State<RecurringOrderScreen> createState() => _RecurringOrderScreenState();
}

class _RecurringOrderScreenState extends State<RecurringOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return const Placeholder();
  }
}
