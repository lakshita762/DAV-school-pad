import 'package:flutter/material.dart';

import '../api/models/student_detail_model.dart';
import '../extras/dimension.dart';

const Color _bg = Color(0xFFF4F4F4);
const Color _surface = Colors.white;
const Color _borderSoft = Color(0xFFFFF3E8);
const Color _text = Color(0xFF1C2430);
const Color _muted = Color(0xFF6D7786);
const Color _primary = Color(0xFF75292A);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final String fullName =
        student.studentName.trim().isEmpty ? 'Student' : student.studentName.trim();
    final String email = student.email.trim().isEmpty ? 'No email available' : student.email;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingL,
          AppDimens.paddingM,
          AppDimens.paddingL,
          AppDimens.paddingXXL,
        ),
        children: [
          _ProfileHeaderCard(
            name: fullName,
            subtitle: email,
            initials: _initials(fullName),
          ),
          const SizedBox(height: AppDimens.paddingM),
          _ProfileMenuSection(
            items: <_ProfileMenuItemData>[
              _ProfileMenuItemData(
                icon: Icons.badge_outlined,
                title: 'Admission Number',
                value: _orDash(student.adm_no),
              ),
              _ProfileMenuItemData(
                icon: Icons.calendar_month_outlined,
                title: 'Admission Date',
                value: _orDash(student.admissionDate),
              ),
              _ProfileMenuItemData(
                icon: Icons.school_outlined,
                title: 'Class & Section',
                value:
                    '${_orDash(student.className)}${student.section.trim().isEmpty ? '' : '  |  ${student.section.trim()}'}',
              ),
              _ProfileMenuItemData(
                icon: Icons.category_outlined,
                title: 'Category',
                value: _orDash(student.category),
              ),
              _ProfileMenuItemData(
                icon: Icons.person_outline,
                title: 'Gender',
                value: _orDash(student.gender),
              ),
              _ProfileMenuItemData(
                icon: Icons.bloodtype_outlined,
                title: 'Blood Group',
                value: _orDash(student.bloodGroup),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingM),
          _ProfileMenuSection(
            items: <_ProfileMenuItemData>[
              _ProfileMenuItemData(
                icon: Icons.family_restroom_outlined,
                title: "Father's Name",
                value: _orDash(student.fatherName),
              ),
              _ProfileMenuItemData(
                icon: Icons.family_restroom_outlined,
                title: "Mother's Name",
                value: _orDash(student.motherName),
              ),
              _ProfileMenuItemData(
                icon: Icons.phone_outlined,
                title: 'Contact',
                value: _orDash(student.contact),
              ),
              _ProfileMenuItemData(
                icon: Icons.mail_outline,
                title: 'Email',
                value: _orDash(student.email),
              ),
              _ProfileMenuItemData(
                icon: Icons.apartment_outlined,
                title: 'School',
                value: _orDash(student.schoolName),
              ),
              _ProfileMenuItemData(
                icon: Icons.menu_book_outlined,
                title: 'Board',
                value: _orDash(student.board),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  static String _orDash(String value) => value.trim().isEmpty ? '--' : value;
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.subtitle,
    required this.initials,
  });

  final String name;
  final String subtitle;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingS,
        vertical: AppDimens.paddingM,
      ),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE1E1E1), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.isEmpty ? 'ST' : initials,
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingS),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
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
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.items});

  final List<_ProfileMenuItemData> items;

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
          ...List<Widget>.generate(items.length, (int index) {
            final _ProfileMenuItemData row = items[index];
            final bool hasDivider = index != items.length - 1;
            return Column(
              children: [
                _ProfileMenuItem(item: row),
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

class _ProfileMenuItemData {
  _ProfileMenuItemData({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({required this.item});

  final _ProfileMenuItemData item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingM,
        vertical: AppDimens.paddingM,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, size: 18, color: _primary),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: _text,
                fontSize: AppDimens.fontM,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _muted,
                fontWeight: FontWeight.w500,
                fontSize: AppDimens.fontS,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
