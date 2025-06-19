import 'dart:convert';
import 'package:flutter/foundation.dart'; // for compute
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'helper.dart'; // Adjust the import as necessary

class TokenUtils {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Returns true if token is valid, otherwise handles logout and returns false.
  static Future<bool> isTokenValid(BuildContext context) async {
    try {
      final tokenDetails = await _storage.read(key: 'session_token');
      if (tokenDetails == null || tokenDetails.isEmpty) {
        debugPrint('TokenUtils: No session_token found.');
        return false;
      }

      String? token;
      try {
        token = jsonDecode(tokenDetails)['token']['value'];
      } catch (e) {
        debugPrint('TokenUtils: Error decoding token JSON: $e');
        return false;
      }

      // Move JWT parsing and validation to a background isolate
      final result = await compute(parseAndValidateToken, token);

      if (result['isValid'] == true) {
        return true;
      } else {
        final error = result['error'] ?? 'Unknown error';
        debugPrint('TokenUtils: Token invalid: $error');
        if (error == 'Token expired') {
          await showTokenExpiredDialog(context);
        }
        return false;
      }
    } catch (e, stack) {
      debugPrint('TokenUtils: Unexpected error: $e\n$stack');
      return false;
    }
  }

  /// Shows an alert dialog for token expiration and handles logout
  static Future<void> showTokenExpiredDialog(BuildContext context) async {
    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Session Expired'),
            content: const Text(
              'Your session has expired. Please login again.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  logoutUser(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('TokenUtils: Error showing token expired dialog: $e');
    }
  }

  /// Logs out the user by clearing storage and navigating to login
  static Future<void> logoutUser(BuildContext context) async {
    try {
      await _storage.delete(key: 'session_token');
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('TokenUtils: Error during logout: $e');
    }
  }
}
