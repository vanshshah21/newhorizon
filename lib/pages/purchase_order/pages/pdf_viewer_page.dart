import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../model/po_data.dart';
import '../services/po_service.dart';

class POPdfLoaderPage extends StatefulWidget {
  final POData po;
  final bool isRegular;

  const POPdfLoaderPage({required this.po, required this.isRegular, super.key});

  @override
  State<POPdfLoaderPage> createState() => _POPdfLoaderPageState();
}

class _POPdfLoaderPageState extends State<POPdfLoaderPage> {
  final _service = POService();

  String? _pdfUrl;
  String? _error;

  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchPdfUrl();
  }

  /* ---------- 1. Fetch the PDF URL ---------- */

  Future<void> _fetchPdfUrl() async {
    setState(() {
      _error = null;
      _pdfUrl = null;
    });
    try {
      final url = await _service.fetchPOPdfUrl(widget.po, widget.isRegular);
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() => _error = 'PDF not found');
      } else {
        setState(() => _pdfUrl = url);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    }
  }

  /* ---------- 2. Enhanced Permission helper ---------- */

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true; // iOS/macOS doesn't need this

    try {
      // For Android 11+ (API 30+), we need different permissions
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      Permission permission;
      if (sdkInt >= 30) {
        // Android 11+ uses MANAGE_EXTERNAL_STORAGE for full access
        permission = Permission.manageExternalStorage;
      } else {
        // Android 10 and below use WRITE_EXTERNAL_STORAGE
        permission = Permission.storage;
      }

      var status = await permission.status;

      // Already granted ✅
      if (status.isGranted) return true;

      // 2a. First‑time ask OR the user has tapped "Deny" earlier
      if (status.isDenied) {
        // Show explanation dialog first
        final shouldRequest = await _showPermissionDialog(
          title: 'Storage Permission Required',
          message:
              'This app needs storage permission to download PDF files to your device. '
              'Please allow storage access in the next dialog.',
        );

        if (!shouldRequest) return false;

        status = await permission.request();
        return status.isGranted;
      }

      // 2b. "Don't ask again" selected ➜ permanently denied
      if (status.isPermanentlyDenied) {
        final openSettings = await _showPermissionDialog(
          title: 'Permission Permanently Denied',
          message:
              'Storage permission has been permanently denied. '
              'Please go to Settings > Apps > [Your App] > Permissions and enable Storage access.',
          showSettingsButton: true,
        );

        if (openSettings) {
          await openAppSettings();
          // Check permission again after user returns from settings
          return await permission.isGranted;
        }
        return false;
      }

      // Any other status (e.g. restricted) ➜ treat as not granted
      return false;
    } catch (e) {
      // If there's any error with permission handling, show a user-friendly message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> _showPermissionDialog({
    required String title,
    required String message,
    bool showSettingsButton = false,
  }) async {
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
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(showSettingsButton ? 'Open Settings' : 'Allow'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /* ---------- 3. Path helpers ---------- */

  Future<String> _cacheDir() async => (await getTemporaryDirectory()).path;

  Future<String> _downloadsDir() async {
    if (Platform.isAndroid) {
      return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  /* ---------- 4. Low‑level downloader ---------- */

  Future<String?> _downloadPdf({required bool toCache}) async {
    if (_pdfUrl == null) return null;

    if (!toCache && !(await _ensureStoragePermission())) return null;

    final dir = toCache ? await _cacheDir() : await _downloadsDir();
    final name =
        'PO_${widget.po.nmbr}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '$dir/$name';

    final file = File(path);
    if (await file.exists()) return path; // reuse

    try {
      await Dio().download(_pdfUrl!, path);
      return path;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
      return null;
    }
  }

  /* ---------- 5. Persistent "Download" ---------- */

  Future<void> _handleDownload() async {
    if (_isDownloading || _pdfUrl == null) return;
    setState(() => _isDownloading = true);

    try {
      final path = await _downloadPdf(toCache: false);
      if (path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download cancelled or permission denied'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF saved to ${Platform.isAndroid ? "Downloads" : "Documents"} folder',
          ),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () => OpenFile.open(path),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /* ---------- 6. Ephemeral "Share" ---------- */

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final path = await _downloadPdf(toCache: true);
      if (path == null) throw Exception('Unable to prepare PDF');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, name: 'PO_${widget.po.nmbr}.pdf')],
          text: 'Purchase Order ${widget.po.nmbr} PDF',
          subject: 'Purchase Order ${widget.po.nmbr} PDF',
        ),
      );
      // Optionally delete cached copy afterwards
      // await File(path).delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /* ---------- 7. UI ---------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PO PDF'),
        actions: [
          if (_pdfUrl != null) ...[
            IconButton(
              tooltip: 'Download PDF',
              onPressed: _isDownloading ? null : _handleDownload,
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.download),
            ),
            IconButton(
              tooltip: 'Share PDF',
              onPressed: _isSharing ? null : _handleShare,
              icon:
                  _isSharing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.share),
            ),
          ],
        ],
      ),
      body:
          _error != null
              ? _ErrorPane(message: _error!, onRetry: _fetchPdfUrl)
              : _pdfUrl == null
              ? const Center(child: CircularProgressIndicator())
              : PDF().fromUrl(
                // _pdfUrl!,
                '${_pdfUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                placeholder: (p) => Center(child: Text('$p %')),
                errorWidget: (e) => Center(child: Text(e.toString())),
              ),
    );
  }
}

/* ---------- 8. Error widget ---------- */

class _ErrorPane extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPane({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
