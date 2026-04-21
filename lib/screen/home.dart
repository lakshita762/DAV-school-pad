import 'package:dav_school_app/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/client.dart';
import '../api/get.dart';
import '../api/models/student_detail_model.dart';
import '../extras/dimension.dart';
import '../extras/string.dart';
import 'profile_page.dart';

const Color _bg = Color(0xFFF4F4F4);
const Color _surface = Colors.white;
const Color _borderSoft = Color(0xFFFFF3E8);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF75292A);
const Color _danger = Color(0xFFE2572C);
const Color _success = Color(0xFF75292A);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const String _tokenStorageKey = 'auth_bearer_token';
  final GetApi _getApi = GetApi();

  bool _isLoading = true;
  String? _error;
  StudentDetailData? _student;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadStudentDetail();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStudentDetail();
  }

  Future<void> _loadStudentDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString(_tokenStorageKey) ?? '';
      if (token.isEmpty) {
        throw Exception('No auth token found. Please log in again.');
      }

      final StudentDetailResponse response = await _getApi.fetchStudentDetail(
        token: token,
      );

      if (!mounted) return;
      setState(() {
        _student = response.data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _primary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: _danger, size: 32),
                const SizedBox(height: AppDimens.paddingS),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _text),
                ),
                const SizedBox(height: AppDimens.paddingL),
                ElevatedButton(
                  onPressed: _loadStudentDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final StudentDetailData student = _student ?? _fallbackStudent();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _loadStudentDetail,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(student),
              _buildHomeBody(student),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StudentDetailData student) {
    final String initials = _getInitials(student.studentName);
    final String displayName = _toTitleCase(
      student.studentName.isEmpty ? 'Student' : student.studentName,
    );
    final String subtitle = [
      if (student.className.isNotEmpty) student.className,
      if (student.section.isNotEmpty) 'Section ${student.section}',
    ].join('  ');

    return Container(
      color: _primary,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingL,
        AppDimens.paddingL,
        AppDimens.paddingL,
        AppDimens.paddingXXL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString(Strings.tokenStorageKey, '');

                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _primary,
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                tooltip: 'Logout',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingM),
          Text(
            'Hello, $displayName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle.isEmpty ? 'Welcome back' : subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFE5F3E8),
              fontSize: AppDimens.fontL,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody(StudentDetailData student) {
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingL,
        AppDimens.paddingM,
        AppDimens.paddingL,
        AppDimens.paddingXXL,
      ),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: _buildQuickAccess(student),
    );
  }

  Widget _buildQuickAccess(StudentDetailData student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: _ActionCard(
              icon: Icons.manage_accounts_rounded,
              title: 'Profile',
              subtitle: 'Student Details',
              iconBg: const Color(0xFFFFF3E8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfilePage(student: student),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppDimens.paddingL),
          SizedBox(
            width: 150,
            child: _ActionCard(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Payment',
              subtitle: 'Fee Status',
              iconBg: const Color(0xFFFFF3E8),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentsPage(student: student),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _toTitleCase(String value) {
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .map(
          (String part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  StudentDetailData _fallbackStudent() {
    return StudentDetailData(
      studentName: '',
      studentId: '',
      admissionDate: '',
      className: '',
      section: '',
      category: '',
      rollNo: '',
      fatherName: '',
      motherName: '',
      schoolName: '',
      board: '',
      academicYear: '',
      teacherName: '',
      dob: '',
      gender: '',
      bloodGroup: '',
      contact: '',
      balanceDue: 0,
      paidAmount: 0,
      totalAmount: 0,
      attendancePercent: 0,
      dueDate: '',
      adm_no: '',
      active: '',
      email: '',
      conveyance: '',
      hostel: '',
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 156,
        padding: const EdgeInsets.all(AppDimens.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E2E2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primary, size: 20),
            ),
            const SizedBox(height: AppDimens.paddingM),
            Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: AppDimens.fontXL,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: _muted,
                fontSize: AppDimens.fontS,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Payments'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          _PaymentSummary(student: student),
          const SizedBox(height: AppDimens.paddingL),
          const Text(
            'Breakdown',
            style: TextStyle(
              color: _muted,
              fontSize: AppDimens.fontS,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          _PaymentItem(
            title: 'Balance due',
            subtitle: 'Current payable amount',
            amount: _formatCurrency(student.balanceDue),
            pending: student.balanceDue > 0,
          ),
          _PaymentItem(
            title: 'Paid amount',
            subtitle: 'Received till now',
            amount: _formatCurrency(student.paidAmount),
            pending: false,
          ),
          _PaymentItem(
            title: 'Total amount',
            subtitle: 'Academic year total',
            amount: _formatCurrency(student.totalAmount),
            pending: student.balanceDue > 0,
          ),
          const SizedBox(height: AppDimens.paddingM),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                openUrl(
                  '${DioClient.baseUrl}/student-autologin?dob=${student.dob}&adm_no=${student.adm_no}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: AppDimens.fontL, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static String _formatCurrency(double amount) {
    if (amount % 1 == 0) return 'INR ${amount.toInt()}';
    return 'INR ${amount.toStringAsFixed(2)}';
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF75292A), Color(0xFF75292A)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3375292A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total balance due',
            style: TextStyle(
              color: Color(0xFFFFF3E8),
              fontSize: AppDimens.fontS,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            student.balanceDue % 1 == 0
                ? 'INR ${student.balanceDue.toInt()}'
                : 'INR ${student.balanceDue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 34,
              height: 1,
            ),
          ),
          const SizedBox(height: AppDimens.paddingM),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: student.paidProgress,
              minHeight: 7,
              color: const Color(0xFFFFF3E8),
              backgroundColor: Colors.white.withOpacity(0.32),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  const _PaymentItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.pending,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingS),
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: pending ? const Color(0xFFFFF1EC) : const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              pending ? Icons.pending_actions_outlined : Icons.check_circle,
              color: pending ? _danger : _success,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimens.fontXL,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: AppDimens.fontS,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: pending ? _danger : _success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

