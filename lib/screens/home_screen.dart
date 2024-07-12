import 'package:ewasfa/providers/offers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../assets/app_data.dart';
import '../providers/branches.dart';
import '../providers/language.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offers_custom_listview.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen that displays the offers & Promotions')
class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool offersLoaded = false;

  @override
  void initState() {
    super.initState();
    Logger logger = Logger();
    final offersProvider = Provider.of<Offers>(context, listen: false);
    final branchesProvider = Provider.of<Branches>(context, listen: false);
    branchesProvider.fetchBranches();
    offersProvider.fetchAndSetOffers().then((_) {
      setState(() {
        offersLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    return DefaultTabController(
        length: 2,
        child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) => Localizations(
                  delegates: AppLocalizations.localizationsDelegates,
                  locale: languageProvider.currentLanguage == Language.arabic
                      ? const Locale('ar')
                      : const Locale('en'),
                  child: Scaffold(
                    backgroundColor: Colors.white,
                    extendBodyBehindAppBar: true,
                    appBar: CustomAppBar(
                      actions: [],
                      leading: Container(
                        color: Colors.white,
                        width: 20.w,
                      ),
                      pageTitle: appLocalization.offersPromotions,
                      tabBar: TabBar(
                        indicatorColor: primarySwatch.shade500,
                        tabs: [
                          Tab(
                              child: Text(
                            AppLocalizations.of(context)!.pharmacyOffers,
                            style: Theme.of(context).textTheme.titleMedium,
                          )),
                          Tab(
                              child: Text(
                                  AppLocalizations.of(context)!.clinics_offers,
                                  style:
                                      Theme.of(context).textTheme.titleMedium)),
                        ],
                      ),
                    ),
                    body: LayoutBuilder(builder: (context, constraints) {
                      return offersLoaded
                          ? Container(
                              margin: EdgeInsets.only(
                                  top: constraints.maxHeight * 0.19),
                              child: const Align(
                                alignment: Alignment.topCenter,
                                child: TabBarView(
                                  children: [
                                    OffersListView(offerType: true),
                                    OffersListView(offerType: false),
                                  ],
                                ),
                              ),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                height: constraints.maxHeight * 0.5,
                                width: constraints.maxWidth * 0.5,
                                child: const LoadingIndicator(
                                    indicatorType: Indicator.ballBeat,
                                    colors: [primarySwatch]),
                              ),
                            );
                    }),
                  ),
                )));
  }
}
