import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenUtils {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> isTokenValid(BuildContext context) async {
    try {
      final tokenDetails = await _storage.read(key: 'session_token');

      if (tokenDetails == null || tokenDetails.isEmpty) {
        return false;
      }

      final token = jsonDecode(tokenDetails)['token']['value'];

      // Parse the JWT token to check expiration
      final parts = token.split('.');
      if (parts.length != 3) {
        return false; // Not a valid JWT token
      }

      // Decode the payload
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(decoded);

      if (payloadMap.containsKey('exp')) {
        final expirationTime = DateTime.fromMillisecondsSinceEpoch(
          payloadMap['exp'] * 1000,
        );
        final currentTime = DateTime.now();

        if (currentTime.isAfter(expirationTime)) {
          await showTokenExpiredDialog(context);
          return false;
        }

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking token validity: $e');
      return false;
    }
  }

  /// Shows an alert dialog for token expiration and handles logout
  static Future<void> showTokenExpiredDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Session Expired'),
          content: Text('Your session has expired. Please login again.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                logoutUser(context);
              },
            ),
          ],
        );
      },
    );
  }

  /// Logs out the user by clearing storage and navigating to login
  static Future<void> logoutUser(BuildContext context) async {
    // Clear specific keys
    await _storage.delete(key: 'session_token');

    // Navigate to login screen and clear navigation history
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
