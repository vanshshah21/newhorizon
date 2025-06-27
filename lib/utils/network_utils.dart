import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NetworkUtils {
  static Dio createDioInstance() {
    final dio = Dio();
    
    // Configure timeouts
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    // Configure headers
    dio.options.headers['Content-Type'] = 'application/json';
    dio.options.headers['Accept'] = 'application/json';
    
    // Add interceptor for logging and error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          debugPrint('Network Error: ${error.message}');
          debugPrint('Request: ${error.requestOptions.uri}');
          handler.next(error);
        },
        onRequest: (options, handler) {
          debugPrint('Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('Response: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
      ),
    );
    
    return dio;
  }
  
  static String getErrorMessage(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;
      
      String message = 'Server error ($statusCode)';
      
      if (data is Map && data.containsKey('message')) {
        message += ': ${data['message']}';
      }
      
      return message;
    }
    
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'Network error: ${e.message ?? 'Unknown error'}';
    }
  }
  
  static void showNetworkError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}