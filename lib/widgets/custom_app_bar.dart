import 'package:ewasfa/providers/language.dart';
import 'package:ewasfa/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('A custom App bar')
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;
  TabBar? tabBar;
  List<Widget>? actions;
Widget? leading;
bool? isLogOut;

  CustomAppBar({super.key, required this.pageTitle,  this.isLogOut=false, this.leading, this.tabBar, this.actions});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PreferredSize(
            preferredSize: Size.fromHeight(
                kToolbarHeight + (tabBar != null ? kTextTabBarHeight : 0)),
            child: AppBar(
              iconTheme: Theme.of(context).iconTheme,
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              bottom: tabBar,
              leading: leading  ,
              title: Text(
                pageTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              actions: actions == null
                  ? []
                  : isLogOut==true? [
                      ...?actions,
                 PopupMenuButton(
                        icon: Icon(Icons.more_vert,
                            color: Theme.of(context).iconTheme.color),
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'Logout',
                              child: ListTile(
                                leading: auth.isGuest
                                    ? Icon(Icons.login,
                                        color:
                                            Theme.of(context).iconTheme.color)
                                    : Icon(Icons.logout,
                                        color:
                                            Theme.of(context).iconTheme.color),
                                title: Text(
                                  auth.isGuest
                                      ? appLocalization.login
                                      : appLocalization.logout,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'Settings',
                              child: ListTile(
                                leading: Icon(Icons.settings,
                                    color: Theme.of(context).iconTheme.color),
                                title: Text(appLocalization.settings,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                            ),
                          ];
                        },
                        onSelected: (value) {
                          if (value == 'Logout') {
                            Provider.of<Auth>(context, listen: false).logout();
                          } else if (value == "Settings") {
                            Navigator.of(context)
                                .pushNamed(SettingsScreen.routeName);
                          }
                        },
                      ),
                    ]:actions,
            ),
          ),
        ),
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (tabBar != null ? kTextTabBarHeight : 0));
}
