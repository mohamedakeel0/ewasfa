import 'package:cached_network_image/cached_network_image.dart';
import 'package:ewasfa/screens/offer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../assets/app_data.dart';
import '../models/offer.dart';
import '../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('A widget that displays all offer List Tiles in a scrollable list fashion')
class OffersScrollView extends StatelessWidget {
  const OffersScrollView({
    super.key,
    required this.query,
    required this.offers,
  });

  final MediaQueryData query;
  final List<Offer> offers;

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: SingleChildScrollView(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.fromLTRB(
              query.size.width * 0.03, 0, query.size.width * 0.03, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: query.size.height * 0.7,
                width: query.size.width * 0.95,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: offers.length,
                  itemBuilder: (ctx, index) => SizedBox(
                    height: 175,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, OfferDetailsScreen.routeName,
                            arguments: offers[index]);
                      },
                      child: Card(                        
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "$offersImagesDirectory/${offers[index].image}",
                                    placeholder: (context, url) => const Center(
                                        child: LoadingIndicator(
                                      indicatorType: Indicator.ballBeat,
                                      colors: [primaryswatchAccent],
                                    )),
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      width: query.size.width*0.9,
                                      decoration: BoxDecoration(
                                        color: const Color(0x00000000),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      "lib/assets/images/not_found.png",
                                    ),
                                  )
                                  ),
                            ),                            
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: query.size.width * 0.6,
                                    child: Text(
                                      languageProvider.currentLanguage ==
                                              Language.arabic
                                          ? offers[index].arabicName
                                          : offers[index].englishName,
                                      maxLines: 2,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            offset: const Offset(0, 2.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                        overflow: TextOverflow
                                            .ellipsis, // Enable text wrapping with ellipsis
                                      ),
                                    ),
                                  ),
                                  Text(appLocalization.moreDetails,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            offset: const Offset(0, 2.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
