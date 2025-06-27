import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'network_utils.dart';

class ErrorHandler {
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // In debug mode, use the default error handler to show the red screen
        FlutterError.presentError(details);
      } else {
        // In release mode, log the error
        debugPrint('Flutter Error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      }
    };

    // Catch errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('Platform Error: $error');
        debugPrint('Stack trace: $stack');
      }
      return true;
    };
  }

  static Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? errorMessage,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } on DioException catch (e) {
      final message = errorMessage ?? NetworkUtils.getErrorMessage(e);
      if (context != null) {
        NetworkUtils.showNetworkError(context, message);
      } else {
        debugPrint('Network Error: $message');
      }
      return fallbackValue;
    } catch (e, stackTrace) {
      final message = errorMessage ?? 'An unexpected error occurred: $e';
      debugPrint('Error: $message');
      debugPrint('Stack trace: $stackTrace');
      
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return fallbackValue;
    }
  }

  static Widget buildErrorWidget(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildNoDataWidget({String message = 'No data available'}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}