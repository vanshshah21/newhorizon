import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/pages/followup/pages/add_follow_up.dart';
import 'package:nhapp/pages/leads/models/lead_attachment.dart';
import 'package:nhapp/pages/leads/pages/lead_pdf_loader_page.dart';
import 'package:nhapp/pages/leads/services/lead_attachment_service.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nhapp/pages/quotation/test/page/ad_qote.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/lead_data.dart';
import '../models/lead_detail_data.dart';
import '../services/lead_service.dart';

class InquiryDetailsPage extends StatefulWidget {
  final LeadData lead;
  const InquiryDetailsPage({required this.lead, super.key});

  @override
  State<InquiryDetailsPage> createState() => _InquiryDetailsPageState();
}

class _InquiryDetailsPageState extends State<InquiryDetailsPage> {
  LeadDetailData? data;
  late List<LeadAttachment> attachments;
  String? error;
  String? attachmentError;

  bool _isDownloading = false;
  bool _isSharing = false;
  bool _isLoadingAttachments = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchAttachments();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      data = null;
      error = null;
    });

    LeadService service = LeadService();
    try {
      final detail = await service.fetchLeadDetails(
        customerCode: widget.lead.customerCode,
        salesmanCode: widget.lead.salesmanCode,
        inquiryYear: widget.lead.inquiryYear,
        inquiryGroup: widget.lead.inquiryGroup,
        inquirySiteCode: widget.lead.locationCode,
        inquiryNumber: widget.lead.inquiryNumber,
        inquiryID: widget.lead.inquiryID,
      );
      if (!mounted) return;
      setState(() => data = detail);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Error: $e');
    }
  }

  Future<void> _fetchAttachments() async {
    setState(() {
      _isLoadingAttachments = true;
      attachmentError = null;
    });

    try {
      final service = LeadAttachmentService(Dio());
      final leadService = LeadService();
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';

      final fetchedAttachments = await service.fetchLeadAttachments(
        baseUrl: baseUrl,
        inquiryYear: widget.lead.inquiryYear,
        inquiryGroup: widget.lead.inquiryGroup,
        locationCode: widget.lead.locationCode,
        inquiryNumber: widget.lead.inquiryNumber,
      );

      if (!mounted) return;
      setState(() {
        attachments = fetchedAttachments;
        _isLoadingAttachments = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        attachmentError = 'Failed to load attachments: $e';
        _isLoadingAttachments = false;
      });
    }
  }

  void _navigateToFollowUp() {
    if (data == null) return;

    final followUpData = {
      'customerCode': data!.customerCode,
      'customerName': data!.customerName,
      'salesmanCode': data!.salesmanCode,
      'salesmanName': data!.salesmanName,
      'inquiryNumber': data!.inquiryNumber,
      'inquiryID': data!.inquiryID,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFollowUpForm(initialData: followUpData),
      ),
    );
  }

  void _navigateToQuotation() {
    if (data == null) return;

    final quotationData = {
      'customerCode': data!.customerCode,
      'customerName': data!.customerName,
      'salesmanCode': data!.salesmanCode,
      'salesmanName': data!.salesmanName,
      'inquiryNumber': data!.inquiryNumber,
      'inquiryID': data!.inquiryID,
      'inquiryYear': widget.lead.inquiryYear,
      'inquiryGroup': widget.lead.inquiryGroup,
      'locationCode': widget.lead.locationCode,
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddQuotationPage(initialData: quotationData),
      ),
    );
  }

  void _viewPdf() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LeadPdfLoaderPage(lead: widget.lead),
      ),
    );
  }

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

  /* ---------- Path helpers ---------- */

  Future<String> _cacheDir() async => (await getTemporaryDirectory()).path;

  Future<String> _downloadsDir() async {
    if (Platform.isAndroid) {
      return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOAD,
      );
    }
    return (await getApplicationDocumentsDirectory()).path;
  }

  /* ---------- Downloader ---------- */

  Future<String?> _downloadPdfFile({required bool toCache}) async {
    final service = LeadService();
    final pdfUrl = await service.fetchLeadPdfUrl(widget.lead);

    if (pdfUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PDF not available')));
      }
      return null;
    }

    if (!toCache && !(await _ensureStoragePermission())) return null;

    final dir = toCache ? await _cacheDir() : await _downloadsDir();
    final name =
        'Lead_${widget.lead.inquiryNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final path = '$dir/$name';

    final file = File(path);
    if (await file.exists()) return path;

    try {
      await Dio().download(pdfUrl, path);
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

  /* ---------- Download ---------- */

  Future<void> _handleDownload() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final path = await _downloadPdfFile(toCache: false);
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

  /* ---------- Share ---------- */

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final path = await _downloadPdfFile(toCache: true);
      if (path == null) throw Exception('Unable to prepare PDF');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path, name: 'Lead_${widget.lead.inquiryNumber}.pdf')],
          text: 'Lead ${widget.lead.inquiryNumber} PDF',
          subject: 'Lead ${widget.lead.inquiryNumber} PDF',
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

  Widget _buildAttachmentsSection() {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Attachments Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.attachment, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Attachments",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isLoadingAttachments) ...[
                  const SizedBox(width: 12),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),

          // Attachments Content
          if (_isLoadingAttachments)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (attachmentError != null)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    attachmentError!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _fetchAttachments,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          else if (attachments == null || attachments!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 48,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No attachments found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          else
            ...attachments!.map(
              (attachment) => _buildAttachmentItem(attachment),
            ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(LeadAttachment attachment) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        // leading: _getFileIcon(attachment.extension),
        title: Text(
          attachment.originalName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatFileSize(attachment.size),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        // trailing: Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     IconButton(
        //       onPressed: () => _viewAttachment(attachment),
        //       icon: const Icon(Icons.visibility),
        //       tooltip: 'View',
        //     ),
        //     IconButton(
        //       onPressed: () => _downloadAttachment(attachment),
        //       icon: const Icon(Icons.download),
        //       tooltip: 'Download',
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Widget _getFileIcon(String extension) {
    final theme = Theme.of(context);
    IconData iconData;
    Color color;

    switch (extension.toLowerCase()) {
      case '.pdf':
        iconData = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        iconData = Icons.image;
        color = Colors.blue;
        break;
      case '.doc':
      case '.docx':
        iconData = Icons.description;
        color = Colors.blue;
        break;
      case '.xls':
      case '.xlsx':
        iconData = Icons.table_chart;
        color = Colors.green;
        break;
      default:
        iconData = Icons.insert_drive_file;
        color = theme.colorScheme.outline;
        break;
    }

    return Icon(iconData, color: color, size: 32);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _viewAttachment(LeadAttachment attachment) {
    // Implement view functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('View ${attachment.originalName}')));
  }

  void _downloadAttachment(LeadAttachment attachment) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download ${attachment.originalName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry Details')),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchDetail();
            await _fetchAttachments();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(child: Text(error!)),
            ),
          ),
        ),
      );
    }
    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('View Lead')),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton.filledTonal(
                              onPressed:
                                  _isDownloading ? null : _handleDownload,
                              icon:
                                  _isDownloading
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.download, size: 20),
                            ),
                            const SizedBox(width: 6),
                            IconButton.filledTonal(
                              onPressed: _viewPdf,
                              icon: const Icon(Icons.picture_as_pdf, size: 20),
                            ),
                            const SizedBox(width: 6),
                            IconButton.filledTonal(
                              onPressed: _isSharing ? null : _handleShare,
                              icon:
                                  _isSharing
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Icon(Icons.share, size: 20),
                            ),
                            const SizedBox(width: 6),
                            IconButton.filledTonal(
                              onPressed: () {},
                              icon: const Icon(Icons.location_on, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Card(
                //   child: Row(
                //     children: [
                //       ElevatedButton.icon(
                //         onPressed: () async {
                //           final result = await Navigator.of(context).push(
                //             MaterialPageRoute(
                //               builder:
                //                   (context) => AddQuotationPage(
                //                     leadData: widget.lead,
                //                     leadDetailData: data,
                //                   ),
                //             ),
                //           );
                //           if (result == true) {
                //             // Quotation created successfully
                //             ScaffoldMessenger.of(context).showSnackBar(
                //               const SnackBar(
                //                 content: Text(
                //                   'Quotation created successfully!',
                //                 ),
                //               ),
                //             );
                //           }
                //         },
                //         icon: const Icon(Icons.add_business, size: 18),
                //         label: const Text('Create Quotation'),
                //         style: ElevatedButton.styleFrom(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 12,
                //             vertical: 8,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToFollowUp,
                            icon: const Icon(Icons.schedule_send, size: 18),
                            label: const Text('Add Follow Up'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: borderColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _navigateToQuotation,
                            icon: const Icon(Icons.add_business, size: 18),
                            label: const Text('Create Quotation'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // CardHeader
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lead No. ${data!.inquiryNumber}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Customer: ${data!.customerCode} - ${data!.customerName}",
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      // Customer Information Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Customer Code",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: data!.customerCode,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Customer Name",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: data!.customerName,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Sales Team Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Salesman",
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      text:
                                          "${data!.salesmanCode} - ${data!.salesmanName}",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Region",
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      text:
                                          "${data!.salesRegionCode} - ${data!.salesRegionCodeDesc}",
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Inquiry Summary Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Lead Date",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: FormatUtils.formatDateForUser(
                                            DateTime.parse(data!.inquiryDate),
                                          ),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Source",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: data!.inquirySourceDesc,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Consultant",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: data!.consultantFullName,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Group",
                                        style: theme.textTheme.labelSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          text: data!.inquiryGroup,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Items Section Header
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: borderColor, width: 1),
                          ),
                        ),
                        child: Text(
                          "Items",
                          style: theme.textTheme.titleMedium,
                        ),
                      ),

                      // Items Section
                      ...List.generate(data!.inqEntryItemModel.length, (index) {
                        final item = data!.inqEntryItemModel[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Item Code/ Name",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            text:
                                                "${item.salesItemCode} - ${item.itemName}",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Quantity",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            text: FormatUtils.formatQuantity(
                                              item.itemQty,
                                            ),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "SUOM",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            text: item.uom,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rate",
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            text: FormatUtils.formatAmount(
                                              item.basicPrice,
                                            ),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                _buildAttachmentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
