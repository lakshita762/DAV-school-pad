import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/client.dart';
import '../api/post.dart';
import '../api/models/student_detail_model.dart';
import '../extras/color.dart';
import '../extras/string.dart';

const Color _bg = AppColors.scaffold;
const Color _surface = AppColors.card;
const Color _borderSoft = Color(0xFFCCCCCC);
const Color _text = AppColors.textPrimary;
const Color _muted = AppColors.textSecondary;
const Color _primary = AppColors.primary;
const Color _primaryDeep = AppColors.primaryDeep;
const Color _primarySoft = AppColors.primarySoft;
const Color _danger = AppColors.errorText;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.student});

  final StudentDetailData student;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final Post _post = Post();

  late StudentDetailData _student;
  bool _isSavingMissingInfo = false;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _parseDob(_dobController.text) ??
        DateTime(now.year - 10, now.month, now.day);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: _primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;
    _dobController.text = _formatDob(pickedDate);
  }

  Future<void> _saveMissingInfo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSavingMissingInfo = true;
    });

    final String phone = _phoneController.text.trim();
    final String dob = _dobController.text.trim();
    final String email = _emailController.text.trim();

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString(Strings.tokenStorageKey) ?? '';
      if (token.isEmpty) {
        throw Exception('No auth token found. Please log in again.');
      }

      final Map<String, dynamic> response = await _post.updateStudent(
        token: token,
        mobile: _isMissing(_student.contact) ? phone : null,
        dob: _isMissing(_student.dob) ? dob : null,
        email: _isMissing(_student.email) ? email : null,
      );

      if (!mounted) return;
      setState(() {
        _student = _student.copyWith(
          contact: _isMissing(_student.contact) ? phone : null,
          dob: _isMissing(_student.dob) ? dob : null,
          email: _isMissing(_student.email) ? email : null,
        );
        _isSavingMissingInfo = false;
      });

      final String message = response['message']?.toString().trim() ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isEmpty ? 'Profile details updated.' : message),
          backgroundColor: _primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingMissingInfo = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: _danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final StudentDetailData student = _student;
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
            _buildHeader(
              context,
              fullName,
              email,
              student.photographPath,
              student.photographAttachmentId,
              student.photographFileExt,
            ),
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
                      if (_shouldShowMissingInfoForm(student)) ...<Widget>[
                        _MissingInfoForm(
                          formKey: _formKey,
                          student: student,
                          phoneController: _phoneController,
                          dobController: _dobController,
                          emailController: _emailController,
                          isSaving: _isSavingMissingInfo,
                          onPickDob: _pickDob,
                          onSave: _saveMissingInfo,
                        ),
                        const SizedBox(height: 16),
                      ],
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
                          // _InfoRowData(
                          //   Icons.calendar_month_outlined,
                          //   'Admission Date',
                          //   _displayValue(student.admissionDate),
                          // ),
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
                          // _InfoRowData(
                          //   Icons.assignment_ind_outlined,
                          //   'Course ID',
                          //   _displayValueInt(student.courseId),
                          // ),
                          // _InfoRowData(
                          //   Icons.numbers_outlined,
                          //   'Section ID',
                          //   _displayValueInt(student.secId),
                          // ),
                          // _InfoRowData(
                          //   Icons.account_tree_outlined,
                          //   'Branch ID',
                          //   _displayValueInt(student.branchId),
                          // ),
                          // _InfoRowData(
                          //   Icons.toggle_on_outlined,
                          //   'Active',
                          //   _displayValue(student.active),
                          // ),
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
                          // _InfoRowData(
                          //   Icons.bloodtype_outlined,
                          //   'Blood Group',
                          //   _displayValue(student.bloodGroup),
                          // ),
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
                            'Address',
                            _displayAddress(
                              student.schoolAddress1,
                              student.schoolAddress2,
                            ),
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

  Widget _buildHeader(
    BuildContext context,
    String name,
    String email,
    String photographPath,
    int photographAttachmentId,
    String photographFileExt,
  ) {
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
                        color: AppColors.onPrimary.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ProfileAvatar(
                initials: _initials(name),
                imageUrls: _resolvePhotographUrls(
                  photographPath,
                  photographAttachmentId,
                  photographFileExt,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: AppColors.onPrimary.withValues(alpha: 0.6),
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

  static String _displayAddress(String line1, String line2) {
    final List<String> parts = <String>[
      line1.trim(),
      line2.trim(),
    ].where((String value) => value.isNotEmpty).toList();
    return parts.isEmpty ? 'Not set' : parts.join(', ');
  }

  static List<String> _resolvePhotographUrls(
    String path,
    int attachmentId,
    String fileExt,
  ) {
    final String trimmed = path.trim();
    if (trimmed.isEmpty && attachmentId == 0) return <String>[];
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return <String>[trimmed];
    }

    final String baseUrl = DioClient.baseUrl.replaceFirst(RegExp(r'/$'), '');
    final List<String> urls = <String>[];
    if (attachmentId != 0) {
      urls.add('$baseUrl/attachments/$attachmentId');
    }

    if (trimmed.startsWith('/')) {
      urls.add('$baseUrl$trimmed');
    } else if (trimmed.contains('/')) {
      urls.add('$baseUrl/$trimmed');
    }

    final List<String> uniqueUrls = urls.toSet().toList();
    if (kDebugMode) {
      debugPrint('PROFILE PHOTO attachmentId=$attachmentId fileExt=$fileExt');
      debugPrint('PROFILE PHOTO urls=${uniqueUrls.join(', ')}');
    }
    return uniqueUrls;
  }

  bool _shouldShowMissingInfoForm(StudentDetailData student) {
    return _isMissing(student.contact) ||
        _isMissing(student.dob) ||
        _isMissing(student.email);
  }

  static bool _isMissing(String value) => value.trim().isEmpty;

  static String? _validatePhone(String? value) {
    final String phone = value?.trim() ?? '';
    if (phone.isEmpty) return 'Phone number is required.';
    if (!RegExp(r'^\d{7,15}$').hasMatch(phone)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? _validateDob(String? value) {
    final String dob = value?.trim() ?? '';
    if (dob.isEmpty) return 'Date of birth is required.';
    if (_parseDob(dob) == null) return 'Use DD-MM-YYYY format.';
    return null;
  }

  static String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String _formatDob(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day-$month-$year';
  }

  static DateTime? _parseDob(String raw) {
    final RegExpMatch? match = RegExp(
      r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$',
    ).firstMatch(raw.trim());
    if (match == null) return null;

    final int? day = int.tryParse(match.group(1)!);
    final int? month = int.tryParse(match.group(2)!);
    final int? year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;

    final DateTime parsed = DateTime(year, month, day);
    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return null;
    }
    if (parsed.isAfter(DateTime.now())) return null;
    return parsed;
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

class _MissingInfoForm extends StatelessWidget {
  const _MissingInfoForm({
    required this.formKey,
    required this.student,
    required this.phoneController,
    required this.dobController,
    required this.emailController,
    required this.isSaving,
    required this.onPickDob,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final StudentDetailData student;
  final TextEditingController phoneController;
  final TextEditingController dobController;
  final TextEditingController emailController;
  final bool isSaving;
  final VoidCallback onPickDob;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSoft),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AppColors.iconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Complete Missing Details',
                    style: GoogleFonts.outfit(
                      color: _text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_ProfilePageState._isMissing(student.contact)) ...<Widget>[
              _ProfileInput(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
                validator: _ProfilePageState._validatePhone,
              ),
              const SizedBox(height: 10),
            ],
            if (_ProfilePageState._isMissing(student.dob)) ...<Widget>[
              _ProfileInput(
                controller: dobController,
                label: 'Date of Birth',
                icon: Icons.event_outlined,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                onTap: onPickDob,
                validator: _ProfilePageState._validateDob,
              ),
              const SizedBox(height: 10),
            ],
            if (_ProfilePageState._isMissing(student.email)) ...<Widget>[
              _ProfileInput(
                controller: emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: _ProfilePageState._validateEmail,
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(isSaving ? 'Saving' : 'Save Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: _primarySoft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar({required this.initials, required this.imageUrls});

  final String initials;
  final List<String> imageUrls;

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  int _loadRun = 0;

  static bool _isSuccessfulStatus(int? status) {
    return status != null && status >= 200 && status < 300;
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(_ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.join('|') != widget.imageUrls.join('|')) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final int run = ++_loadRun;
    if (widget.imageUrls.isEmpty) {
      setState(() {
        _imageBytes = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _imageBytes = null;
      _isLoading = true;
    });

    for (final String imageUrl in widget.imageUrls) {
      try {
        final Response<List<int>> response = await DioClient().dio
            .get<List<int>>(
              imageUrl,
              options: Options(
                responseType: ResponseType.bytes,
                contentType: null,
                followRedirects: true,
                validateStatus: _isSuccessfulStatus,
                headers: const <String, dynamic>{
                  'Accept': 'image/*,*/*',
                  'Accept-Encoding': 'identity',
                },
              ),
            );

        final List<int>? data = response.data;
        if (data == null || data.isEmpty) continue;
        if (!mounted || run != _loadRun) return;
        setState(() {
          _imageBytes = Uint8List.fromList(data);
          _isLoading = false;
        });
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('PROFILE PHOTO failed: $imageUrl');
          debugPrint('PROFILE PHOTO error: $e');
        }
      }
    }

    if (!mounted || run != _loadRun) return;
    setState(() {
      _imageBytes = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: AppColors.onPrimary.withValues(alpha: 0.16),
        border: Border.all(
          color: AppColors.onPrimary.withValues(alpha: 0.4),
          width: 1.4,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: _imageBytes != null
          ? Image.memory(_imageBytes!, width: 72, height: 72, fit: BoxFit.cover)
          : _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.onPrimary,
              ),
            )
          : _AvatarInitials(initials: widget.initials),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: GoogleFonts.outfit(
        color: AppColors.onPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  const _ProfileInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.keyboardType,
    required this.validator,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: GoogleFonts.dmSans(
        color: _text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.iconColor, size: 18),
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
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
        // boxShadow: const <BoxShadow>[
        //   BoxShadow(
        //     color: AppColors.cardShadow,
        //     blurRadius: 12,
        //     offset: Offset(0, 2),
        //   ),
        // ],
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
        color: AppColors.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 16, color: AppColors.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Text(
              item.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              item.value,
              textAlign: TextAlign.left,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: isNotSet ? _muted : _text,
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
