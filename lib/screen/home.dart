import 'package:school_konnect/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/client.dart';
import '../api/get.dart';
import '../api/models/student_detail_model.dart';
import '../extras/string.dart';
import 'profile_page.dart';

const Color _bg = Color(0xFFF3F7FB);
const Color _surface = Colors.white;
const Color _borderSoft = Color(0xFFD8E3EE);
const Color _text = Color(0xFF0C1F41);
const Color _muted = Color(0xFF5D7085);
const Color _primary = Color(0xFF0C1F41);
const Color _primaryDeep = Color(0xFF07152D);
const Color _primarySoft = Color(0xFF8CAAC9);
const Color _danger = Color(0xFFE2572C);
const Color _success = Color(0xFF16A34A);

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStudentDetail();
  }

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
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, color: _danger, size: 32),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: _text,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
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
        left: false,
        right: false,
        bottom: false,
        child: RefreshIndicator(
          color: _primary,
          onRefresh: _loadStudentDetail,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: <Widget>[_buildHeader(student), _buildHomeSheet(student)],
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
    final String sectionText = student.section.trim().isEmpty
        ? 'Not set'
        : student.section.trim();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.9, -0.8),
          end: Alignment(-0.7, 0.9),
          colors: <Color>[_primary, _primaryDeep],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 48),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: 10,
            top: -26,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 34,
            bottom: -54,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setString(Strings.tokenStorageKey, '');

                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const SplashScreen(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Good Morning,',
                style: GoogleFonts.dmSans(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      Icons.class_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Section $sectionText',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSheet(StudentDetailData student) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: Container(
          color: _bg,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.16,
            shrinkWrap: true,
            children: <Widget>[
              _PressableQuickCard(
                title: 'Profile',
                subtitle: 'Student details',
                icon: Icons.badge_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProfilePage(student: student),
                    ),
                  );
                },
              ),
              _PressableQuickCard(
                title: 'Payments',
                subtitle: 'Fee status',
                icon: Icons.account_balance_wallet_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PaymentsPage(student: student),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
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
      shortName: '',
      schoolId: 0,
      schoolAddress1: '',
      schoolAddress2: '',
      schoolPhone: '',
      schoolEmail: '',
      schoolWebsite: '',
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
      admNo: '',
      active: '',
      email: '',
      conveyance: '',
      hostel: '',
      courseId: 0,
      secId: 0,
      branchId: 0,
      photographPath: '',
      photographAttachmentId: 0,
      photographFileExt: '',
    );
  }
}

class _PressableQuickCard extends StatefulWidget {
  const _PressableQuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_PressableQuickCard> createState() => _PressableQuickCardState();
}

class _PressableQuickCardState extends State<_PressableQuickCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          onHighlightChanged: (bool value) {
            setState(() {
              _pressed = value;
            });
          },
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFEFF5FA),
                  ),
                  alignment: Alignment.center,
                  child: Icon(widget.icon, color: _primary, size: 20),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: GoogleFonts.outfit(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.dmSans(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
    const double headerHeight = 118;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Stack(
          children: <Widget>[
            ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                _buildPaymentsHeader(context, headerHeight),
                const SizedBox(height: 138),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'BREAKDOWN',
                    style: GoogleFonts.outfit(
                      color: _muted,
                      fontSize: 11,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      _PaymentItem(
                        icon: Icons.pending_actions_outlined,
                        title: 'Balance due',
                        subtitle: 'Current payable amount',
                        amount: _formatCurrency(student.balanceDue),
                        amountColor: student.balanceDue == 0
                            ? _success
                            : _primarySoft,
                      ),
                      _PaymentItem(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Paid amount',
                        subtitle: 'Received till now',
                        amount: _formatCurrency(student.paidAmount),
                        amountColor: _success,
                      ),
                      _PaymentItem(
                        icon: Icons.request_quote_outlined,
                        title: 'Total amount',
                        subtitle: 'Academic year total',
                        amount: _formatCurrency(student.totalAmount),
                        amountColor: student.totalAmount == 0
                            ? _success
                            : _text,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _GradientActionButton(
                    label: 'Pay Now',
                    icon: Icons.credit_card_rounded,
                    onPressed: () {
                      openUrl(
                        '${DioClient.baseUrl}/student-autologin?dob=${student.dob}&adm_no=${student.admNo}',
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            Positioned(
              top: headerHeight - 20,
              left: 20,
              right: 20,
              child: _BalanceCard(student: student),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsHeader(BuildContext context, double height) {
    return Container(
      height: height,
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
          Positioned(
            right: 12,
            top: -24,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
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
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String _formatCurrency(double amount) {
    if (amount % 1 == 0) return 'INR ${amount.toInt()}';
    return 'INR ${amount.toStringAsFixed(2)}';
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final bool isClear = student.balanceDue <= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x268CAAC9),
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Total Balance Due',
            style: GoogleFonts.dmSans(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            student.balanceDue % 1 == 0
                ? 'INR ${student.balanceDue.toInt()}'
                : 'INR ${student.balanceDue.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: _text,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isClear
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFFFF2F2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isClear ? 'All Clear' : 'Payment Due',
              style: GoogleFonts.dmSans(
                color: isClear ? _success : _primarySoft,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  const _PaymentItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF5FA),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: _primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              color: amountColor,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.9, -0.8),
          end: Alignment(-0.7, 0.9),
          colors: <Color>[_primary, _primaryDeep],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x590C1F41),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}
