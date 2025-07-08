// import 'package:flutter/material.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/pages/service_po/service/service_po_service.dart';

// class ServicePOPdfLoaderPage extends StatefulWidget {
//   final ServicePOData po;

//   const ServicePOPdfLoaderPage({required this.po, super.key});

//   @override
//   State<ServicePOPdfLoaderPage> createState() => _ServicePOPdfLoaderPageState();
// }

// class _ServicePOPdfLoaderPageState extends State<ServicePOPdfLoaderPage> {
//   String? pdfUrl;
//   String? error;
//   final service = ServicePOService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchPdf();
//   }

//   Future<void> _fetchPdf() async {
//     setState(() {
//       error = null;
//       pdfUrl = null;
//     });
//     try {
//       final url = await service.fetchServicePOPdfUrl(widget.po);
//       if (!mounted) return;
//       if (url.isEmpty) {
//         setState(() => error = 'PDF not found');
//       } else {
//         setState(() => pdfUrl = url);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => error = 'Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Service PO PDF'),
//         actions: [
//           if (pdfUrl != null)
//             IconButton(
//               icon: const Icon(Icons.download),
//               onPressed: () {
//                 // TODO: Implement download logic
//               },
//             ),
//         ],
//       ),
//       body:
//           error != null
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error, color: Colors.red, size: 48),
//                     const SizedBox(height: 16),
//                     Text(error!, style: const TextStyle(fontSize: 16)),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _fetchPdf,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//               : pdfUrl == null
//               ? const Center(child: CircularProgressIndicator())
//               : PDF().fromUrl(
//                 pdfUrl!,
//                 placeholder: (progress) => Center(child: Text('$progress %')),
//                 errorWidget: (error) => Center(child: Text(error.toString())),
//               ),
//     );
//   }
// }

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:nhapp/pages/service_po/models/service_po_data.dart';
import 'package:nhapp/pages/service_po/service/service_po_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ServicePOPdfLoaderPage extends StatefulWidget {
  final ServicePOData po;

  const ServicePOPdfLoaderPage({required this.po, super.key});

  @override
  State<ServicePOPdfLoaderPage> createState() => _ServicePOPdfLoaderPageState();
}

class _ServicePOPdfLoaderPageState extends State<ServicePOPdfLoaderPage> {
  final service = ServicePOService();

  String? pdfUrl;
  String? error;

  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  /* ---------- 1. Fetch the PDF URL ---------- */

  Future<void> _fetchPdf() async {
    setState(() {
      error = null;
      pdfUrl = null;
    });
    try {
      final url = await service.fetchServicePOPdfUrl(widget.po);
      if (!mounted) return;
      if (url.isEmpty) {
        setState(() => error = 'PDF not found');
      } else {
        setState(() => pdfUrl = url);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Error: $e');
    }
  }

  /* ---------- 2. Enhanced Permission helper ---------- */

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      Permission permission;
      if (sdkInt >= 30) {
        permission = Permission.manageExternalStorage;
      } else {
        permission = Permission.storage;
      }

      var status = await permission.status;

      if (status.isGranted) return true;

      if (status.isDenied) {
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
          return await permission.isGranted;
        }
        return false;
      }

      return false;
    } catch (e) {
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
    if (pdfUrl == null) return null;

    if (!toCache && !(await _ensureStoragePermission())) return null;

    final dir = toCache ? await _cacheDir() : await _downloadsDir();
    final name =
        'ServicePO_${widget.po.number}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '$dir/$name';

    final file = File(path);
    if (await file.exists()) return path;

    try {
      await Dio().download(pdfUrl!, path);
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
    if (_isDownloading || pdfUrl == null) return;
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
          files: [XFile(path, name: 'ServicePO_${widget.po.number}.pdf')],
          text: 'Service PO ${widget.po.number} PDF',
          subject: 'Service PO ${widget.po.number} PDF',
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
        title: const Text('Service PO PDF'),
        actions: [
          if (pdfUrl != null) ...[
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
          error != null
              ? _ErrorPane(message: error!, onRetry: _fetchPdf)
              : pdfUrl == null
              ? const Center(child: CircularProgressIndicator())
              : PDF().fromUrl(
                pdfUrl!,
                placeholder: (progress) => Center(child: Text('$progress %')),
                errorWidget: (error) => Center(child: Text(error.toString())),
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
