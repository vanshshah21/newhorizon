import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart'; // Optional, to open after download
import 'package:external_path/external_path.dart'; // <== ADD THIS

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
  String? pdfUrl;
  String? error;
  final service = POService();
  bool _isDownloading = false;
  bool _isSharing = false;
  String? _downloadedFilePath;

  @override
  void initState() {
    super.initState();
    _fetchPdf();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      error = null;
      pdfUrl = null;
    });
    try {
      final url = await service.fetchPOPdfUrl(widget.po, widget.isRegular);
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

  // ---- NEW: Robust Download Directory Handler ----
  Future<String> _getDownloadPath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      try {
        // Try to get public Download folder (for Android 11+)
        final downloadsPath =
            await ExternalPath.getExternalStoragePublicDirectory('Download');

        directory = Directory(downloadsPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } catch (e) {
        // Fallback: app's private external dir
        directory = await getExternalStorageDirectory();
      }
    } else {
      // iOS - App's docs directory
      directory = await getApplicationDocumentsDirectory();
    }
    return directory?.path ?? '';
  }

  // ---- Permission Handler ----
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return true; // iOS doesn't require storage permission
  }

  // ---- Download PDF ----
  Future<String?> _downloadPdfFile() async {
    if (pdfUrl == null) return null;

    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission required.')),
        );
      }
      return null;
    }

    try {
      final downloadPath = await _getDownloadPath();
      if (downloadPath.isEmpty) throw Exception('Download directory not found');
      final fileName =
          'PO_${widget.po.nmbr}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '$downloadPath/$fileName';
      final dio = Dio();

      // If file already exists, don't download again
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }

      await dio.download(pdfUrl!, filePath);
      return filePath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
      }
      return null;
    }
  }

  // ---- Download Handler ----
  Future<void> _downloadPdf() async {
    if (pdfUrl == null || _isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final filePath = await _downloadPdfFile();
      if (filePath != null && mounted) {
        setState(() => _downloadedFilePath = filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PDF downloaded to: ${Platform.isAndroid ? 'Downloads' : 'Documents'}',
            ),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  // ---- Share Handler ----
  Future<void> _sharePdf() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      String? fileToShare = _downloadedFilePath;
      if (fileToShare == null || !await File(fileToShare).exists()) {
        fileToShare = await _downloadPdfFile();
        if (fileToShare != null) {
          setState(() => _downloadedFilePath = fileToShare);
        }
      }
      if (fileToShare != null && await File(fileToShare).exists()) {
        await Share.shareXFiles(
          [XFile(fileToShare, name: 'PO_${widget.po.nmbr}.pdf')],
          text: 'PO ${widget.po.nmbr} PDF',
          subject: 'PO ${widget.po.nmbr} PDF',
        );
      } else {
        throw Exception('No PDF file available to share');
      }
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

  // ---- UI ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PO PDF'),
        actions: [
          if (pdfUrl != null) ...[
            IconButton(
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.download),
              onPressed: _isDownloading ? null : _downloadPdf,
              tooltip: 'Download PDF',
            ),
            IconButton(
              icon:
                  _isSharing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.share),
              onPressed: _isSharing ? null : _sharePdf,
              tooltip: 'Share PDF',
            ),
          ],
        ],
      ),
      body:
          error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(error!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchPdf,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
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
