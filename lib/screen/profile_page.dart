import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/models/student_detail_model.dart';

const Color _bg = Color(0xFFF4F1EE);
const Color _surface = Colors.white;
const Color _borderSoft = Color(0xFFE8E4DF);
const Color _text = Color(0xFF1A1A2E);
const Color _muted = Color(0xFF7E7E8F);
const Color _primary = Color(0xFF7C1C1C);
const Color _primaryDeep = Color(0xFF5A1212);
const Color _primarySoft = Color(0xFF9E3535);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final String fullName = student.studentName.trim().isEmpty
        ? 'Student'
        : student.studentName.trim();
    final String email = student.email.trim().isEmpty
        ? 'No email available'
        : student.email;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildHeader(context, fullName, email),
            Transform.translate(
              offset: const Offset(0, -24),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                child: Container(
                  color: _bg,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _InfoSection(
                        label: 'ACADEMIC INFO',
                        items: <_InfoRowData>[
                          // _InfoRowData(
                          //   Icons.badge_outlined,
                          //   'Student ID',
                          //   _displayValue(student.studentId),
                          // ),
                          _InfoRowData(
                            Icons.confirmation_number_outlined,
                            'Admission No.',
                            _displayValue(student.admNo),
                          ),
                          _InfoRowData(
                            Icons.event_outlined,
                            'Date of Birth',
                            _displayValue(student.dob),
                          ),
                          _InfoRowData(
                            Icons.calendar_month_outlined,
                            'Admission Date',
                            _displayValue(student.admissionDate),
                          ),
                          _InfoRowData(
                            Icons.school_outlined,
                            'Class',
                            _displayValue(student.className),
                          ),
                          _InfoRowData(
                            Icons.class_outlined,
                            'Section',
                            _displayValue(student.section),
                          ),
                          _InfoRowData(
                            Icons.category_outlined,
                            'Category',
                            _displayValue(student.category),
                          ),
                          _InfoRowData(
                            Icons.pin_outlined,
                            'Roll No.',
                            _displayValue(student.rollNo),
                          ),
                          _InfoRowData(
                            Icons.assignment_ind_outlined,
                            'Course ID',
                            _displayValueInt(student.courseId),
                          ),
                          _InfoRowData(
                            Icons.numbers_outlined,
                            'Section ID',
                            _displayValueInt(student.secId),
                          ),
                          _InfoRowData(
                            Icons.account_tree_outlined,
                            'Branch ID',
                            _displayValueInt(student.branchId),
                          ),
                          _InfoRowData(
                            Icons.toggle_on_outlined,
                            'Active',
                            _displayValue(student.active),
                          ),
                          _InfoRowData(
                            Icons.account_balance_wallet_outlined,
                            'Balance Amount',
                            _displayAmount(student.balanceDue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoSection(
                        label: 'PERSONAL INFO',
                        items: <_InfoRowData>[
                          _InfoRowData(
                            Icons.person_outline,
                            'Student Name',
                            _displayValue(student.studentName),
                          ),
                          _InfoRowData(
                            Icons.male_outlined,
                            'Gender',
                            _displayValue(student.gender),
                          ),
                          _InfoRowData(
                            Icons.bloodtype_outlined,
                            'Blood Group',
                            _displayValue(student.bloodGroup),
                          ),
                          _InfoRowData(
                            Icons.person_outline_rounded,
                            "Father's Name",
                            _displayValue(student.fatherName),
                          ),
                          _InfoRowData(
                            Icons.person_2_outlined,
                            "Mother's Name",
                            _displayValue(student.motherName),
                          ),
                          _InfoRowData(
                            Icons.call_outlined,
                            'Mobile',
                            _displayValue(student.contact),
                          ),
                          _InfoRowData(
                            Icons.mail_outline,
                            'Email',
                            _displayValue(student.email),
                          ),
                          _InfoRowData(
                            Icons.directions_bus_outlined,
                            'Conveyance',
                            _displayValue(student.conveyance),
                          ),
                          _InfoRowData(
                            Icons.house_siding_outlined,
                            'Hostel',
                            _displayValue(student.hostel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoSection(
                        label: 'SCHOOL INFO',
                        items: <_InfoRowData>[
                          _InfoRowData(
                            Icons.apartment_outlined,
                            'School Name',
                            _displayValue(student.schoolName),
                          ),
                          _InfoRowData(
                            Icons.numbers_outlined,
                            'Branch Code',
                            _displayValue(student.shortName),
                          ),
                          _InfoRowData(
                            Icons.location_on_outlined,
                            'Address Line 1',
                            _displayValue(student.schoolAddress1),
                          ),
                          _InfoRowData(
                            Icons.location_on_outlined,
                            'Address Line 2',
                            _displayValue(student.schoolAddress2),
                          ),
                          _InfoRowData(
                            Icons.phone_outlined,
                            'School Phone',
                            _displayValue(student.schoolPhone),
                          ),
                          _InfoRowData(
                            Icons.alternate_email_outlined,
                            'School Email',
                            _displayValue(student.schoolEmail),
                          ),
                          _InfoRowData(
                            Icons.language_outlined,
                            'Website',
                            _displayValue(student.schoolWebsite),
                          ),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context, String name, String email) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.9, -0.8),
          end: Alignment(-0.7, 0.9),
          colors: <Color>[_primary, _primaryDeep],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: 12,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 34,
            bottom: -50,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  GestureDetector(
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
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials(name),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _displayValue(String value) {
    final String trimmed = value.trim();
    return trimmed.isEmpty ? 'Not set' : trimmed;
  }

  static String _displayValueInt(int value) {
    return value == 0 ? 'Not set' : value.toString();
  }

  static String _displayAmount(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  static String _initials(String name) {
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
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.label, required this.items});

  final String label;
  final List<_InfoRowData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSoft),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  color: _muted,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
            child: Column(
              children: items
                  .map(
                    (_InfoRowData item) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _InfoRow(item: item),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _InfoRowData item;

  @override
  Widget build(BuildContext context) {
    final bool isNotSet = item.value == 'Not set';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFFCFBF9),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF1F1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 16, color: _primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: GoogleFonts.dmSans(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: isNotSet ? _muted : _primarySoft,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
