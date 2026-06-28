import 'package:dio/dio.dart';
import 'package:my_first_app/core/config/api_config.dart';
import 'package:my_first_app/core/network/api_exception.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/core/network/token_storage.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.instance.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete<dynamic>(path);
      return response.data;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  ApiException _mapDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data != null) {
      return ApiException.fromResponse(status, data);
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const ApiException('Connection timed out. Please try again.');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const ApiException(
        'Unable to reach WowKidz servers. Check your internet connection.',
      );
    }
    return ApiException(
      error.message ?? 'Network error',
      statusCode: status,
    );
  }

  Map<String, dynamic> asMap(dynamic json) =>
      asJsonMap(unwrapData(json));

  List<dynamic> asList(dynamic json) => asJsonList(unwrapData(json));
}
