import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@Category(<String>['Helpers'])
@Summary('A class that handles Custom Page Transitions')
/// Custom Route class that is used to add a routing animation
/// used to add animations to unnamed routes
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  /// Builds the [FadeTransition] between the current widget and its child
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

/// Custom Page Transition builder class that that builds a [PageTransitionBuilder]
/// Used to add animations to named routes in app_data.dart
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
 @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == '/') {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}