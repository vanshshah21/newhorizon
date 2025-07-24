import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_proforma_invoice.dart';
import 'package:nhapp/pages/sales_order/models/sales_order.dart';
import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
import 'package:nhapp/pages/sales_order/service/so_attachment.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/map_utils.dart';
import 'package:nhapp/utils/rightsChecker.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sales_order_detail.dart';
import 'so_pdf_page.dart';

class SalesOrderDetailPage extends StatefulWidget {
  final SalesOrder salesOrder;
  const SalesOrderDetailPage({required this.salesOrder, super.key});

  @override
  State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
}

class _SalesOrderDetailPageState extends State<SalesOrderDetailPage> {
  SalesOrderDetail? detail;
  List<Map<String, dynamic>>? attachments;
  String? attachmentError;
  bool _isLoadingAttachments = false;
  late final SalesOrderAttachmentService _attachmentService;
  String? error;
  bool loading = true;

  bool _isDownloading = false;
  bool _isSharing = false;

  Map<String, dynamic>? locationData;
  bool _isLoadingLocation = false;
  String? locationError;

  @override
  void initState() {
    super.initState();
    _attachmentService = SalesOrderAttachmentService(Dio());
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
          'functioncode': 'SO',
          'functionid': widget.salesOrder.orderId.toString(),
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
      final service = SalesOrderService();
      final result = await service.fetchSalesOrderDetails(widget.salesOrder);
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
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';

      final attachmentsList = await _attachmentService
          .fetchSalesOrderAttachments(
            baseUrl: baseUrl,
            ioYear: widget.salesOrder.ioYear,
            ioGroup: widget.salesOrder.ioGroup,
            ioSiteCode: widget.salesOrder.siteCode,
            ioNumber: widget.salesOrder.ioNumber,
          );

      if (!mounted) return;
      setState(() {
        attachments = attachmentsList;
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

  void _viewPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SalesOrderPdfLoaderPage(salesOrder: widget.salesOrder),
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
    final service = SalesOrderService();
    final pdfUrl = await service.fetchSalesOrderPdfUrl(widget.salesOrder);

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
        'SalesOrder_${widget.salesOrder.ioNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

      await Share.shareXFiles(
        [XFile(path, name: 'SalesOrder_${widget.salesOrder.ioNumber}.pdf')],
        text: 'Sales Order ${widget.salesOrder.ioNumber} PDF',
        subject: 'Sales Order ${widget.salesOrder.ioNumber} PDF',
      );
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

  /* ---------- Location ---------- */

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
            content: Text('Location is not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await MapsUtils.showLocationDialog(
        context: context,
        latitude: latitude,
        longitude: longitude,
        label: 'Sales Order ${widget.salesOrder.ioNumber}',
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

  // Calculate total tax amount from rate structure details
  double _calculateTotalTaxAmount() {
    if (detail?.rateStructureDetails == null) return 0;

    double totalTax = 0;
    for (var rateDetail in detail!.rateStructureDetails) {
      totalTax += (rateDetail['rateAmount'] ?? 0).toDouble();
    }
    return totalTax;
  }

  // Calculate basic amount (sum of all item amounts)
  double _calculateBasicAmount() {
    if (detail?.modelDetails == null) return 0;

    double basicAmount = 0;
    for (var item in detail!.modelDetails) {
      final qty = (item['qtyIUOM'] ?? 0).toDouble();
      final rate = (item['basicPriceIUOM'] ?? 0).toDouble();
      basicAmount += qty * rate;
    }
    return basicAmount;
  }

  // Calculate total discount amount
  double _calculateDiscountAmount() {
    if (detail?.modelDetails == null) return 0;

    double totalDiscount = 0;
    for (var item in detail!.modelDetails) {
      totalDiscount += (item['discountAmt'] ?? 0).toDouble();
    }
    return totalDiscount;
  }

  Future<void> _navigateToAddProformaInvoice() async {
    if (detail == null) return;

    // Convert SalesOrderDetail to Map format for Proforma Invoice
    final salesOrderData = {
      'salesOrderDetails': detail!.salesOrderDetails,
      'modelDetails': detail!.modelDetails,
      'rateStructureDetails': detail!.rateStructureDetails,
      'discountDetails': detail!.discountDetails,
    };

    // Convert SalesOrder to Map format
    final salesOrderItem = {
      'salesOrderId': widget.salesOrder.orderId,
      'ioNumber': widget.salesOrder.ioNumber,
      'ioYear': widget.salesOrder.ioYear,
      'ioGroup': widget.salesOrder.ioGroup,
      'siteCode': widget.salesOrder.siteCode,
      'ioDate': widget.salesOrder.date,
      'customerName': widget.salesOrder.customerFullName,
      'customerCode': widget.salesOrder.customerCode,
      'isAuthorized': widget.salesOrder.isAuthorized,
      'orderStatus': widget.salesOrder.orderStatus,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddProformaInvoiceForm(
              salesOrderData: salesOrderData,
              salesOrderItem: salesOrderItem,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool canPrint = RightsChecker.canPrint('Sales Order Print');
    final bool canAddProformaInvoice = RightsChecker.canAdd('Proforma Invoice');

    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sales Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sales Order Details')),
        body: RefreshIndicator(
          onRefresh: _fetchDetail,
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
        appBar: AppBar(title: const Text('Sales Order Details')),
        body: RefreshIndicator(
          onRefresh: _fetchDetail,
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(child: Text('No data found.')),
          ),
        ),
      );
    }

    final so = detail!.salesOrderDetails;
    final items = detail!.modelDetails;

    final isAuthorized = widget.salesOrder.isAuthorized == true;
    final isNotCancelled =
        widget.salesOrder.orderStatus.toLowerCase() != 'close';
    final canCreateProformaInvoice = isAuthorized && isNotCancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Order Details'),
        actions: [
          if (canPrint)
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
          if (canPrint)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _viewPdf,
              tooltip: 'View PDF',
            ),
          if (canPrint)
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
          await _fetchDetail();
          await _fetchAttachments();
          await _fetchLocationData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (canCreateProformaInvoice && canAddProformaInvoice) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToAddProformaInvoice,
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('Add Proforma Invoice'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                      // Section 1: Sales Order Reference
                      Text(
                        'Sales Order - ${so['ioNumber'] ?? ''}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(thickness: 1.2),
                      const SizedBox(height: 16),

                      // Section 2: Order From and Bill To
                      Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              'Order From',
                              so['customerName'] ?? '-',
                            ),
                          ),
                          Expanded(
                            child: _infoTile(
                              'Bill To',
                              so['billToName'] ?? '-',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Section 3: Date and Customer PO Number
                      Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              'Date',
                              so['ioDate'] != null
                                  ? FormatUtils.formatDateForUser(
                                    DateTime.parse(so['ioDate']),
                                  )
                                  : '-',
                            ),
                          ),
                          Expanded(
                            child: _infoTile(
                              'Customer PO Number',
                              so['customerPONumber'] ?? '-',
                            ),
                          ),
                        ],
                      ),

                      // Section 4: Items
                      const SizedBox(height: 24),
                      Text(
                        'Items',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.map((item) => _itemCard(context, item)),

                      // Section 5: Amount Summary
                      const SizedBox(height: 24),
                      Text(
                        'Amount Summary',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _amountRow('Basic Amount', _calculateBasicAmount()),
                      _amountRow('Discount Amount', _calculateDiscountAmount()),
                      _amountRow('Tax Amount', _calculateTotalTaxAmount()),
                      const Divider(thickness: 1),
                      _amountRow(
                        'Total Amount',
                        so['totalAmounttAfterTaxDomesticCurrency'] ?? 0,
                        isTotal: true,
                      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _itemCard(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);

    // Calculate item amount (quantity * rate)
    final qty = (item['qtyIUOM'] ?? 0).toDouble();
    final rate = (item['basicPriceIUOM'] ?? 0).toDouble();
    final amount = qty * rate;
    final discount = (item['discountAmt'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item code and name
            Text(
              '${item['salesItemCode'] ?? '-'} / ${item['salesItemDesc'] ?? '-'}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Quantity, Rate, Amount
            Row(
              children: [
                Expanded(
                  child: _itemDetailTile(
                    'Quantity',
                    '${qty.toStringAsFixed(0)} ${item['uom'] ?? ''}',
                  ),
                ),
                Expanded(
                  child: _itemDetailTile('Rate', rate.toStringAsFixed(2)),
                ),
                Expanded(
                  child: _itemDetailTile('Amount', amount.toStringAsFixed(2)),
                ),
              ],
            ),

            // Discount if applicable
            if (discount > 0) ...[
              const SizedBox(height: 8),
              _itemDetailTile('Discount', discount.toStringAsFixed(2)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemDetailTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _amountRow(String label, dynamic value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value is num ? value.toStringAsFixed(2) : value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
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

  // Add this method to build individual attachment items
  Widget _buildAttachmentItem(Map<String, dynamic> attachment) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;

    final originalName =
        attachment['originalFileName'] ?? attachment['name'] ?? 'Unknown file';
    final extension = attachment['extension'] ?? '';
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

  // Add these helper methods
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

  void _viewAttachment(Map<String, dynamic> attachment) {
    final originalName =
        attachment['originalFileName'] ?? attachment['name'] ?? 'file';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('View $originalName')));
  }

  void _downloadAttachment(Map<String, dynamic> attachment) {
    final originalName =
        attachment['originalFileName'] ?? attachment['name'] ?? 'file';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Download $originalName')));
  }
}
