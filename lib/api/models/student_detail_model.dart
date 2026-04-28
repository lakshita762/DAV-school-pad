class StudentDetailResponse {
  final bool success;
  final String message;
  final StudentDetailData data;

  StudentDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StudentDetailResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dataMap =
        _asMap(json['data']) ?? _asMap(json['student']) ?? json;

    return StudentDetailResponse(
      success: _asBool(json['success'], fallback: true),
      message: _asString(json['message']),
      data: StudentDetailData.fromJson(dataMap),
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}

class StudentDetailData {
  final String studentName;
  final String studentId;
  final String admissionDate;
  final String className;
  final String section;
  final String category;
  final String rollNo;
  final String fatherName;
  final String motherName;
  final String schoolName;
  final String shortName;
  final int schoolId;
  final String schoolAddress1;
  final String schoolAddress2;
  final String schoolPhone;
  final String schoolEmail;
  final String schoolWebsite;
  final String board;
  final String academicYear;
  final String teacherName;
  final String dob;
  final String gender;
  final String bloodGroup;
  final String contact;
  final double balanceDue;
  final double paidAmount;
  final double totalAmount;
  final double attendancePercent;
  final String dueDate;
  final String admNo;
  final String active;
  final String email;
  final String conveyance;
  final String hostel;
  final int courseId;
  final int secId;
  final int branchId;
  final String photographPath;
  final int photographAttachmentId;
  final String photographFileExt;

  StudentDetailData({
    required this.studentName,
    required this.studentId,
    required this.admissionDate,
    required this.className,
    required this.admNo,
    required this.active,
    required this.section,
    required this.category,
    required this.rollNo,
    required this.fatherName,
    required this.motherName,
    required this.schoolName,
    required this.shortName,
    required this.schoolId,
    required this.schoolAddress1,
    required this.schoolAddress2,
    required this.schoolPhone,
    required this.schoolEmail,
    required this.schoolWebsite,
    required this.board,
    required this.academicYear,
    required this.teacherName,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    required this.contact,
    required this.balanceDue,
    required this.paidAmount,
    required this.totalAmount,
    required this.attendancePercent,
    required this.dueDate,
    required this.email,
    required this.conveyance,
    required this.hostel,
    required this.courseId,
    required this.secId,
    required this.branchId,
    required this.photographPath,
    required this.photographAttachmentId,
    required this.photographFileExt,
  });

  double get paidProgress {
    if (totalAmount <= 0) {
      return 0;
    }
    final double value = paidAmount / totalAmount;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  StudentDetailData copyWith({String? dob, String? contact, String? email}) {
    return StudentDetailData(
      studentName: studentName,
      studentId: studentId,
      admissionDate: admissionDate,
      className: className,
      admNo: admNo,
      active: active,
      section: section,
      category: category,
      rollNo: rollNo,
      fatherName: fatherName,
      motherName: motherName,
      schoolName: schoolName,
      shortName: shortName,
      schoolId: schoolId,
      schoolAddress1: schoolAddress1,
      schoolAddress2: schoolAddress2,
      schoolPhone: schoolPhone,
      schoolEmail: schoolEmail,
      schoolWebsite: schoolWebsite,
      board: board,
      academicYear: academicYear,
      teacherName: teacherName,
      dob: dob ?? this.dob,
      gender: gender,
      bloodGroup: bloodGroup,
      contact: contact ?? this.contact,
      balanceDue: balanceDue,
      paidAmount: paidAmount,
      totalAmount: totalAmount,
      attendancePercent: attendancePercent,
      dueDate: dueDate,
      email: email ?? this.email,
      conveyance: conveyance,
      hostel: hostel,
      courseId: courseId,
      secId: secId,
      branchId: branchId,
      photographPath: photographPath,
      photographAttachmentId: photographAttachmentId,
      photographFileExt: photographFileExt,
    );
  }

  factory StudentDetailData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> courseMap =
        _asMap(json['course']) ?? <String, dynamic>{};
    final Map<String, dynamic> sectionMap =
        _asMap(json['section']) ?? <String, dynamic>{};
    final Map<String, dynamic> schoolMap =
        _asMap(json['school_details']) ??
        _asMap(json['school']) ??
        <String, dynamic>{};
    final Map<String, dynamic> photographMap =
        _asMap(json['photograph']) ?? <String, dynamic>{};
    final Map<String, dynamic> attachmentMap =
        _asMap(photographMap['attachment']) ?? <String, dynamic>{};

    return StudentDetailData(
      studentId: _firstString(json, const ['student_id', 'admission_no', 'id']),
      studentName: _firstString(json, const [
        'student_name',
        'name',
        'full_name',
      ]),
      admNo: _firstString(json, const ['adm_no']),
      active: _firstString(json, const ['active']),
      dob: _firstString(json, const ['dob', 'date_of_birth']),
      fatherName: _firstString(json, const [
        'father_name',
        'father',
        'fathers_name',
      ]),
      motherName: _firstString(json, const [
        'mother_name',
        'mother',
        'mothers_name',
      ]),
      email: _firstString(json, const ['email']),
      contact: _firstString(json, const ['contact', 'phone', 'mobile']),
      conveyance: _firstString(json, const ['conveyance']),
      hostel: _firstString(json, const ['hostel']),
      admissionDate: _firstString(json, const [
        'admission_date',
        'date_of_admission',
        'admissionDate',
      ]),
      className: _firstString(json, const ['class_name', 'class']).isNotEmpty
          ? _firstString(json, const ['class_name', 'class'])
          : _firstString(courseMap, const ['course_name', 'name', 'title']),
      section: _firstString(json, const ['section']).isNotEmpty
          ? _firstString(json, const ['section'])
          : _firstString(sectionMap, const ['name', 'section_name', 'title']),
      category: _firstString(json, const ['category']),
      rollNo: _firstString(json, const ['roll_no', 'roll_number']),
      schoolName: _firstString(schoolMap, const [
        'name',
        'school_name',
        'school',
      ]),
      shortName:
          _firstString(schoolMap, const [
            'short_name',
            'Short_name',
            'shortName',
          ]).isNotEmpty
          ? _firstString(schoolMap, const [
              'short_name',
              'Short_name',
              'shortName',
            ])
          : _firstString(json, const ['short_name', 'Short_name', 'shortName']),
      schoolId: _firstInt(schoolMap, const ['id']),
      schoolAddress1: _firstString(schoolMap, const [
        'add1',
        'address1',
        'address_line_1',
      ]),
      schoolAddress2: _firstString(schoolMap, const [
        'add2',
        'address2',
        'address_line_2',
      ]),
      schoolPhone: _firstString(schoolMap, const ['phone', 'mobile']),
      schoolEmail: _firstString(schoolMap, const ['email']),
      schoolWebsite: _firstString(schoolMap, const ['website']),
      board: _firstString(json, const ['board']),
      academicYear: _firstString(json, const ['academic_year', 'year']),
      teacherName: _firstString(json, const ['class_teacher', 'teacher_name']),
      gender: _firstString(json, const ['gender']),
      bloodGroup: _firstString(json, const ['blood_group']),
      balanceDue: _firstDouble(json, const [
        'balance_due',
        'due_amount',
        'balance_amount',
      ]),
      paidAmount: _firstDouble(json, const ['paid_amount', 'paid']),
      totalAmount: _firstDouble(json, const ['total_amount', 'total_fee']),
      attendancePercent: _firstDouble(json, const [
        'attendance_percent',
        'attendance',
      ]),
      dueDate: _firstString(json, const ['due_date']),
      courseId: _firstInt(json, const ['course_id']),
      secId: _firstInt(json, const ['sec_id']),
      branchId: _firstInt(json, const ['branch_id']),
      photographPath:
          _firstString(json, const [
            'photograph_url',
            'photo_url',
            'image_url',
          ]).isNotEmpty
          ? _firstString(json, const [
              'photograph_url',
              'photo_url',
              'image_url',
            ])
          : _firstString(photographMap, const [
              'url',
              'full_url',
              'path',
              'file_path',
              'file_url',
            ]).isNotEmpty
          ? _firstString(photographMap, const [
              'url',
              'full_url',
              'path',
              'file_path',
              'file_url',
            ])
          : _firstString(attachmentMap, const [
              'url',
              'full_url',
              'path',
              'file_path',
              'file_url',
              'file_name',
            ]),
      photographAttachmentId:
          _firstInt(photographMap, const ['attachment_id']) != 0
          ? _firstInt(photographMap, const ['attachment_id'])
          : _firstInt(attachmentMap, const ['id', 'attachment_id']),
      photographFileExt: _firstString(attachmentMap, const ['file_ext']),
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      if (!json.containsKey(key)) continue;
      final dynamic value = json[key];
      if (value == null) continue;
      final String text = _stringFromValue(value).trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static int _firstInt(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      if (!json.containsKey(key)) continue;
      final int value = _asInt(json[key]);
      if (value != 0) return value;
      if (_isZeroLike(json[key])) return 0;
    }
    return 0;
  }

  static double _firstDouble(Map<String, dynamic> json, List<String> keys) {
    for (final String key in keys) {
      if (!json.containsKey(key)) continue;
      final double value = _asDouble(json[key]);
      if (value != 0) return value;
      if (_isZeroLike(json[key])) return 0;
    }
    return 0;
  }

  static bool _isZeroLike(dynamic value) {
    if (value == null) return false;
    if (value is num) return value == 0;
    return value.toString().trim() == '0';
  }

  static String _stringFromValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      final List<String> preferredKeys = <String>[
        'name',
        'title',
        'label',
        'course_name',
        'class_name',
        'value',
      ];
      for (final String key in preferredKeys) {
        if (!map.containsKey(key)) continue;
        final String nested = _stringFromValue(map[key]).trim();
        if (nested.isNotEmpty) return nested;
      }
      return '';
    }
    return value.toString();
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

int _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String _asString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

bool _asBool(dynamic value, {required bool fallback}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final String v = value.trim().toLowerCase();
    if (v == 'true' || v == '1' || v == 'yes') return true;
    if (v == 'false' || v == '0' || v == 'no') return false;
  }
  return fallback;
}
