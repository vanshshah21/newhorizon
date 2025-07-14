import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapsUtils {
  static Future<void> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final String googleMapsUrl;

    if (Platform.isIOS) {
      // For iOS, try to open Google Maps app first, then fallback to Apple Maps
      googleMapsUrl =
          'comgooglemaps://?q=$latitude,$longitude&label=${label ?? 'Location'}';
      final fallbackUrl = 'http://maps.apple.com/?q=$latitude,$longitude';

      try {
        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl));
        } else {
          await launchUrl(Uri.parse(fallbackUrl));
        }
      } catch (e) {
        debugPrint('Error opening maps: $e');
      }
    } else {
      // For Android, try Google Maps app first, then fallback to web
      googleMapsUrl =
          'geo:$latitude,$longitude?q=$latitude,$longitude(${label ?? 'Location'})';
      final fallbackUrl = 'https://maps.google.com/maps?q=$latitude,$longitude';

      try {
        if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
          await launchUrl(Uri.parse(googleMapsUrl));
        } else {
          await launchUrl(
            Uri.parse(fallbackUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (e) {
        debugPrint('Error opening maps: $e');
      }
    }
  }

  static Future<void> showLocationDialog({
    required BuildContext context,
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Open Location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latitude: $latitude'),
                Text('Longitude: $longitude'),
                if (label != null) Text('Label: $label'),
                const SizedBox(height: 16),
                const Text('Open this location in Google Maps?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openGoogleMaps(
                    latitude: latitude,
                    longitude: longitude,
                    label: label,
                  );
                },
                child: const Text('Open Maps'),
              ),
            ],
          ),
    );
  }
}
