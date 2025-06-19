import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallUtils {
  /// Attempts to launch the phone dialer with the specified [phoneNumber].
  ///
  /// Throws an exception if the phone number cannot be dialed.
  static Future<void> makePhoneCall(String phoneNumber) async {
    debugPrint('Attempting to make a call to: $phoneNumber');
    // Ensure the phone number is appropriately formatted.
    final String cleanedPhoneNumber = phoneNumber.trim();
    final Uri callUri = Uri(scheme: 'tel', path: cleanedPhoneNumber);

    try {
      if (await canLaunchUrl(callUri)) {
        // It is recommended to explicitly use the external application mode.
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Dialer cannot handle the phone number: $phoneNumber');
      }
    } catch (error) {
      // Log the error.
      debugPrint('Error encountered while trying to make a call: $error');
      rethrow;
    }
  }
}
