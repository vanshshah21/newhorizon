class LoginResponse {
  final bool success;
  final dynamic data;
  final String? message;

  LoginResponse({required this.success, this.data, this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    success: json['success'] ?? false,
    data: json['data'],
    message: json['message'],
  );
}
