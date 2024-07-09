import 'package:ewasfa/main.dart';
import 'package:ewasfa/screens/add_new_address.dart';
import 'package:ewasfa/screens/notifications_screen.dart';
import 'package:ewasfa/screens/offer_details_screen.dart';
import 'package:ewasfa/screens/order/doctor_make_order.dart';
import 'package:ewasfa/screens/order/doctor_make_order_details.dart';
import 'package:ewasfa/screens/order/order_successful_screen.dart';
import 'package:ewasfa/screens/order/referred_order_screen.dart';
import 'package:ewasfa/screens/order_details_screen.dart';
import 'package:ewasfa/screens/reset_password.dart';
import 'package:ewasfa/screens/zoomable_image_screen.dart';
import 'package:ewasfa/widgets/address_book.dart';
import 'package:ewasfa/widgets/map_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/custom_route.dart';
import '../screens/auth_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_profile_screen.dart';
import '../screens/order/checkout_screen.dart';
import '../screens/order/new_order_screen.dart';
import '../screens/order/order_failed_screen.dart';
import '../screens/order/place_order_screen.dart';
import '../screens/order/recurring_order_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/verify_code.dart';

@Category(<String>['App Data'])
@Summary('A file that stores most app supporting data')
// APP METADATA
const String appName = 'Ewasfa';
const String googleApiKey = 'AIzaSyC-PjXpAPY1leIPPg4Wn3IdVTUnKi3CatI';
const String appDescription = 'Medicine ordering app';
const String domainName = "https://e-wasfa.com";
const String uploadsFolder = "https://pharmacyapi.e-wasfa.com/uploads";
const String apiUrl = "https://pharmacyapi.e-wasfa.com/api";
const String userImagesDirectory = "https://pharmacyapi.e-wasfa.com/uploads/users";
const String ordersImagesDirectory =
    "https://pharmacyapi.e-wasfa.com/uploads/orders";
const String offersImagesDirectory =
    "https://pharmacyapi.e-wasfa.com/uploads/offers";
const String productsImagesDirectory =
    "https://pharmacyapi.e-wasfa.com/uploads/products";

//-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// FONT DATA
const String fontFamily = 'Lato';

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// COLOR DATA
const int _primarySwatchPrimaryValue = 0xFFEBC300;
const int _primaryswatchAccentValue = 0xFFFFF1D1;
const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primarySwatch =
    MaterialColor(_primarySwatchPrimaryValue, <int, Color>{
  50: Color(0xFFFDF8E0),
  100: Color(0xFFF9EDB3),
  200: Color(0xFFF5E180),
  300: Color(0xFFF1D54D),
  400: Color(0xFFEECC26),
  500: Color(_primarySwatchPrimaryValue),
  600: Color(0xFFE9BD00),
  700: Color(0xFFE5B500),
  800: Color(0xFFE2AE00),
  900: Color(0xFFDDA100),
});

const MaterialColor primaryswatchAccent = MaterialColor(
  _primaryswatchAccentValue, <int, Color>{
  100: Color(0xFFFFFFFF),
  200: Color(_primaryswatchAccentValue),
  400: Color(0xFFFFE19E),
  700: Color(0xFFFFD985),
});

MaterialColor blackToGrey = const MaterialColor(
  _blackPrimaryValue, <int, Color>{
    50: Color(0xFFFAFAFA),
    100: Color(0xFFF5F5F5),
    200: Color(0xFFEEEEEE),
    300: Color(0xFFE0E0E0),
    400: Color(0xFFBDBDBD),
    500: Color(0xFF9E9E9E),
    600: Color(0xFF757575),
    700: Color(0xFF616161),
    800: Color(0xFF424242),
    900: Color(0xFF212121),
  },
);


BoxDecoration defaultDecoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [              
              const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
              const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 1],
          ),
        );
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// PAGE TRANSITION DATA

PageTransitionsTheme transitionTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: CustomPageTransitionBuilder(),
    TargetPlatform.iOS: CustomPageTransitionBuilder(),
  },
);

final Map<String, WidgetBuilder> routingTable = {
  // Order Screens
  CheckoutScreen.routeName: (ctx) => const CheckoutScreen(),
  NewOrderScreen.routeName: (ctx) => const NewOrderScreen(),
  PlaceOrderScreen.routeName: (ctx) => const PlaceOrderScreen(),
  RecurringOrderScreen.routeName: (ctx) => const RecurringOrderScreen(),
  ReferredOrderScreen.routeName: (ctx) => ReferredOrderScreen(),
  OrderSuccessfulScreen.routeName: (ctx) => OrderSuccessfulScreen(),
  OrderFailedScreen.routeName: (ctx) => OrderSuccessfulScreen(),
  DoctorMakeOrderScreen.routeName: (ctx) => const DoctorMakeOrderScreen(),
  DoctorOrderDetailsScreen.routeName: (ctx) => DoctorOrderDetailsScreen(),
  // Login Screen
  SplashScreen.routeName: (ctx) => SplashScreen(),
  AuthScreen.routeName: (ctx) => AuthScreen(),
  OTPScreen.routeName: (ctx) => OTPScreen(),
  ForgotPasswordScreen.routeName: (ctx) => ForgotPasswordScreen(),
  // Tabs in the navigation bar
  HomeScreen.routeName: (ctx) => const HomeScreen(),
  OrderHistoryScreen.routeName: (ctx) => OrderHistoryScreen(),
  SettingsScreen.routeName: (ctx) => const SettingsScreen(),
  NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
  MyHomePage.routeName: (ctx) => const MyHomePage(),
  // Pages within the app
  MyProfileScreen.routeName: (ctx) => MyProfileScreen(),
  NewAddressScreen.routeName: (ctx) => NewAddressScreen(),
  OfferDetailsScreen.routeName: (ctx) => OfferDetailsScreen(),
  PreviousOrderDetailsScreen.routeName: (ctx) => PreviousOrderDetailsScreen(),
  ZoomableImageScreen.routeName: (ctx) => ZoomableImageScreen(),
  AddressBookWidget.routeName: (ctx) => AddressBookWidget(),
  MapScreen.routeName: (ctx) => MapScreen(),
  ResetPasswordPage.routeName: (ctx) => ResetPasswordPage(),
};
