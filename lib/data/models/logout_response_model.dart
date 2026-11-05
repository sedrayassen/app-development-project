class LogoutResponseModel {
  final String message;
  final int code;

  const LogoutResponseModel({required this.message, required this.code});

  factory LogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return LogoutResponseModel(
      message: json['message']?.toString() ?? 'Logout successful.',
      code: (json['code'] as num?)?.toInt() ?? 200,
    );
  }
}