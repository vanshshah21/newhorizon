import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/followup/pages/add_follow_up.dart';
import 'package:nhapp/pages/leads/models/lead_attachment.dart';
import 'package:nhapp/pages/leads/pages/lead_pdf_loader_page.dart';
import 'package:nhapp/pages/leads/services/lead_attachment_service.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/map_utils.dart';
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
  List<LeadAttachment> attachments = []; // Fixed: Initialize instead of late
  String? error;
  String? attachmentError;

  Map<String, dynamic>? locationData;
  bool _isLoadingLocation = false;
  String? locationError;

  bool _isDownloading = false;
  bool _isSharing = false;
  bool _isLoadingAttachments = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchAttachments();
    _fetchLocationData();
  }

  @override
  void dispose() {
    // Clean up any cached files on dispose
    _cleanupCachedFiles();
    super.dispose();
  }

  Future<void> _cleanupCachedFiles() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final files = cacheDir.listSync();

      for (final file in files) {
        if (file.path.contains('Lead_${widget.lead.inquiryNumber}') &&
            file.path.endsWith('.pdf')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
      debugPrint('Cache cleanup error: $e');
    }
  }

  Future<void> _fetchLocationData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
      locationError = null;
    });

    try {
      final service = LeadService();
      locationData = await service.getGeoLocation(
        functionId: widget.lead.inquiryID.toString(),
      );

      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationError = 'Failed to load location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  // Fixed location button handler with better error handling
  Future<void> _handleLocationButton() async {
    if (!mounted) return;

    if (locationData == null) {
      _showSnackBar('Location data not available', Colors.orange);
      return;
    }

    try {
      // Better error handling for location parsing
      final latStr = locationData!['mLOCLATITUDE']?.toString();
      final lngStr = locationData!['mLOCLONGITUDE']?.toString();

      if (latStr == null ||
          lngStr == null ||
          latStr.isEmpty ||
          lngStr.isEmpty) {
        _showSnackBar('Location coordinates not available', Colors.orange);
        return;
      }

      final latitude = double.tryParse(latStr);
      final longitude = double.tryParse(lngStr);

      if (latitude == null || longitude == null) {
        _showSnackBar('Invalid location coordinates format', Colors.red);
        return;
      }

      // Validate coordinate ranges
      if (latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        _showSnackBar(
          'Location coordinates are out of valid range',
          Colors.red,
        );
        return;
      }

      await MapsUtils.showLocationDialog(
        context: context,
        latitude: latitude,
        longitude: longitude,
        label: 'Lead ${widget.lead.inquiryNumber}',
      );
    } catch (e) {
      _showSnackBar('Error opening location: $e', Colors.red);
    }
  }

  // Helper method for showing snackbars
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _fetchDetail() async {
    if (!mounted) return;

    setState(() {
      data = null;
      error = null;
    });

    try {
      final service = LeadService();
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
      setState(() => error = 'Error loading lead details: $e');
    }
  }

  Future<void> _fetchAttachments() async {
    if (!mounted) return;

    setState(() {
      _isLoadingAttachments = true;
      attachmentError = null;
    });

    try {
      final service = LeadAttachmentService(Dio());
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
        attachments = []; // Ensure attachments is always a valid list
      });
    }
  }

  void _navigateToFollowUp() {
    if (data == null || !mounted) return;

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
    if (data == null || !mounted) return;

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
    if (!mounted) return;

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
          // Re-check permission after user returns from settings
          status = await permission.status;
          return status.isGranted;
        }
        return false;
      }

      return false;
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error checking permissions: $e', Colors.red);
      }
      return false;
    }
  }

  Future<bool> _showPermissionDialog({
    required String title,
    required String message,
    bool showSettingsButton = false,
  }) async {
    if (!mounted) return false;

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
    try {
      final service = LeadService();
      final pdfUrl = await service.fetchLeadPdfUrl(widget.lead);

      if (pdfUrl.isEmpty) {
        if (mounted) {
          _showSnackBar('PDF not available', Colors.orange);
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

      final dio = Dio();
      await dio.download(pdfUrl, path);
      return path;
    } catch (e) {
      if (mounted) {
        _showSnackBar('Download failed: $e', Colors.red);
      }
      return null;
    }
  }

  /* ---------- Download ---------- */

  Future<void> _handleDownload() async {
    if (_isDownloading || !mounted) return;

    setState(() => _isDownloading = true);

    try {
      final path = await _downloadPdfFile(toCache: false);
      if (path == null) {
        if (mounted) {
          _showSnackBar(
            'Download cancelled or permission denied',
            Colors.orange,
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
    if (_isSharing || !mounted) return;

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
    } catch (e) {
      if (mounted) {
        _showSnackBar('Share failed: $e', Colors.red);
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
          else if (attachments.isEmpty) // Fixed: Remove null check
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
            ...attachments.map(
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
        leading: _getFileIcon(attachment),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _viewAttachment(attachment),
              icon: const Icon(Icons.visibility),
              tooltip: 'View',
            ),
            IconButton(
              onPressed: () => _downloadAttachment(attachment),
              icon: const Icon(Icons.download),
              tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }

  // Added file icon helper
  Widget _getFileIcon(LeadAttachment attachment) {
    final extension = attachment.originalName.split('.').last.toLowerCase();

    IconData iconData;
    Color iconColor = Colors.grey;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        iconData = Icons.image;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.insert_drive_file;
    }

    return Icon(iconData, color: iconColor);
  }

  // Added attachment actions
  Future<void> _viewAttachment(LeadAttachment attachment) async {
    // Implement attachment viewing logic
    _showSnackBar('View attachment feature coming soon', Colors.blue);
  }

  Future<void> _downloadAttachment(LeadAttachment attachment) async {
    // Implement attachment download logic
    _showSnackBar('Download attachment feature coming soon', Colors.blue);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Added refresh method for pull-to-refresh
  Future<void> _refreshData() async {
    await Future.wait([
      _fetchDetail(),
      _fetchAttachments(),
      _fetchLocationData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry Details')),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
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
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            children: [
              // Action Buttons Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: borderColor, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        onPressed: _isDownloading ? null : _handleDownload,
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
                        label: 'Download',
                      ),
                      _buildActionButton(
                        onPressed: _viewPdf,
                        icon: const Icon(Icons.picture_as_pdf, size: 20),
                        label: 'View PDF',
                      ),
                      _buildActionButton(
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
                        label: 'Share',
                      ),
                      _buildActionButton(
                        onPressed:
                            _isLoadingLocation ? null : _handleLocationButton,
                        icon:
                            _isLoadingLocation
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.location_on, size: 20),
                        label: 'Location',
                      ),
                    ],
                  ),
                ),
              ),

              // Follow Up Card
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //     side: BorderSide(color: borderColor, width: 1),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: SizedBox(
              //       width: double.infinity,
              //       child: ElevatedButton.icon(
              //         onPressed: _navigateToFollowUp,
              //         icon: const Icon(Icons.schedule_send, size: 18),
              //         label: const Text('Add Follow Up'),
              //         style: ElevatedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 16,
              //             vertical: 12,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // // Quotation Card
              // Card(
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //     side: BorderSide(color: borderColor, width: 1),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: SizedBox(
              //       width: double.infinity,
              //       child: ElevatedButton.icon(
              //         onPressed: _navigateToQuotation,
              //         icon: const Icon(Icons.add_business, size: 18),
              //         label: const Text('Create Quotation'),
              //         style: ElevatedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 16,
              //             vertical: 12,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _navigateToFollowUp,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Follow Up'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            topLeft: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _navigateToQuotation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Quotation'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Main Details Card
              Card(
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: borderColor, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card Header
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
                    _buildInfoSection("Customer Information", [
                      _buildInfoRow("Customer Code", data!.customerCode),
                      _buildInfoRow("Customer Name", data!.customerName),
                    ]),

                    // Sales Team Section
                    _buildInfoSection("Sales Team", [
                      _buildInfoRow(
                        "Salesman",
                        "${data!.salesmanCode} - ${data!.salesmanName}",
                      ),
                      _buildInfoRow(
                        "Region",
                        "${data!.salesRegionCode} - ${data!.salesRegionCodeDesc}",
                      ),
                    ]),

                    // Inquiry Summary Section
                    _buildInfoSection("Inquiry Summary", [
                      _buildInfoRow(
                        "Lead Date",
                        FormatUtils.formatDateForUser(
                          DateTime.parse(data!.inquiryDate),
                        ),
                      ),
                      _buildInfoRow("Source", data!.inquirySourceDesc),
                      _buildInfoRow("Consultant", data!.consultantFullName),
                      _buildInfoRow("Group", data!.inquiryGroup),
                    ]),

                    // Items Section
                    _buildItemsSection(),
                  ],
                ),
              ),

              // Attachments Section
              _buildAttachmentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for action buttons
  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(onPressed: onPressed, icon: icon),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  // Helper method for info sections
  Widget _buildInfoSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Helper method for info rows
  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.labelSmall),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for items section
  Widget _buildItemsSection() {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: borderColor, width: 1)),
          ),
          child: Text(
            "Items",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...List.generate(data!.inqEntryItemModel.length, (index) {
          final item = data!.inqEntryItemModel[index];
          return Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Item ${index + 1}",
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildItemDetailRow(
                  "Item Code/Name",
                  "${item.salesItemCode} - ${item.itemName}",
                ),
                _buildItemDetailRow(
                  "Quantity",
                  FormatUtils.formatQuantity(item.itemQty),
                ),
                _buildItemDetailRow("UOM", item.uom),
                _buildItemDetailRow(
                  "Rate",
                  FormatUtils.formatAmount(item.basicPrice),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method for item detail rows
  Widget _buildItemDetailRow(String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
