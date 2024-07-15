import 'package:ewasfa/widgets/background_painter.dart';
import 'package:ewasfa/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_theme.dart';
import '../providers/auth.dart';
import '../providers/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Settings Screen')
class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // A map that holds whether or not an option is currently expanded
  final Map<String, bool> _expandedOptions = {
    'Notifications': false,
    'Language': false,
    'Theme': false,
  };

  // A function that toggles the expansion state of an option
  void _toggleExpansionState(String option) {
    setState(() {
      _expandedOptions[option] = !_expandedOptions[option]!;
      _expandedOptions.forEach((key, value) {
        if (key != option) {
          _expandedOptions[key] = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context);
    final appLocalization = AppLocalizations.of(context)!;
    return Consumer<LanguageProvider>(builder: (context, languageProvider, _) {
      return Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: languageProvider.currentLanguage == Language.arabic
            ? const Locale('ar')
            : const Locale('en'),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: CustomAppBar(pageTitle: appLocalization.settings),
          body: CustomPaint(
            painter: BackgroundPainter(),
            child: Container(
              margin: EdgeInsets.only(top: query.size.height * 0.15),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildOptionTile(
                      "Language",
                      Icons.language,
                      appLocalization.select_your_preferred_language,
                      _expandedOptions['Language']!,
                      appLocalization.sub_options_for_language,
                      [
                        _buildSubOption(
                            'English', false, context, appLocalization),
                        _buildSubOption(
                            'Arabic', false, context, appLocalization),
                      ],
                      appLocalization),
                  _buildOptionTile(
                      'Theme',
                      Icons.palette,
                      appLocalization.select_your_preferred_color_theme,
                      _expandedOptions['Theme']!,
                      appLocalization.sub_options_for_theme,
                      [
                        _buildSubOption(
                            'Light', false, context, appLocalization),
                        _buildSubOption(
                            'Dark', false, context, appLocalization),
                      ],
                      appLocalization),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // A function that returns a ListTile widget for an option
  Widget _buildOptionTile(
      String option,
      IconData icon,
      String description,
      bool isExpanded,
      String expansionTitle,
      List<Widget> subOptions,
      AppLocalizations appLocalization) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          _toggleExpansionState(option);
        },
        children: [
          ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  leading: Icon(icon),
                  title: Text(
                      option == "Language"
                          ? appLocalization.language
                          : appLocalization.theme,
                      style: Theme.of(context).textTheme.labelLarge),
                  subtitle: Text(description),
                ),
              );
            },
            body: Column(
              children: subOptions,
            ),
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  // A function that returns a ListTile widget for a sub-option
  Widget _buildSubOption(String option, bool isSelected, BuildContext context,
      AppLocalizations appLocalization) {
    final appThemeProvider = Provider.of<AppTheme>(context, listen: false);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    String subOption = "";
    if (option == "English") {
      subOption = "English";
    } else if (option == "Arabic") {
      subOption = "العربيه";
    } else if (option == "Light") {
      subOption = appLocalization.light;
    } else if (option == "Dark") {
      subOption = appLocalization.dark;
    }
    return ListTile(
      title: Text(subOption, style: Theme.of(context).textTheme.bodyMedium),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          isSelected = !isSelected;
        });
        if (option == "Arabic") {
          if (languageProvider.currentLanguage != Language.arabic) {
            setState(() {
              final langProv =
                  Provider.of<LanguageProvider>(context, listen: false);
              final authProvider = Provider.of<Auth>(context, listen: false);
              langProv.changeLanguage(Language.arabic, authProvider.auth);
              appThemeProvider.toggleLanguage();
              langProv.saveLanguagePreference(Language.arabic);
            });
          }
        } else if (option == "English") {
          if (languageProvider.currentLanguage != Language.english) {
            setState(() {
              final langProv =
                  Provider.of<LanguageProvider>(context, listen: false);
              final authProvider = Provider.of<Auth>(context, listen: false);
              langProv.changeLanguage(Language.english, authProvider.auth);
              appThemeProvider.toggleLanguage();
              langProv.saveLanguagePreference(Language.english);
            });
          }
        } else if (option == "Light") {
          if (appThemeProvider.isDarkMode) {
            appThemeProvider.toggleTheme();
            appThemeProvider.saveCurrentTheme("light");
          }
        } else if (option == "Dark") {
          if (!appThemeProvider.isDarkMode) {
            appThemeProvider.toggleTheme();
            appThemeProvider.saveCurrentTheme("dark");
          }
        }
      },
    );
  }
}
