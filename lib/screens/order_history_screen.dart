import 'dart:async';

import 'package:ewasfa/screens/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import '../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';
import '../providers/auth.dart';
import '../providers/orders.dart';
import '../widgets/custom_app_bar.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Order History screen')
class OrderHistoryScreen extends StatefulWidget {
  static const routeName = '/order_history';

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _showImage = false;
  bool _isLoading = true;
  late Timer timer;

  void startTimer() {
    // Create a timer with a duration of 5 seconds
    timer = Timer(const Duration(seconds: 5), () {
      // Update the state to show the image
      setState(() {
        _showImage = true;
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Start the timer when the widget is initialized
    startTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<Auth>(context, listen: false);
    final ordersProvider = Provider.of<Orders>(context);
    final userOrders = ordersProvider.getUserOrders(authProvider.userId);
    final query = MediaQuery.of(context);
    final appLocalization = AppLocalizations.of(context)!;

    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(pageTitle: appLocalization.orderHistory),
          body: userOrders.isEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? SizedBox(
                          height: query.size.height * 0.5,
                          width: query.size.width * 0.5,
                          child: const LoadingIndicator(
                              indicatorType: Indicator.ballBeat,
                              colors: [primarySwatch]),
                        )
                      : Image.asset(
                          "lib/assets/images/empty_data.png",
                        ),
                )
              : Container(
                  margin: EdgeInsets.only(top: query.size.height * 0.15),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: userOrders.length,
                    itemBuilder: (context, index) {
                      final order = userOrders[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  '${appLocalization.date} ${order.date}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              Text(
                                '${appLocalization.orderId} ${order.orderId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${appLocalization.orderStatus} ${order.status}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: order.status != 'pending'
                              ? Text(
                                  '${appLocalization.price} ${order.price}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              : null,
                          onTap: () {
                            Navigator.pushNamed(
                                context, PreviousOrderDetailsScreen.routeName,
                                arguments: userOrders[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      );
    });
  }
}
