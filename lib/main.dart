import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:ewasfa/helpers/location_helper.dart';
import 'package:ewasfa/providers/addresses.dart';
import 'package:ewasfa/providers/app_theme.dart';
import 'package:ewasfa/providers/auth.dart';
import 'package:ewasfa/providers/branches.dart';
import 'package:ewasfa/providers/offers.dart';
import 'package:ewasfa/providers/orders.dart';
import 'package:ewasfa/providers/prescriptions.dart';
import 'package:ewasfa/providers/user_data.dart';
import 'package:ewasfa/screens/auth_screen.dart';
import 'package:ewasfa/screens/home_screen.dart';
import 'package:ewasfa/screens/my_profile_screen.dart';
import 'package:ewasfa/screens/order/place_order_screen.dart';
import 'package:ewasfa/screens/order_history_screen.dart';
import 'package:ewasfa/widgets/check_internet_connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:ewasfa/providers/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'helpers/custom_route.dart';
import 'screens/notifications_screen.dart';
import 'screens/splash_screen.dart';
import 'assets/app_data.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  showNotification(message);
}

Logger log = Logger();
late FirebaseMessaging messaging;

final List<Map<String, Object>> pages = [
  {
    'page': const HomeScreen(),
    'title': 'Home Screen',
  },
  {
    'page': OrderHistoryScreen(),
    'title': 'Order History',
  },
  {
    'page': const PlaceOrderScreen(),
    'title': 'Place a new Order',
  },
  {
    'page': NotificationsScreen(),
    'title': 'User Notifications',
  },
  {
    'page': MyProfileScreen(),
    'title': 'Place a new Order',
  },
];

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print(
          'Message also contained a notification: ${message.notification?.title}');
    }
    showNotification(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    print('Got a message whilst app is opened!');
    print('Message data: ${message}');
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
    showNotification(message);
  });
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFirebase().then((value) async {
    final Location location = Location();
    await location.requestService();
    return value;
  }).then((value) async {
    LocationHelper.getPermissionState();
      final RemoteMessage? remoteMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  });
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Language language = prefs.containsKey('language')
      ? Language.values
          .firstWhere((lang) => lang.toString() == prefs.getString('language')!)
      : Language.english;
  runApp(MyApp(language: language));

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'flutter_notification', // id
      'flutter_notification_title', // title
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      showBadge: true,
      playSound: true);

  const InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings(
        '@ic_launcher'), // Replace with your launcher icon
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, // Display an alert notification
    badge: true, // Update the app badge
    sound: true, // Play a notification sound
  );
}

Future<void> showNotification(RemoteMessage message) async {
  print(message);
  final notification = message.notification;
  final android = notification?.android;
  final body = notification?.body;
  final title = notification?.title;

  const int notificationId = 0; // Replace with a unique notification ID

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'flutter_notification', // id
          'flutter_notification_title', // title
          importance: Importance.high,
          enableLights: true,
          enableVibration: true,
          playSound: true);

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    notificationId,
    title,
    body,
    platformChannelSpecifics,
    payload: message.data.toString(), // Replace with your payload data
  );
}

