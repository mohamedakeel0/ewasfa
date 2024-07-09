import 'package:ewasfa/providers/offers.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../assets/app_data.dart';
import '../models/offer.dart';
import 'offers_scoll_view.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('A listview widget that contains OfferScrollView widgets')
class OffersListView extends StatelessWidget {
  final bool offerType;
  const OffersListView({required this.offerType});

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final offersProvider = Provider.of<Offers>(context);
    List<Offer> offers = [];
    return LayoutBuilder(
      builder: (ctx, constraints) {
        if (offersProvider.isOffersLoaded()) {
          offers = [...offersProvider.getTypedOffers(offerType)];          
        }
        else {
          return Center(
            child: Transform.scale(
              scale: 0.5,
              child: const LoadingIndicator(
                  indicatorType: Indicator.ballBeat, colors: [primarySwatch]),
            ),
          );
        }
        return offers.isEmpty
            ? Image.asset("lib/assets/images/empty_data.png",
                fit: BoxFit.contain)
            : OffersScrollView(query: query, offers: offers);
      },
    );
  }
}
