// import 'dart:ffi';

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
  final String adm_no;
  final String active;
  final String email;
  final String conveyance, hostel;

  StudentDetailData({
    required this.studentName,
    required this.studentId,
    required this.admissionDate,
    required this.className,
    required this.adm_no,
    required this.active,
    required this.section,
    required this.category,
    required this.rollNo,
    required this.fatherName,
    required this.motherName,
    required this.schoolName,
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
    required this.hostel
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

  factory StudentDetailData.fromJson(Map<String, dynamic> json) {
    return StudentDetailData(
      studentId: _firstString(json, const ['student_id', 'admission_no', 'id']),
      studentName: _firstString(json, const [
        'student_name',
        'name',
        'full_name',
      ]),
      adm_no: _firstString(json, const ['adm_no']),
      active: _firstString(json, const ['active']),
      dob: _firstString(json, const ['dob', 'date_of_birth']),
      fatherName: _firstString(
        json,
        const ['father_name', 'father', 'fathers_name'],
      ),
      motherName: _firstString(
        json,
        const ['mother_name', 'mother', 'mothers_name'],
      ),
      email: _firstString(json, const ['email']),
      contact: _firstString(json, const ['contact', 'phone', 'mobile']),
      conveyance: _firstString(json, const ['conveyance']),
      hostel: _firstString(json, const ['hostel']),
      admissionDate: _firstString(
        json,
        const ['admission_date', 'date_of_admission', 'admissionDate'],
      ),
      className: _firstString(
        json,
        const ['course', 'class_name', 'class'],
      ),
      section: _firstString(json, const ['section']),
      category: _firstString(json, const ['category']),
      rollNo: _firstString(json, const ['roll_no', 'roll_number']),

      schoolName: _firstString(json, const ['school_name', 'school']),
      board: _firstString(json, const ['board']),
      academicYear: _firstString(json, const ['academic_year', 'year']),
      teacherName: _firstString(json, const ['class_teacher', 'teacher_name']),

      gender: _firstString(json, const ['gender']),
      bloodGroup: _firstString(json, const ['blood_group']),

      balanceDue: _firstDouble(json, const ['balance_due', 'due_amount', 'balance_amount']),
      paidAmount: _firstDouble(json, const ['paid_amount', 'paid']),
      totalAmount: _firstDouble(json, const ['total_amount', 'total_fee']),
      attendancePercent: _firstDouble(
        json,
        const ['attendance_percent', 'attendance'],
      ),
      dueDate: _firstString(json, const ['due_date']),
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
    if (value is int) return value == 0;
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
