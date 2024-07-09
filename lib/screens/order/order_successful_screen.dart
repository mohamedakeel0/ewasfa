import 'package:ewasfa/main.dart';
import 'package:ewasfa/screens/order/place_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../../assets/app_data.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen that displays the success response of an order request')
class OrderSuccessfulScreen extends StatelessWidget {
  static const routeName = '/order_successful';

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(
            pageTitle: appLocalization.orderSuccess,
          ),
          body: Container(
            padding: const EdgeInsets.only(right: 20, left: 20),
            child: Container(
              margin: EdgeInsets.only(top: query.size.height * 0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("lib/assets/images/order_successful.png",
                        fit: BoxFit.contain),
                    const SizedBox(height: 16),
                    Text(
                      appLocalization.orderSuccessMsg,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                          backgroundColor: primarySwatch.shade500),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context,
                            PlaceOrderScreen.routeName, (route) => false);
                      },
                      child: Text(appLocalization.placeNewOrder,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                          backgroundColor: primarySwatch.shade500),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, MyHomePage.routeName, (route) => false);
                      },
                      child: Text(appLocalization.homePage,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
