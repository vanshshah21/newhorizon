import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class LocationUtils {
  static LocationUtils? _instance;
  static LocationUtils get instance => _instance ??= LocationUtils._internal();
  LocationUtils._internal();

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if GPS/Location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Get current location with high accuracy
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        return null;
      }

      // Check/request permission
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return null;
        }
      }

      // Get current position with highest accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Check location permission and service status
  Future<LocationStatus> checkLocationStatus() async {
    final hasPermission = await hasLocationPermission();
    final isServiceEnabled = await isLocationServiceEnabled();

    if (!hasPermission && !isServiceEnabled) {
      return LocationStatus.permissionDeniedAndServiceDisabled;
    } else if (!hasPermission) {
      return LocationStatus.permissionDenied;
    } else if (!isServiceEnabled) {
      return LocationStatus.serviceDisabled;
    } else {
      return LocationStatus.granted;
    }
  }

  /// Show location dialog based on status
  Future<bool> showLocationDialog(
    BuildContext context,
    LocationStatus status,
  ) async {
    String title;
    String message;
    String actionText;
    VoidCallback? action;

    switch (status) {
      case LocationStatus.permissionDenied:
        title = 'Location Permission Required';
        message = 'Please grant location permission to submit the lead.';
        actionText = 'Grant Permission';
        action = () async {
          await requestLocationPermission();
        };
        break;
      case LocationStatus.serviceDisabled:
        title = 'Enable Location Services';
        message = 'Please enable GPS/Location services to submit the lead.';
        actionText = 'Open Settings';
        action = () async {
          await openLocationSettings();
        };
        break;
      case LocationStatus.permissionDeniedAndServiceDisabled:
        title = 'Location Access Required';
        message =
            'Please enable location services and grant permission to submit the lead.';
        actionText = 'Open Settings';
        action = () async {
          await openLocationSettings();
        };
        break;
      case LocationStatus.granted:
        return true;
    }

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      action?.call();
                      Navigator.of(context).pop(true);
                    },
                    child: Text(actionText),
                  ),
                ],
              ),
        ) ??
        false;
  }
}

enum LocationStatus {
  granted,
  permissionDenied,
  serviceDisabled,
  permissionDeniedAndServiceDisabled,
}
