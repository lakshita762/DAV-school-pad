class LoginRequest {
  final String admNo;
  final String dob;

  LoginRequest({required this.admNo, required this.dob});

  Map<String, dynamic> toJson() => {
    'adm_no': admNo,
    'dob': dob,
  };
}

class LoginResponse {
  final String token;
  final String message;
  final bool success;

  LoginResponse({
    required this.token,
    required this.message,
    required this.success,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }
}
