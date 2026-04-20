import 'package:dav_school_app/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/client.dart';
import '../api/get.dart';
import '../api/models/student_detail_model.dart';
import '../extras/dimension.dart';
import '../extras/string.dart';

const Color _bg = Color(0xFFF6F8FD);
const Color _surface = Colors.white;
const Color _borderSoft = Color(0xFFE8EDF6);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF3E7BFA);
const Color _primaryDark = Color(0xFF245FDC);
const Color _danger = Color(0xFFE2572C);
const Color _success = Color(0xFF2E9D55);

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
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingL,
              AppDimens.paddingL,
              AppDimens.paddingL,
              AppDimens.paddingXXL,
            ),
            children: [
              _buildHeader(student),
              const SizedBox(height: AppDimens.paddingL),
              const Text(
                'Quick Access',
                style: TextStyle(
                  color: _muted,
                  fontSize: AppDimens.fontS,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppDimens.paddingS),
              _buildQuickAccess(student),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StudentDetailData student) {
    final String initials = _getInitials(student.studentName);
    final String subtitle = [
      if (student.className.isNotEmpty) student.className,
      if (student.section.isNotEmpty) 'Section ${student.section}',
    ].join('  ');

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
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
                  color: const Color(0xFFEAF1FF),
                  border: Border.all(color: const Color(0xFFD8E4FB)),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: _primaryDark,
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
                  backgroundColor: const Color(0xFFEAF1FF),
                  foregroundColor: _primaryDark,
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                tooltip: 'Logout',
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingM),
          Text(
            'Hello, ${student.studentName.isEmpty ? 'Student' : student.studentName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontSize: 27,
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
              color: _muted,
              fontSize: AppDimens.fontS,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(StudentDetailData student) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            subtitle: 'Student details',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProfilePage(student: student),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppDimens.paddingS),
        Expanded(
          child: _ActionCard(
            icon: Icons.credit_card_outlined,
            title: 'Payments',
            subtitle: 'Fee status',
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _borderSoft),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _primary, size: 20),
            ),
            const SizedBox(height: AppDimens.paddingS),
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
          colors: <Color>[Color(0xFF4A86FF), Color(0xFF2C69E6)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E2A63D8),
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
              color: Color(0xFFE3ECFF),
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
              color: const Color(0xFFAEE8C8),
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
              color: pending ? const Color(0xFFFFF1EC) : const Color(0xFFECFAF1),
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

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        children: [
          _ProfileHeader(student: student),
          const SizedBox(height: AppDimens.paddingL),
          _DetailCard(
            title: 'Student Details',
            rows: <_DetailRowData>[
              _DetailRowData('Student name', _orDash(student.studentName)),
              _DetailRowData('Admission date', _orDash(student.admissionDate)),
              _DetailRowData("Father's name", _orDash(student.fatherName)),
              _DetailRowData("Mother's name", _orDash(student.motherName)),
              _DetailRowData('Date of birth', _orDash(student.dob)),
              _DetailRowData('Gender', _orDash(student.gender)),
            ],
          ),
          const SizedBox(height: AppDimens.paddingM),
          _DetailCard(
            title: 'Academic Details',
            rows: <_DetailRowData>[
              _DetailRowData('Course', _orDash(student.className)),
              _DetailRowData('Section', _orDash(student.section)),
              _DetailRowData('Category', _orDash(student.category)),
            ],
          ),
        ],
      ),
    );
  }

  static String _orDash(String value) => value.trim().isEmpty ? '--' : value;
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final String initials = student.studentName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .map((String e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    final String subtitle = [
      if (student.className.trim().isNotEmpty) student.className,
      if (student.section.trim().isNotEmpty) 'Section ${student.section}',
    ].join('  ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEAF1FF),
              border: Border.all(color: const Color(0xFFD8E4FB)),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? 'ST' : initials,
              style: const TextStyle(
                color: _primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            student.studentName.isEmpty ? 'Student' : student.studentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
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
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.rows});

  final String title;
  final List<_DetailRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingM,
              AppDimens.paddingM,
              AppDimens.paddingM,
              AppDimens.paddingS,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: _muted,
                  fontSize: AppDimens.fontS,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          ...List<Widget>.generate(rows.length, (int index) {
            final _DetailRowData row = rows[index];
            final bool hasDivider = index != rows.length - 1;
            return Column(
              children: [
                _DetailRow(label: row.label, value: row.value),
                if (hasDivider)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF0F3F8),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DetailRowData {
  _DetailRowData(this.label, this.value);

  final String label;
  final String value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: AppDimens.fontS,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _text,
                fontWeight: FontWeight.w600,
                fontSize: AppDimens.fontM,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
