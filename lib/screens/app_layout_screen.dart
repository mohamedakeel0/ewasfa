import 'package:ewasfa/assets/app_data.dart';
import 'package:ewasfa/main.dart';
import 'package:ewasfa/providers/app_theme.dart';
import 'package:ewasfa/providers/auth.dart';
import 'package:ewasfa/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:ewasfa/screens/home_screen.dart';
import 'package:ewasfa/screens/my_profile_screen.dart';
import 'package:ewasfa/screens/order/place_order_screen.dart';
import 'package:ewasfa/screens/order_history_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

import 'package:ewasfa/providers/language.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
class AppLayoutScreen extends StatefulWidget {
  static const routeName = '/AppLayout';
  const AppLayoutScreen({Key? key}) : super(key: key);

  @override
  State<AppLayoutScreen> createState() => _AppLayoutScreenState();
}

class _AppLayoutScreenState extends State<AppLayoutScreen> {

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer3<Auth, LanguageProvider, AppTheme>(
        builder: (ctx, auth, languageProvider, themeProvider, _){
        return Scaffold(
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
                                    auth.logout(context); // Navigate to login screen
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
            ));
      }
    );
  }
}
