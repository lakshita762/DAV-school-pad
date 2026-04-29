import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/models/config_model.dart';
import '../api/models/login_model.dart';
import '../api/post.dart';
import '../extras/color.dart';
import '../extras/dimension.dart';
import 'home.dart';

const Color _bg = AppColors.scaffold;
const Color _surface = AppColors.card;
const Color _border = Color(0xFFCCCCCC);
const Color _text = AppColors.textPrimary;
const Color _muted = AppColors.textSecondary;
const Color _primary = AppColors.primary;
const Color _primaryDeep = AppColors.primaryDeep;
const Color _danger = AppColors.errorText;
const String _logoAsset = 'assets/images/schoolkonnect-login.jpg';

class Login extends StatefulWidget {
  const Login({super.key, required this.items});

  final List<ConfigModel> items;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final Post _post = Post();
  static const String _tempLoginUrl = '/api/student-login';
  static const String _tokenStorageKey = 'auth_bearer_token';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _admissionController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  List<ConfigModel> _urlItems = <ConfigModel>[];
  String _mainUrl = '';

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  Future<void> _loadConfig() async {
    final Future<void> minDelay = Future.delayed(
      Duration(milliseconds: AppDimens.durationSplashMin),
    );

    try {
      final results = await Future.wait(<Future<dynamic>>[
        _post.fetchConfig(),
        minDelay,
      ]);
      _urlItems = results[0] as List<ConfigModel>;
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _mainUrl = '';
    for (int i = 0; i < _urlItems.length; i++) {
      if (_codeController.text.trim() == _urlItems[i].code) {
        _mainUrl = _urlItems[i].url.substring(0, _urlItems[i].url.length - 1);
        break;
      }
    }
    print(_mainUrl);

    if (_mainUrl.isNotEmpty) {
      await _login();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No valid Code found';
      });
    }
  }

  Future<void> _login() async {
    try {
      final DioClient dioClient = DioClient();
      dioClient.changeBaseUrl(_mainUrl);

      final String dobForApi = _normalizeDobForApi(_dobController.text.trim());

      final LoginResponse response = await _post.login(
        LoginRequest(admNo: _admissionController.text.trim(), dob: dobForApi),
        _tempLoginUrl,
      );

      if (response.token.isNotEmpty) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenStorageKey, response.token);
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      final String message = response.message.isNotEmpty
          ? response.message
          : response.success
          ? 'Login successful.'
          : 'Login failed.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: response.success ? _primary : _danger,
        ),
      );

      if (response.success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomePage(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 10, now.month, now.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
    );

    if (pickedDate == null) return;

    _dobController.text = _formatDob(pickedDate);
  }

  String _formatDob(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day-$month-$year';
  }

  String _normalizeDobForApi(String raw) {
    final RegExp pattern = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$');
    final RegExpMatch? match = pattern.firstMatch(raw);
    if (match == null) return raw;

    final int first = int.parse(match.group(1)!);
    final int second = int.parse(match.group(2)!);
    final String year = match.group(3)!;

    int day = first;
    int month = second;

    if (first <= 12 && second > 12) {
      day = second;
      month = first;
    }

    return '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _admissionController.dispose();
    _dobController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double viewportHeight = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : MediaQuery.sizeOf(context).height;
                final bool keyboardOpen =
                    MediaQuery.viewInsetsOf(context).bottom > 0;

                final double heroHeight =
                    (viewportHeight * (keyboardOpen ? 0.38 : 0.45)).clamp(
                      keyboardOpen ? 220.0 : 280.0,
                      keyboardOpen ? 300.0 : 360.0,
                    );
                final double sheetMinHeight = math.max(
                  0.0,
                  viewportHeight - heroHeight + 24,
                );

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: viewportHeight),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        _buildHero(heroHeight, compact: keyboardOpen),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: heroHeight - 24,
                          child: _buildSheet(sheetMinHeight),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(double height, {required bool compact}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.9, -0.8),
          end: Alignment(-0.7, 0.9),
          colors: <Color>[_primary, _primaryDeep],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: compact ? 16 : 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: compact ? 116 : 138,
                    child: Image.asset(
                      _logoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.school_rounded,
                        color: AppColors.onPrimary,
                        size: 76,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),
                  // Text(
                  //   'Welcome Back!',
                  //   textAlign: TextAlign.center,
                  //   style: GoogleFonts.outfit(
                  //     color: AppColors.onPrimary,
                  //     fontSize: compact ? 32 : 38,
                  //     fontWeight: FontWeight.w700,
                  //     height: 1.04,
                  //   ),
                  // ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    'Welcome, Sign in to your student portal.',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: AppColors.onPrimary.withValues(alpha: 0.65),
                      fontSize: compact ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(double minHeight) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        color: _surface,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildInputField(
                controller: _admissionController,
                hintText: 'Admission Number',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.badge_outlined,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Admission number is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _dobController,
                hintText: 'Date of Birth (DD-MM-YYYY)',
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.calendar_month_outlined,
                suffixIcon: Icons.date_range_rounded,
                onSuffixTap: _pickDateOfBirth,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Date of birth is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _codeController,
                hintText: 'School Code',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.qr_code_2_rounded,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'School code is required.';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                _buildErrorMessage(),
              ],
              const SizedBox(height: 18),
              _buildLoginButton(),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  // children: <TextSpan>[
                  //   // const TextSpan(text: 'No account? '),
                  //   // TextSpan(
                  //   //   text: 'Contact school admin',
                  //   //   style: GoogleFonts.dmSans(
                  //   //     color: _primary,
                  //   //     fontWeight: FontWeight.w700,
                  //   //   ),
                  //   ),
                  // ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      readOnly: readOnly,
      onTap: onTap,
      style: GoogleFonts.dmSans(
        color: _text,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.dmSans(
          color: _muted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.iconColor, size: 20),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon, color: AppColors.iconColor, size: 20),
              ),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        enabledBorder: _buildInputBorder(_border),
        focusedBorder: _buildInputBorder(_primary),
        errorBorder: _buildInputBorder(_danger),
        focusedErrorBorder: _buildInputBorder(_danger),
        errorStyle: GoogleFonts.dmSans(
          color: _danger,
          fontSize: AppDimens.fontS,
        ),
      ),
    );
  }

  OutlineInputBorder _buildInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: _danger, size: 20),
          const SizedBox(width: AppDimens.paddingS),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.dmSans(
                color: _danger,
                fontSize: AppDimens.fontS,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.9, -0.8),
          end: Alignment(-0.7, 0.9),
          colors: <Color>[Color(0xFF074417), Color(0xFF074417)],
        ),
        borderRadius: BorderRadius.circular(14),
        // boxShadow: const <BoxShadow>[
        //   BoxShadow(
        //     color: AppColors.primaryShadow,
        //     blurRadius: 20,
        //     offset: Offset(0, 8),
        //   ),
        // ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.onPrimary,
                ),
              )
            : const Text('Sign in'),
      ),
    );
  }
}
