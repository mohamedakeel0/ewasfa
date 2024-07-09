import 'package:ewasfa/widgets/background_painter.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Screens'])
@Summary('The Screen that displays at the application startup')
class SplashScreen extends StatelessWidget {
  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    final MediaQueryData query = MediaQuery.of(context);
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: query.size.width * 0.6,
                height: query.size.height * 0.4,
                child: Image.asset(
                  "lib/assets/images/logo_main.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
      ),
    );
  }
}
