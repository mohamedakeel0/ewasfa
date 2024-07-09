import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:provider/provider.dart';
import '../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/offer.dart';
import '../assets/app_data.dart';
import '../widgets/custom_app_bar.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Offer Details Screen')
class OfferDetailsScreen extends StatefulWidget {
  static const routeName = '/offer_details';

  @override
  State<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends State<OfferDetailsScreen> {
  late final Offer offer;
  bool offerLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    offer = ModalRoute.of(context)!.settings.arguments as Offer;
    offerLoaded = true;
  }

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
        child: offerLoaded
            ? Scaffold(
                extendBodyBehindAppBar: true,
                appBar: CustomAppBar(pageTitle: appLocalization.offerinfo),
                body: Container(
                  child: Container(
                    margin: EdgeInsets.only(top: query.size.height * 0.15),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Text(
                                  languageProvider.currentLanguage ==
                                          Language.arabic
                                      ? offer.arabicName
                                      : offer.englishName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(
                                  "${appLocalization.offerValidity} ${offer.offerEndDate}"),
                              Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(appLocalization.priceAfter,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall),
                                        Text(
                                          "SAR ${offer.priceAfter.toString()}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        )
                                      ],
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ClippedOfferImage(
                                    query: query, offer: offer),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Center(
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      LoadingIndicator(
                          indicatorType: Indicator.ballBeat,
                          colors: [primarySwatch]),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

class ClippedOfferImage extends StatelessWidget {
  const ClippedOfferImage({
    super.key,
    required this.query,
    required this.offer,
  });

  final MediaQueryData query;
  final Offer offer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, ZoomableImageScreen.routeName,
              arguments: [
                ZoomableImageSourceType.network,
                "$offersImagesDirectory/${offer.image}"
              ]);
        },
        child: Container(
          height: query.size.height * 0.3,
          width: query.size.width * 0.9,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage("$offersImagesDirectory/${offer.image}"),
            ),
          ),
        ),
      ),
    );
  }
}
