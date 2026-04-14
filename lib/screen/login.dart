import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/models/config_model.dart';
import '../api/models/login_model.dart';
import '../api/post.dart';
import '../extras/dimension.dart';
import 'home.dart';

const Color _bg = Color(0xFFF4F6FA);
const Color _surface = Colors.white;
const Color _border = Color(0xFFE3E7EE);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF2A7FFF);
const Color _danger = Color(0xFFE2572C);

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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppDimens.durationAnimation),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
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

    try {
      final LoginResponse response = await _post.login(
        LoginRequest(
          admNo: _admissionController.text.trim(),
          dob: _dobController.text.trim(),
        ),
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

  @override
  void dispose() {
    _animationController.dispose();
    _admissionController.dispose();
    _dobController.dispose();
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingL,
                  vertical: AppDimens.paddingXXL,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppDimens.paddingXXL),
                        _buildLoginCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            shape: BoxShape.circle,
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.school_rounded, size: 36, color: _primary),
        ),
        const SizedBox(height: AppDimens.paddingL),
        const Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _text,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: AppDimens.paddingS),
        const Text(
          'Sign in with your admission number and date of birth.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: AppDimens.fontM,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            controller: _admissionController,
            label: 'Admission Number',
            hintText: 'Enter admission number',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Admission number is required.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimens.paddingL),
          _buildInputField(
            controller: _dobController,
            label: 'Date of Birth',
            hintText: 'DD-MM-YYYY',
            keyboardType: TextInputType.datetime,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.calendar_month_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Date of birth is required.';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppDimens.paddingL),
            _buildErrorMessage(),
          ],
          const SizedBox(height: AppDimens.paddingXL),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String? Function(String?) validator,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: AppDimens.fontS,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          style: const TextStyle(
            color: _text,
            fontSize: AppDimens.fontXL,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF9AA3B2),
              fontSize: AppDimens.fontM,
            ),
            prefixIcon: Icon(prefixIcon, color: _muted),
            filled: true,
            fillColor: const Color(0xFFF9FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingM,
              vertical: AppDimens.paddingM,
            ),
            enabledBorder: _buildInputBorder(_border),
            focusedBorder: _buildInputBorder(_primary),
            errorBorder: _buildInputBorder(_danger),
            focusedErrorBorder: _buildInputBorder(_danger),
            errorStyle: const TextStyle(
              color: _danger,
              fontSize: AppDimens.fontS,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1.4),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD7CA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _danger, size: 20),
          const SizedBox(width: AppDimens.paddingS),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
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
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF97BAF5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimens.fontXL,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: AppDimens.loaderSize,
                height: AppDimens.loaderSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Text('Log In'),
      ),
    );
  }
}
