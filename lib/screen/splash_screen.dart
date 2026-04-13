import 'package:dav_school_app/api/post.dart';
import 'package:flutter/material.dart';

import '../api/models/config_model.dart';
import '../extras/color.dart';
import '../extras/dimension.dart';
import '../extras/string.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final Post _post = Post();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
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
    final Future<void> minDelay =
    Future.delayed(Duration(milliseconds: AppDimens.durationSplashMin));

    try {
      setState(() => _statusMessage = Strings.statusFetching);

      final results = await Future.wait([_post.fetchConfig(), minDelay]);
      final List<ConfigModel> items = results[0] as List<ConfigModel>;

      if (!mounted) return;

      setState(() => _statusMessage = Strings.statusLoaded(items.length));
      await Future.delayed(Duration(milliseconds: AppDimens.durationStatusDelay));

      if (!mounted) return;

     /** Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: AppDimens.durationTransition),
          pageBuilder: (_, __, ___) => Login(items: items),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );**/
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
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: child),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              SizedBox(height: AppDimens.paddingXXL),
              _buildTitle(),
              SizedBox(height: AppDimens.paddingXS),
              _buildTagline(),
              SizedBox(height: AppDimens.splashBottomSpacing),
              _hasError ? _buildErrorState() : _buildLoadingState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: AppDimens.logoSize,
      height: AppDimens.logoSize,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.logoRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGlow,
            blurRadius: AppDimens.logoBlurRadius,
            spreadRadius: AppDimens.logoSpreadRadius,
          ),
        ],
      ),
      child: Icon(
        Icons.school,
        size: AppDimens.logoIconSize,
        color: AppColors.iconColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      Strings.appName,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppDimens.fontTitle,
        fontWeight: FontWeight.bold,
        letterSpacing: AppDimens.letterSpacingTitle,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      Strings.appTagline,
      style: TextStyle(
        color: AppColors.textHint,
        fontSize: AppDimens.fontM,
        letterSpacing: AppDimens.letterSpacingHint,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(
          width: AppDimens.loaderSize,
          height: AppDimens.loaderSize,
          child: CircularProgressIndicator(
            strokeWidth: AppDimens.strokeWidth,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: AppDimens.splashStatusSpacing),
        AnimatedSwitcher(
          duration: Duration(milliseconds: AppDimens.durationSwitch),
          child: Text(
            _statusMessage,
            key: ValueKey(_statusMessage),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppDimens.fontS,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: AppDimens.errorIconSize,
        ),
        SizedBox(height: AppDimens.errorSpacing),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingXXL + 12),
          child: Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.error,
              fontSize: AppDimens.fontS,
            ),
          ),
        ),
        SizedBox(height: AppDimens.paddingXL),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _hasError = false;
              _statusMessage = Strings.statusRetrying;
            });
            _loadConfig();
          },
          icon: Icon(Icons.refresh, color: AppColors.primary),
          label: Text(
            Strings.btnRetry,
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}