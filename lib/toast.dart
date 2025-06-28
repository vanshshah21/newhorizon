import 'package:flutter/material.dart';

/// Global navigator key to access context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Show a toast message using overlay
void showToast(String message, {Duration duration = const Duration(seconds: 2)}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final overlay = Overlay.of(context);
  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50.0,
      left: 20.0,
      right: 20.0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((0.8 * 255).toInt()),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(duration).then((_) {
    overlayEntry?.remove();
    overlayEntry = null;
  });
}

/// Show a snackbar message (alternative to toast)
void showSnackBar(String message, {bool isError = false}) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
      duration: const Duration(seconds: 3),
    ),
  );
}
