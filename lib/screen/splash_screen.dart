import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../extras/dimension.dart';
import '../extras/string.dart';
import 'home.dart';
import 'login.dart';

const Color _bgTop = Color(0xFFFFF3E8);
const Color _bgBottom = Color(0xFFF4F4F4);
const Color _blobOne = Color(0xFFFFF3E8);
const Color _blobTwo = Color(0xFFF4F4F4);
const Color _primary = Color(0xFF75292A);
const Color _titleColor = Color(0xFF172338);
const Color _subtleText = Color(0xFF61708A);
const Color _error = Color(0xFFE2572C);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  String _statusMessage = Strings.statusInitializing;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadConfig();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppDimens.durationAnimation),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadConfig() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString(Strings.tokenStorageKey) ?? '';

      if (!mounted) return;

      if (token.isEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            transitionDuration:
                Duration(milliseconds: AppDimens.durationTransition),
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
        _hasError = true;
        _statusMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_bgTop, _bgBottom],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              top: -70,
              right: -50,
              child: _SplashBlob(size: 220, color: _blobOne),
            ),
            const Positioned(
              left: -90,
              bottom: -100,
              child: _SplashBlob(size: 260, color: _blobTwo),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(scale: _scaleAnimation, child: child),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingXL,
                    vertical: AppDimens.paddingXXL,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.86),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFF3E8)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildLogo(),
                      const SizedBox(height: AppDimens.paddingXXL),
                      _buildTitle(),
                      const SizedBox(height: AppDimens.paddingXS),
                      _buildTagline(),
                      const SizedBox(height: AppDimens.splashBottomSpacing),
                      _hasError ? _buildErrorState() : _buildLoadingState(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: AppDimens.logoSize + 10,
      height: AppDimens.logoSize + 10,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF75292A), Color(0xFF75292A)],
        ),
        borderRadius: BorderRadius.circular(AppDimens.logoRadius + 8),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _primary.withOpacity(0.35),
            blurRadius: AppDimens.logoBlurRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.school,
        size: AppDimens.logoIconSize,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'DAV School Pad',
      style: TextStyle(
        color: _titleColor,
        fontSize: AppDimens.fontTitle,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Loading your experience',
      style: TextStyle(
        color: _subtleText,
        fontSize: AppDimens.fontM,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: <Widget>[
        const SizedBox(
          width: AppDimens.loaderSize,
          height: AppDimens.loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: AppDimens.strokeWidth,
            color: _primary,
          ),
        ),
        const SizedBox(height: AppDimens.splashStatusSpacing),
        AnimatedSwitcher(
          duration: Duration(milliseconds: AppDimens.durationSwitch),
          child: Text(
            _statusMessage,
            key: ValueKey<String>(_statusMessage),
            style: const TextStyle(
              color: _subtleText,
              fontSize: AppDimens.fontS,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: <Widget>[
        const Icon(
          Icons.error_outline,
          color: _error,
          size: AppDimens.errorIconSize,
        ),
        const SizedBox(height: AppDimens.errorSpacing),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingXXL + 12,
          ),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _error,
              fontSize: AppDimens.fontS,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.paddingXL),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _hasError = false;
              _statusMessage = Strings.statusRetrying;
            });
            _loadConfig();
          },
          icon: const Icon(Icons.refresh, color: _primary),
          label: const Text(
            Strings.btnRetry,
            style: TextStyle(color: _primary),
          ),
        ),
      ],
    );
  }
}

class _SplashBlob extends StatelessWidget {
  const _SplashBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
