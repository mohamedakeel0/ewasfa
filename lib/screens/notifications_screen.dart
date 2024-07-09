import 'dart:async';

import 'package:ewasfa/providers/auth.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/app_data.dart';
import '../providers/language.dart';


import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Notifications Screen')
class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Logger logger = Logger();
  
  Future<List<dynamic>> _fetchNotifications(int userId, String lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String clearDate = prefs.getString('notif_clear_datetime') ?? "";
    String url = "";
    if (clearDate != "") {
      logger.d("Clear Date Found, Fetching notifications after: $clearDate");
      url =
          '$apiUrl/show_notification_datetime?user_id=$userId&lang=$lang&datetime=$clearDate';
    } else {
      url =
          '$apiUrl/show_notification?user_id=$userId&lang=$lang';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> notificationData = jsonResponse['notification_data'];
      return notificationData;
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> clearNotifications(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notif_clear_datetime',
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
    final url =
        '$apiUrl/delete_notifications?user_id=$userId';
    await http.post(Uri.parse(url));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appLocalization = AppLocalizations.of(context)!;
    final query = MediaQuery.of(context);

    return Consumer2<Auth, LanguageProvider>(
        builder: (context, authData, languageProvider, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(pageTitle: appLocalization.notifications),
        body: Container(
          child: Consumer<Auth>(
            builder: (context, authData, child) {
              return FutureBuilder<List<dynamic>>(
                future: _fetchNotifications(
                    authData.userId,
                    languageProvider.currentLanguage == Language.arabic
                        ? "ar"
                        : "en"),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Transform.scale(
                        scale: 0.5,
                        child: const LoadingIndicator(
                            indicatorType: Indicator.ballBeat,
                            colors: [primarySwatch]),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final notifications = snapshot.data!;
                    return notifications.isEmpty
                        ? Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "lib/assets/images/empty_data.png",
                            ))
                        : Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: query.size.height * 0.15),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: notifications
                                        .map((notification) => Card(
                                              child: ListTile(
                                                title: Text(
                                                  notification['title'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                subtitle: Text(
                                                  notification['body'],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: query.size.height * 0.10),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        clearNotifications(authData.userId),
                                  ),
                                ),
                              ),
                            ],
                          );
                  } else {
                    // TODO: else code here.
                    return Container();
                  }
                },
              );
            },
          ),
        ),
      );
    });
  }
}
