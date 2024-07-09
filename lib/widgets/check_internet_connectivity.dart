import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:flutter/foundation.dart';

@Category(<String>['Widgets'])
@Summary('A widget that checks for internet connectivity and disallows the user from using the app if there is no internet')
class ConnectivityAwareScreen extends StatefulWidget {
  final Widget child;

  ConnectivityAwareScreen({required this.child});

  @override
  _ConnectivityAwareScreenState createState() =>
      _ConnectivityAwareScreenState();
}

class _ConnectivityAwareScreenState extends State<ConnectivityAwareScreen> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    Timer.periodic(Duration(seconds: 10), (_) {
      _checkConnectionStatus();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    final ConnectivityResult result =
    await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  Future<void> _checkConnectionStatus() async {
    final ConnectivityResult result =
    await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = (result != ConnectivityResult.none);
      _showLoading = !_isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected
        ? widget.child
        : (_showLoading ? _buildLoadingScreen():_buildNoConnectionScreen() );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoConnectionScreen() {
    return const Scaffold(
      body: Center(
        child: Text('No Internet Connection'),
      ),
    );
  }
}
