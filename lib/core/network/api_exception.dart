class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.details});

  final String message;
  final int? statusCode;
  final dynamic details;

  @override
  String toString() => message;

  static ApiException fromResponse(int? statusCode, dynamic body) {
    if (body is Map) {
      final message = body['message'] ??
          body['error'] ??
          body['errors']?.toString() ??
          'Request failed';
      return ApiException('$message', statusCode: statusCode, details: body);
    }
    return ApiException(
      'Request failed (${statusCode ?? 'unknown'})',
      statusCode: statusCode,
      details: body,
    );
  }
}
