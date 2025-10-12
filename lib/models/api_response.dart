class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    try {
      return ApiResponse<T>(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : json['data'],
      );
    } catch (e) {
      print('DEBUG ApiResponse.fromJson: Error parsing response: $e');
      print('DEBUG ApiResponse.fromJson: Raw JSON: $json');
      return ApiResponse<T>(
        success: false,
        message: 'Error parsing response: $e',
        data: null,
      );
    }
  }
}