class MyApp extends StatelessWidget {
  final Language language;
  const MyApp({super.key, required this.language});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 931),
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
        return const MaterialApp(debugShowCheckedModeBanner: false,
          title: appName,
          home: MyHomePage(),
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const String routeName = '/myHome';
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedPageIndex = 0;
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppTheme>(
            create: (ctx) => AppTheme(),
          ),
          ChangeNotifierProvider<Auth>(
            create: (ctx) => Auth(),
          ),
          ChangeNotifierProvider<Branches>(
            create: (ctx) => Branches(),
          ),
          ChangeNotifierProvider(create: (ctx) => LanguageProvider()),
          ChangeNotifierProxyProvider<Auth, UserData>(
              create: (ctx) => UserData(),
              update: (ctx, authProvider, userDataProvider) => userDataProvider!
                  .updateUserIdRank(
                      authProvider.userId, authProvider.userRank)),
          ChangeNotifierProxyProvider<Auth, Prescriptions>(
              create: (ctx) => Prescriptions(),
              update: (ctx, authProvider, prescriptionProvider) =>
                  prescriptionProvider!.updateUserId(authProvider.userId)
                    ..fetchAndSetPrescriptions()),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: (ctx) => Orders(),
              update: (ctx, authProvider, ordersProvider) =>
                  ordersProvider!.updateUserId(authProvider.userId)
                    ..fetchAndSetOrders()),
          ChangeNotifierProxyProvider<Auth, Addresses>(
              create: (ctx) => Addresses(),
              update: (ctx, authProvider, addressesProvider) =>
                  addressesProvider!.updateUserId(authProvider.userId)
                    ..fetchAndSetAddresses()),
          ChangeNotifierProvider.value(value: Offers()),
        ],
        child: ConnectivityAwareScreen(
            child: Consumer3<Auth, LanguageProvider, AppTheme>(
                builder: (ctx, auth, languageProvider, themeProvider, _) =>
                    Localizations(
                      delegates: AppLocalizations.localizationsDelegates,
                      locale:
                          languageProvider.currentLanguage == Language.arabic
                              ? const Locale('ar')
                              : const Locale('en'),
                      child: MaterialApp(  debugShowCheckedModeBanner: false,
                          locale: languageProvider.currentLanguage ==
                                  Language.arabic
                              ? const Locale('ar')
                              : const Locale('en'),
                          localizationsDelegates: const [
                            AppLocalizations.delegate,
                            GlobalMaterialLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                          ],
                          supportedLocales: const [
                            Locale('en'), // English
                            Locale('ar'), // Arabic
                          ],
                          theme: Provider.of<AppTheme>(ctx)
                              .currentTheme
                              .copyWith(

                                  pageTransitionsTheme: PageTransitionsTheme(
                                    builders: {
                                      TargetPlatform.android:
                                          CustomPageTransitionBuilder(),
                                      TargetPlatform.iOS:
                                          CustomPageTransitionBuilder(),
                                    },
                                  ),
                                  elevatedButtonTheme: ElevatedButtonThemeData(
                                      style: ElevatedButton.styleFrom(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                  )),
                                  colorScheme: Provider.of<AppTheme>(ctx)
                                      .currentTheme
                                      .colorScheme
                                      .copyWith(
                                        primary: primarySwatch,
                                      )),
                          title: 'Ewasfa',
                          routes: routingTable,
                          home: auth.isAuth
                              ? Scaffold(
                                  body: pages[_selectedPageIndex]['page']
                                      as Widget,
                                  bottomNavigationBar: Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: CurvedNavigationBar(
                                      color: primarySwatch.shade500,
                                      backgroundColor: themeProvider.isDarkMode
                                          ? const Color(0xFF303030)
                                          : Colors.white,
                                      items: const [
                                        CurvedNavigationBarItem(
                                          child: Icon(Icons.home_rounded,
                                              color: Color(0xFF303030)),
                                          // label: AppLocalizations.of(context)
                                          //     ?.home,
                                        ),
                                        CurvedNavigationBarItem(
                                          child: Icon(
                                              Icons.shopping_bag_rounded,
                                              color: Color(0xFF303030)),
                                          // label: AppLocalizations.of(context)
                                          //     ?.orderHistory,
                                        ),
                                        CurvedNavigationBarItem(
                                          child: Icon(Icons.add_circle,
                                              color: Color(0xFF303030)),
                                          // label: AppLocalizations.of(context)
                                          //     ?.placeOrder,
                                        ),
                                        CurvedNavigationBarItem(
                                          child: Icon(Icons.notifications,
                                              color: Color(0xFF303030)),
                                          // label: AppLocalizations.of(context)
                                          //     ?.notifications,
                                        ),
                                        CurvedNavigationBarItem(
                                          child: Icon(Icons.person,
                                              color: Color(0xFF303030)),
                                          // label: AppLocalizations.of(context)
                                          //     ?.myProfile,
                                        ),
                                      ],
                                      onTap: (index) {
                                        // Handle button tap
                                        setState(() {
                                          log.d(auth.auth);
                                          if (auth.isGuest) {
                                            if ([1, 2, 3, 4].contains(index)) {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext ctx) {
                                                  return AlertDialog(
                                                    title: Text(languageProvider
                                                                .currentLanguage ==
                                                            Language.arabic
                                                        ? "حدث خطأ!"
                                                        : "User Error"),
                                                    content: Text(languageProvider
                                                                .currentLanguage ==
                                                            Language.arabic
                                                        ? "يجب أن تسجل الدخول للقيام بهذه العملية"
                                                        : "You have to be signed in to do that"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(languageProvider
                                                                    .currentLanguage ==
                                                                Language.arabic
                                                            ? "الرجوع"
                                                            : "Cancel"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context); // Close the dialog
                                                          _selectedPageIndex =
                                                              0;
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(languageProvider
                                                                    .currentLanguage ==
                                                                Language.arabic
                                                            ? "تسجيل الدخول"
                                                            : "Sign in"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          auth.logout(); // Navigate to login screen
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          } else {
                                            _selectedPageIndex = index;
                                          }
                                        });
                                      },
                                    ),
                                  ))
                              : FutureBuilder(
                                  future: auth.tryAutoLogin(ctx),
                                  builder: (ctx, authResultSnapshot) =>
                                      authResultSnapshot.connectionState ==
                                              ConnectionState.waiting
                                          ? SplashScreen()
                                          : AuthScreen(),
                                )),
                    ))));
  }
}
