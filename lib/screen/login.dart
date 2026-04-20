import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/models/config_model.dart';
import '../api/models/login_model.dart';
import '../api/post.dart';
import '../extras/dimension.dart';
import 'package:dav_school_app/screen/home.dart';

const Color _bg = Color(0xFFEFF3FF);
const Color _surface = Colors.white;
const Color _border = Color(0xFFE3E7EE);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF2A7FFF);
const Color _primaryDark = Color(0xFF0D4FC2);
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
  final TextEditingController _codeController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  List<ConfigModel> _urlItems = [];
  String _mainUrl = "";
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  Future<void> _loadConfig() async {
    final Future<void> minDelay =
        Future.delayed(Duration(milliseconds: AppDimens.durationSplashMin));

    try {
      final results = await Future.wait([_post.fetchConfig(), minDelay]);
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

    for(int i = 0; i< _urlItems.length; i++){
      if(_codeController.text == _urlItems[i].code){
        _mainUrl = _urlItems[i].url;
        break;
      }
    }

    if(_mainUrl.isNotEmpty){
      _login();
    }else{
      setState(() {
        _isLoading = false;
        _errorMessage = 'No valid Code found';
      });
    }


  }

  Future<void> _login() async {
    try {
      final dioClient = DioClient();

      dioClient.changeBaseUrl(_mainUrl);

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
            child: Stack(
              children: [
                const Positioned(
                  top: -90,
                  right: -70,
                  child: _BackdropBlob(
                    size: 240,
                    color: Color(0xFFBCD6FF),
                  ),
                ),
                const Positioned(
                  left: -100,
                  bottom: -120,
                  child: _BackdropBlob(
                    size: 280,
                    color: Color(0xFFD7E7FF),
                  ),
                ),
                Center(
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
              ],
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
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF3B8CFF), Color(0xFF1D67E0)],
            ),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x332A7FFF),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, size: 42, color: Colors.white),
        ),
        const SizedBox(height: AppDimens.paddingM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE4EEFF),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'STUDENT PORTAL',
            style: TextStyle(
              color: _primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
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
      padding: const EdgeInsets.all(AppDimens.paddingXL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 30,
            offset: Offset(0, 10),
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
          const SizedBox(height: AppDimens.paddingL),
          _buildInputField(
            controller: _codeController,
            label: 'School Code',
            hintText: 'Enter school code',
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'School Code is required.';
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF2E84FF), Color(0xFF125DD8)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x332A7FFF),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Log In'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}

class _BackdropBlob extends StatelessWidget {
  const _BackdropBlob({required this.size, required this.color});

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
