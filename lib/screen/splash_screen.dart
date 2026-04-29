import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extras/dimension.dart';
import '../extras/string.dart';
import 'home.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString(Strings.tokenStorageKey) ?? '';

      if (!mounted) return;

      if (token.isEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration: Duration(
              milliseconds: AppDimens.durationTransition,
            ),
            pageBuilder: (_, __, ___) => const Login(items: []),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/schoolkonnect-splashscreen.jpg',
            fit: BoxFit.cover,
          ),
          if (_errorMessage != null)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _loadConfig,
                            child: const Text(
                              Strings.btnRetry,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
