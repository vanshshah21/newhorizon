import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/utils/map_utils.dart';
import 'package:nhapp/utils/rightsChecker.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:open_file/open_file.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
import 'package:nhapp/pages/proforma_invoice/pages/proforma_invoice_pdf_loader_page.dart';
import 'package:nhapp/utils/format_utils.dart';

class ProformaInvoiceDetailsPage extends StatefulWidget {
  final ProformaInvoice invoice;

  const ProformaInvoiceDetailsPage({required this.invoice, super.key});

  @override
  State<ProformaInvoiceDetailsPage> createState() =>
      _ProformaInvoiceDetailsPageState();
}

class _ProformaInvoiceDetailsPageState
    extends State<ProformaInvoiceDetailsPage> {
  ProformaInvoiceDetails? details;
  final ProformaInvoiceService service = ProformaInvoiceService();
  String? error;
  bool isLoading = true;

  bool _isDownloading = false;
  bool _isSharing = false;
  bool _isLoadingLocation = false;
  Map<String, dynamic>? locationData;
  String? locationError;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _fetchLocationData();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final d = await service.fetchProformaInvoiceDetails(
        invSiteId: widget.invoice.siteId,
        invYear: widget.invoice.year,
        invGroup: widget.invoice.groupCode,
        invNumber: widget.invoice.number,
        piOn: widget.invoice.piOn,
        fromLocationId: widget.invoice.fromLocationId,
        custCode: widget.invoice.custCode,
      );
      if (!mounted) return;
      setState(() {
        details = d;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
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
          'functioncode': 'PI',
          'functionid': widget.invoice.id.toString(),
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
        label: 'Proforma Invoice ${widget.invoice.number}',
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

  void _viewPdf() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProformaInvoicePdfLoaderPage(
              invoice: widget.invoice,
              service: service,
            ),
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
    final pdfUrl = await service.fetchProformaInvoicePdfUrl(widget.invoice);

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
        'ProformaInvoice_${widget.invoice.number}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
        [XFile(path, name: 'ProformaInvoice_${widget.invoice.number}.pdf')],
        text: 'Proforma Invoice ${widget.invoice.number} PDF',
        subject: 'Proforma Invoice ${widget.invoice.number} PDF',
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

  Future<void> _handleLocation() async {
    if (details?.headerDetail == null) return;

    final header = details!.headerDetail;
    final customerName = header['customerName'] ?? '';

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No customer information available')),
      );
      return;
    }

    final encodedAddress = Uri.encodeComponent(customerName);
    final mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    try {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot open maps application')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
      }
    }
  }

  double _calculateBasicAmount() {
    if (details?.gridDetail == null) return 0;

    final items = details!.gridDetail['itemDetail'] as List? ?? [];
    double basicAmount = 0;

    for (var item in items) {
      final qty = double.tryParse(item['invoiceQty']?.toString() ?? '0') ?? 0;
      final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0;
      basicAmount += qty * rate;
    }

    return basicAmount;
  }

  double _calculateDiscountAmount() {
    if (details?.gridDetail == null) return 0;

    final items = details!.gridDetail['itemDetail'] as List? ?? [];
    double totalDiscount = 0;

    for (var item in items) {
      totalDiscount +=
          double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0;
    }

    return totalDiscount;
  }

  double _calculateTotalTaxAmount() {
    if (details?.gridDetail == null) return 0;

    final rateStructDetail =
        details!.gridDetail['rateStructDetail'] as List? ?? [];
    double totalTax = 0;

    for (var rateDetail in rateStructDetail) {
      totalTax +=
          double.tryParse(rateDetail['rateAmount']?.toString() ?? '0') ?? 0;
    }

    return totalTax;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canPrint = RightsChecker.canPrint('Proforma Invoice Print');

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Details')),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchDetails;
            await _fetchLocationData();
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

    if (details == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proforma Details')),
        body: RefreshIndicator(
          onRefresh: () async {
            await _fetchDetails;
            await _fetchLocationData();
          },
          child: const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Center(child: Text('No data found.')),
          ),
        ),
      );
    }

    final header = details!.headerDetail;
    final salesOrder = details!.salesOrderDetail;
    final items = (details!.gridDetail['itemDetail'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proforma Details'),
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
            icon: const Icon(Icons.location_on),
            onPressed: _isLoadingLocation ? null : _handleLocationButton,
            tooltip: 'View Location',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchDetails;
          await _fetchLocationData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Proforma Invoice Reference
                  Text(
                    'Proforma Invoice Reference',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${header['invYear'] ?? ''}-${header['invGroup'] ?? ''}/${header['invNumber'] ?? ''}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(thickness: 1.2),
                  const SizedBox(height: 16),

                  // Section 2: Customer and Currency Info
                  Row(
                    children: [
                      Expanded(
                        child: _infoTile(
                          'Customer Name',
                          header['customerName'] ?? '-',
                        ),
                      ),
                      Expanded(
                        child: _infoTile(
                          'Currency',
                          header['invCurrCode'] ??
                              salesOrder['currCode'] ??
                              '-',
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
                          header['invIssueDate'] != null
                              ? FormatUtils.formatDateForUser(
                                DateTime.parse(header['invIssueDate']),
                              )
                              : '-',
                        ),
                      ),
                      Expanded(
                        child: _infoTile(
                          'Customer PO Number',
                          header['customerPoNumber']?.toString().isNotEmpty ==
                                  true
                              ? header['customerPoNumber'].toString()
                              : salesOrder['poCustomerNumber']?.toString() ??
                                  '-',
                        ),
                      ),
                    ],
                  ),

                  // Section 4: Items
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Items',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...items.map((item) => _itemCard(context, item)),
                  ],

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
                    _calculateBasicAmount() +
                        _calculateTotalTaxAmount() +
                        _calculateDiscountAmount(),
                    isTotal: true,
                  ),
                ],
              ),
            ),
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

    // Calculate item amount
    final qty = double.tryParse(item['invoiceQty']?.toString() ?? '0') ?? 0;
    final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0;
    final amount = qty * rate;
    final discount =
        double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0;

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
              '${item['itemCode'] ?? '-'} / ${item['itemName'] ?? '-'}',
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
                    '${qty.toStringAsFixed(0)} ${item['suom'] ?? ''}',
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

  // Widget _amountRow(String label, dynamic value, {bool isTotal = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 6),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             label,
  //             style: TextStyle(
  //               fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         Text(
  //           value is num ? value.toStringAsFixed(2) : value.toString(),
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             fontSize: isTotal ? 16 : 14,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
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
}
