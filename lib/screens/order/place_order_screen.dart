import 'package:ewasfa/screens/app_layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  const   PlaceOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    return Consumer<UserData>(builder: (context, userData, _) {
      if (!userData.isInitialized) {
        // Return a loading indicator or placeholder widget while the data is being initialized
        return const Center(
          child: SizedBox(
            height: 200,
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          child: Scaffold(backgroundColor: Colors.white,
            appBar: CustomAppBar(pageTitle: appLocalization.placeNewOrder,
            leading: Container(
              color: Colors.white,
              width: 20.w,
            ),),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    "lib/assets/images/logo.png",
                    height: query.size.height * 0.2,
                    width: query.size.width * 0.5,
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(30.0.h),
                  child: Text(
                    appLocalization.placeOrder,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(onTap: (){
                      Navigator.of(context)
                          .pushNamed(NewOrderScreen.routeName);
                    },
                      child:Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        height: 60.h,
                        width: MediaQuery.of(context).size.width /2.2,
                        decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(25.sp),
                            border: Border.all(color:  Colors.grey.shade300,
                                width: 2)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                                appLocalization.newOrder,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    color:  Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp)),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(onTap: (){
                      Navigator.of(context)
                          .pushNamed(ReferredOrderScreen.routeName);
                    },
                      child:Container(clipBehavior: Clip.antiAliasWithSaveLayer,
                        height: 60.h,
                        width: MediaQuery.of(context).size.width /2.2,
                        decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(25.sp),
                            border: Border.all(color:  Colors.grey.shade300,
                                width: 2)),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                                appLocalization.referredOrder,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    color:  Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.sp)),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),
        );
      });
    });
  }
}
