// Helper for background isolate
import 'dart:convert';

Map<String, dynamic> parseAndValidateToken(String? token) {
  if (token == null) {
    return {'isValid': false, 'error': 'Token is null'};
  }
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return {'isValid': false, 'error': 'Invalid JWT structure'};
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = jsonDecode(decoded);

    if (!payloadMap.containsKey('exp')) {
      return {'isValid': false, 'error': 'No expiration in token'};
    }

    final expirationTime = DateTime.fromMillisecondsSinceEpoch(
      payloadMap['exp'] * 1000,
    );
    final currentTime = DateTime.now();

    if (currentTime.isAfter(expirationTime)) {
      return {'isValid': false, 'error': 'Token expired'};
    }

    return {'isValid': true};
  } catch (e) {
    return {'isValid': false, 'error': 'Exception: $e'};
  }
}
