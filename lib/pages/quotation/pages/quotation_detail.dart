import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_proforma_invoice.dart';
import 'package:nhapp/pages/quotation/service/quotation_service.dart';
import 'package:nhapp/utils/map_utils.dart';
import 'package:nhapp/utils/rightsChecker.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/quotation_list_item.dart';
import '../models/quotation_detail.dart';
import 'package:nhapp/pages/sales_order/pages/add_so.dart';
import 'quotation_pdf_loader_page.dart';

class QuotationDetailPage extends StatefulWidget {
  final QuotationListItem quotation;
  const QuotationDetailPage({required this.quotation, super.key});

  @override
  State<QuotationDetailPage> createState() => _QuotationDetailPageState();
}

class _QuotationDetailPageState extends State<QuotationDetailPage> {
  bool get _isAuthorized =>
      detail?.quotationDetails['isAuthorized'] ??
      widget.quotation.isAuthorized ??
      false;
  QuotationDetail? detail;
  List<Map<String, dynamic>>? attachments;
  String? error;
  String? attachmentError;
  bool loading = true;
  bool _isLoadingAttachments = false;

  bool _isDownloading = false;
  bool _isSharing = false;

  Map<String, dynamic>? locationData;
  bool _isLoadingLocation = false;
  String? locationError;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchAttachments();
    _fetchLocationData();
  }

  Future<void> _fetchLocationData() async {
    setState(() {
      _isLoadingLocation = true;
      locationError = null;
    });

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';

      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['Authorization'] = 'Bearer $token';

      const endpoint = "/api/Login/getGeoLocation";

      final response = await dio.get(
        '$baseUrl$endpoint',
        queryParameters: {
          'companyid': companyId,
          'functioncode': 'QT',
          'functionid': widget.quotation.qtnID.toString(),
        },
      );

      debugPrint("GeoLocation API response: ${response.data}");

      final data = jsonDecode(response.data) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        final parsedData = {
          'mLOCFUNCTIONID': data['data']['mLOCFUNCTIONID'],
          'longitude':
              double.tryParse(data['data']['mLOCLONGITUDE'].toString()) ?? 0.0,
          'latitude':
              double.tryParse(data['data']['mLOCLATITUDE'].toString()) ?? 0.0,
          'mLOCLONGITUDE': data['data']['mLOCLONGITUDE'],
          'mLOCLATITUDE': data['data']['mLOCLATITUDE'],
        };

        if (!mounted) return;
        setState(() {
          locationData = parsedData;
          _isLoadingLocation = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          locationData = null;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationError = 'Failed to load location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final service = QuotationService();
      final result = await service.fetchQuotationDetail(widget.quotation);
      if (!mounted) return;
      setState(() {
        detail = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Error: $e';
        loading = false;
      });
    }
  }

  Future<void> _fetchAttachments() async {
    setState(() {
      _isLoadingAttachments = true;
      attachmentError = null;
    });

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';

      final dio = Dio();
      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Accept'] = 'application/json';
      dio.options.headers['companyid'] = companyId.toString();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final endpoint = "/api/Login/attachment_details";

      // Create document number for quotation
      final documentNo =
          "${widget.quotation.qtnYear}/${widget.quotation.qtnGroup}/${widget.quotation.siteCode}/${widget.quotation.qtnNumber}/QUOTATIONENTRY";

      final response = await dio.post(
        '$baseUrl$endpoint',
        data: {"DocumentNo": documentNo, "FormID": "06103"},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        if (!mounted) return;
        setState(() {
          attachments = data.cast<Map<String, dynamic>>();
          _isLoadingAttachments = false;
        });
      } else {
        throw Exception('Failed to fetch attachments');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        attachmentError = 'Failed to load attachments: $e';
        _isLoadingAttachments = false;
      });
    }
  }

  void _viewPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuotationPdfLoaderPage(quotation: widget.quotation),
      ),
    );
  }

  /* ---------- Permission helper ---------- */

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
    final service = QuotationService();
    final pdfUrl = await service.fetchQuotationPdfUrl(widget.quotation);

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
        'Quotation_${widget.quotation.qtnNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
          files: [
            XFile(path, name: 'Quotation_${widget.quotation.qtnNumber}.pdf'),
          ],
          text: 'Quotation ${widget.quotation.qtnNumber} PDF',
          subject: 'Quotation ${widget.quotation.qtnNumber} PDF',
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

  Future<void> _handleLocationButton() async {
    if (locationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location data not available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final latitude =
          locationData!['latitude'] as double? ??
          double.tryParse(locationData!['mLOCLATITUDE'].toString());
      final longitude =
          locationData!['longitude'] as double? ??
          double.tryParse(locationData!['mLOCLONGITUDE'].toString());

      if (latitude == null ||
          latitude == 0.0 ||
          longitude == null ||
          longitude == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location data is not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await MapsUtils.showLocationDialog(
        context: context,
        latitude: latitude,
        longitude: longitude,
        label: 'Quotation ${widget.quotation.qtnNumber}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateTotalTaxAmount() {
    if (detail?.rateStructureDetails == null) return 0;

    double totalTax = 0;
    for (var rateDetail in detail!.rateStructureDetails) {
      totalTax += (rateDetail['rateAmount'] ?? 0).toDouble();
    }
    return totalTax;
  }

  double _calculateAmountAfterDiscount() {
    final totalAmountAfterTax =
        (detail?.quotationDetails['totalAmounttAfterTaxDomesticCurrency'] ?? 0)
            .toDouble();
    final taxAmount = _calculateTotalTaxAmount();
    return totalAmountAfterTax - taxAmount;
  }

  Future<void> _navigateToAddSalesOrder() async {
    if (detail == null) return;

    // Convert QuotationDetail to Map format
    final quotationData = {
      'quotationDetails': detail!.quotationDetails,
      'modelDetails': detail!.modelDetails,
      'rateStructureDetails': detail!.rateStructureDetails,
      'discountDetails': detail!.discountDetails,
    };

    // Convert QuotationListItem to Map format
    final quotationListItem = {
      'quotationId': widget.quotation.qtnID,
      'qtnNumber': widget.quotation.qtnNumber,
      'qtnYear': widget.quotation.qtnYear,
      'qtnGroup': widget.quotation.qtnGroup,
      'siteCode': widget.quotation.siteCode,
      'date': widget.quotation.date,
      'customerFullName': widget.quotation.customerFullName,
      'isAuthorized': widget.quotation.isAuthorized,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddSalesOrderPage(
              quotationData: quotationData,
              quotationListItem: quotationListItem,
            ),
      ),
    );

    if (result == true) {
      // Sales order was created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sales Order created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _navigateToAddProformaInvoice() async {
    if (detail == null) return;

    // Convert QuotationDetail to Map format for Proforma Invoice
    final quotationData = {
      'quotationDetails': detail!.quotationDetails,
      'modelDetails': detail!.modelDetails,
      'rateStructureDetails': detail!.rateStructureDetails,
      'discountDetails': detail!.discountDetails,
    };

    // Convert QuotationListItem to Map format
    final quotationListItem = {
      'quotationId': widget.quotation.qtnID,
      'qtnNumber': widget.quotation.qtnNumber,
      'qtnYear': widget.quotation.qtnYear,
      'qtnGroup': widget.quotation.qtnGroup,
      'siteCode': widget.quotation.siteCode,
      'date': widget.quotation.date,
      'customerFullName': widget.quotation.customerFullName,
      'isAuthorized': widget.quotation.isAuthorized,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddProformaInvoiceForm(
              quotationData: quotationData,
              quotationListItem: quotationListItem,
            ),
      ),
    );

    if (result == true) {
      // Proforma Invoice was created successfully
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proforma Invoice created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildAttachmentsSection() {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    return Card(
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Attachments Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (attachmentError != null)
            Padding(
              padding: const EdgeInsets.all(20),
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
              padding: const EdgeInsets.all(20),
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

  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    final originalName =
        attachment['originalName'] ?? attachment['name'] ?? 'Unknown file';
    final size = attachment['size'] ?? 0;
    final createdByName = attachment['createdByName'] ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      ),
      child: ListTile(
        // leading: _getFileIcon(extension),
        title: Text(
          originalName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatFileSize(size), style: theme.textTheme.bodySmall),
            if (createdByName.isNotEmpty)
              Text(
                'Uploaded by: $createdByName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool canAddSalesOrder = RightsChecker.canAdd('Sales Order');
    final bool canAddProformaInvoice = RightsChecker.canAdd('Proforma Invoice');
    final bool canViewPdf = RightsChecker.canPrint('Quotation Print');

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quotation Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quotation Details')),
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchDetail();
            _fetchAttachments();
            _fetchLocationData();
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
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quotation Details')),
        body: RefreshIndicator(
          onRefresh: () async {
            _fetchDetail();
            _fetchAttachments();
            _fetchLocationData();
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(child: Text('No data found.')),
          ),
        ),
      );
    }

    final q = detail!.quotationDetails;
    final items = detail!.modelDetails;

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '-';
      try {
        final dt = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {
        return dateStr;
      }
    }

    // Section 1: Title
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quotation No. ${q['quotationNumber'] ?? widget.quotation.qtnNumber}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          q['customerName'] ?? widget.quotation.customerFullName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
    // Section 2: Separator & Info Grid
    final infoSection = Column(
      children: [
        const SizedBox(height: 8),
        const Divider(thickness: 1.2),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile('Quotation Base', q['quotationTypeSalesOrder'] ?? '-'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile('Quotation To', q['customerName'] ?? '-'),
            _infoTile('Bill To', q['billToCustomerName'] ?? '-'),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _infoTile(
              'Number',
              q['quotationNumber'] ?? widget.quotation.qtnNumber,
            ),
            _infoTile(
              'Date',
              formatDate(q['quotationDate'] ?? widget.quotation.date),
            ),
          ],
        ),
      ],
    );

    // Section 3: Items
    final itemsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Items',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _itemCard(context, item)),
      ],
    );

    // Section 4: Amounts
    final amountsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Amounts',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _amountRow(
          'Total Amount (After Discount)',
          _calculateAmountAfterDiscount(),
        ),
        _amountRow('Tax Amount', _calculateTotalTaxAmount()),
        const Divider(thickness: 1),
        _amountRow(
          'Total Amount',
          q['totalAmounttAfterTaxDomesticCurrency'] ?? 0,
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          if (canViewPdf)
            IconButton(
              icon:
                  _isDownloading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.download),
              onPressed: _isDownloading ? null : _handleDownload,
              tooltip: 'Download PDF',
            ),
          if (canViewPdf)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _viewPdf,
              tooltip: 'View PDF',
            ),
          if (canViewPdf)
            IconButton(
              icon:
                  _isSharing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.share),
              onPressed: _isSharing ? null : _handleShare,
              tooltip: 'Share PDF',
            ),
          IconButton(
            onPressed: _isLoadingLocation ? null : _handleLocationButton,
            icon:
                _isLoadingLocation
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(
                      Icons.location_on,
                      size: 20,
                      color:
                          locationData != null
                              ? null
                              : Theme.of(context).colorScheme.outline,
                    ),
            tooltip: 'View Location',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchDetail();
          _fetchAttachments();
          _fetchLocationData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_isAuthorized) ...[
                Row(
                  children: [
                    if (canAddSalesOrder)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _navigateToAddSalesOrder,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Sales Order'),
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
                    if (canAddProformaInvoice)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _navigateToAddProformaInvoice,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Proforma Invoice'),
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
              ],
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titleSection,
                      infoSection,
                      itemsSection,
                      amountsSection,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAttachmentsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _itemCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item['salesItemCode'] ?? item['itemCode'] ?? '-'} - ${item['itemName'] ?? item['salesItemDesc'] ?? '-'}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Description: ${item['description'] ?? '-'}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('Qty: ${item['qtyIUOM'] ?? item['qty'] ?? '-'}'),
                ),
                Expanded(child: Text('UOM: ${item['uom'] ?? '-'}')),
                Expanded(
                  child: Text(
                    'Rate: ${item['basicPriceIUOM'] ?? item['rate'] ?? '-'}',
                  ),
                ),
              ],
            ),
            if (item['remark'] != null && (item['remark'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Remark: ${item['remark']}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value is num ? value.toStringAsFixed(2) : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
