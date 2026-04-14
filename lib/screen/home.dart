import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/get.dart';
import '../api/models/student_detail_model.dart';
import '../extras/dimension.dart';

const Color _bg = Color(0xFFF4F6FA);
const Color _surface = Colors.white;
const Color _border = Color(0xFFE3E7EE);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF2A7FFF);
const Color _danger = Color(0xFFE2572C);
const Color _success = Color(0xFF2E9D55);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _tokenStorageKey = 'auth_bearer_token';
  final GetApi _getApi = GetApi();

  bool _isLoading = true;
  String? _error;
  StudentDetailData? _student;

  @override
  void initState() {
    super.initState();
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                  ),
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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingL,
              AppDimens.paddingL,
              AppDimens.paddingL,
              AppDimens.paddingXXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(student),
                const SizedBox(height: AppDimens.paddingL),
                _buildBalanceCard(student),
                const SizedBox(height: AppDimens.paddingL),
                const Text(
                  'Quick Access',
                  style: TextStyle(
                    color: _muted,
                    fontSize: AppDimens.fontS,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingS),
                _buildQuickAccess(student),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(StudentDetailData student) {
    final String initials = _getInitials(student.studentName);
    final String subtitle = [
      if (student.className.isNotEmpty) student.className,
      if (student.section.isNotEmpty) student.section,
      if (student.schoolName.isNotEmpty) student.schoolName,
    ].join(' · ');

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAF2FF),
            border: Border.all(color: _border),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              color: Color(0xFF1B4F9E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning, ${student.studentName.isEmpty ? 'Student' : student.studentName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle.isEmpty ? 'Student dashboard' : subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _muted,
                  fontSize: AppDimens.fontS,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(StudentDetailData student) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance Due',
            style: TextStyle(color: _muted, fontSize: AppDimens.fontS),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(student.balanceDue),
            style: const TextStyle(
              color: _danger,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: student.paidProgress,
              minHeight: 6,
              color: _danger,
              backgroundColor: const Color(0xFFE8EAF0),
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid ${_formatCurrency(student.paidAmount)}',
                style: const TextStyle(color: _muted, fontSize: AppDimens.fontS),
              ),
              Text(
                'Total ${_formatCurrency(student.totalAmount)}',
                style: const TextStyle(color: _muted, fontSize: AppDimens.fontS),
              ),
            ],
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

  String _formatCurrency(double amount) {
    if (amount % 1 == 0) return 'INR ${amount.toInt()}';
    return 'INR ${amount.toStringAsFixed(2)}';
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
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _primary, size: 20),
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              title,
              style: const TextStyle(
                color: _text,
                fontSize: AppDimens.fontL,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: _muted,
                fontSize: AppDimens.fontS,
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
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: _text,
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
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
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
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total balance due', style: TextStyle(color: _muted)),
          const SizedBox(height: 4),
          Text(
            student.balanceDue % 1 == 0
                ? 'INR ${student.balanceDue.toInt()}'
                : 'INR ${student.balanceDue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: _danger,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: student.paidProgress,
              minHeight: 6,
              color: _danger,
              backgroundColor: const Color(0xFFE8EAF0),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: pending
                  ? const Color(0xFFFFEFEA)
                  : const Color(0xFFEAF8EE),
              borderRadius: BorderRadius.circular(10),
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
                  style: const TextStyle(color: _text, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: AppDimens.fontS),
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
        elevation: 0,
        backgroundColor: _bg,
        foregroundColor: _text,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFEAF2FF),
            child: Text(
              initials.isEmpty ? 'ST' : initials,
              style: const TextStyle(
                color: Color(0xFF1B4F9E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            student.studentName.isEmpty ? 'Student' : student.studentName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
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
                  const Divider(height: 1, thickness: 1, color: _border),
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
