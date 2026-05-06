class LoginRequest {
  final String admNo;
  final String dob;
  final String buildNo;

  LoginRequest({required this.admNo, required this.dob, required this.buildNo});

  Map<String, dynamic> toJson() => {
    'adm_no': admNo,
    'dob': dob,
    'build_no': buildNo,
  };
}

class LoginResponse {
  final String token;
  final String message;
  final bool success;
  final String error;

  LoginResponse({
    required this.token,
    required this.message,
    required this.success,
    required this.error,
  });


  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      error: json['error'] ?? '',
    );
  }
}
