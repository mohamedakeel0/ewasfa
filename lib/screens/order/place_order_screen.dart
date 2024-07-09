import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import '../../assets/app_data.dart';
import '../../models/user.dart';
import '../../providers/user_data.dart';
import '../../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ewasfa/main.dart';
import 'package:ewasfa/screens/order/doctor_make_order.dart';
import 'package:ewasfa/screens/order/new_order_screen.dart';
import 'package:ewasfa/screens/order/referred_order_screen.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';

@Category(<String>['Order Screens'])
@Summary('The Screen through which the user selects New Order or Referred Order')
class PlaceOrderScreen extends StatelessWidget {
  static const routeName = '/place_order';

  const PlaceOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return Consumer<UserData>(builder: (context, userData, _) {
      if (!userData.isInitialized) {
        // Return a loading indicator or placeholder widget while the data is being initialized
        return Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LoadingIndicator(
                    indicatorType: Indicator.ballBeat, colors: [primarySwatch]),
              ],
            ),
          ),
        );
      }
      User user = userData.user;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (user.userRank == "doctor") {
          Navigator.of(context).pushNamed(DoctorMakeOrderScreen.routeName);
        }
      });
      final appLocalization = AppLocalizations.of(context)!;
      return Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
        return Localizations(
          delegates: AppLocalizations.localizationsDelegates,
          locale: languageProvider.currentLanguage == Language.arabic
              ? const Locale('ar')
              : const Locale('en'),
          child: Scaffold(
            appBar: CustomAppBar(pageTitle: appLocalization.placeNewOrder),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    "lib/assets/images/place_order.png",
                    height: query.size.height * 0.5,
                    width: query.size.width * 0.5,
                  ),
                ),
                Text(
                  appLocalization.placeOrder,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primarySwatch.shade500),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(NewOrderScreen.routeName);
                      },
                      child: Text(appLocalization.newOrder,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold),
                          backgroundColor: primarySwatch.shade500),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ReferredOrderScreen.routeName);
                      },
                      child: Text(appLocalization.referredOrder,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              )),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold),
                        backgroundColor: primarySwatch.shade500),
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          MyHomePage.routeName, (route) => false);
                    },
                    child: Text(appLocalization.homePage,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            )),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }
}
