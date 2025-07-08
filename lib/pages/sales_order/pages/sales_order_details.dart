// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/sales_order/models/sales_order.dart';
// import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../models/sales_order_detail.dart';

// class SalesOrderDetailPage extends StatefulWidget {
//   final SalesOrder salesOrder;
//   const SalesOrderDetailPage({required this.salesOrder, super.key});

//   @override
//   State<SalesOrderDetailPage> createState() => _SalesOrderDetailPageState();
// }

// class _SalesOrderDetailPageState extends State<SalesOrderDetailPage> {
//   SalesOrderDetail? detail;
//   String? error;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       final service = SalesOrderService();
//       final result = await service.fetchSalesOrderDetails(widget.salesOrder);
//       if (!mounted) return;
//       setState(() {
//         detail = result;
//         loading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = 'Error: $e';
//         loading = false;
//       });
//     }
//   }

//   // Calculate total tax amount from rate structure details
//   double _calculateTotalTaxAmount() {
//     if (detail?.rateStructureDetails == null) return 0;

//     double totalTax = 0;
//     for (var rateDetail in detail!.rateStructureDetails) {
//       // Only include tax types (M, N, I) - CGST, SGST, IGST, etc.
//       if (rateDetail['taxType'] == 'M' ||
//           rateDetail['taxType'] == 'N' ||
//           rateDetail['taxType'] == 'I') {
//         totalTax += (rateDetail['rateAmount'] ?? 0).toDouble();
//       }
//     }
//     return totalTax;
//   }

//   // Calculate basic amount (sum of all item amounts)
//   double _calculateBasicAmount() {
//     if (detail?.modelDetails == null) return 0;

//     double basicAmount = 0;
//     for (var item in detail!.modelDetails) {
//       final qty = (item['qtyIUOM'] ?? 0).toDouble();
//       final rate = (item['basicPriceIUOM'] ?? 0).toDouble();
//       basicAmount += qty * rate;
//     }
//     return basicAmount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (loading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Sales Order Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Sales Order Details')),
//         body: RefreshIndicator(
//           onRefresh: _fetchDetail,
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.8,
//               child: Center(child: Text(error!)),
//             ),
//           ),
//         ),
//       );
//     }

//     if (detail == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Sales Order Details')),
//         body: RefreshIndicator(
//           onRefresh: _fetchDetail,
//           child: const SingleChildScrollView(
//             physics: AlwaysScrollableScrollPhysics(),
//             child: Center(child: Text('No data found.')),
//           ),
//         ),
//       );
//     }

//     final so = detail!.salesOrderDetails;
//     final items = detail!.modelDetails;

//     return Scaffold(
//       appBar: AppBar(title: const Text('Sales Order Details')),
//       body: RefreshIndicator(
//         onRefresh: _fetchDetail,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//               side: BorderSide(color: theme.dividerColor, width: 1.5),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Section 1: Sales Order Reference
//                   Text(
//                     'Sales Order - ${so['ioNumber'] ?? ''}',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   const SizedBox(height: 16),
//                   const Divider(thickness: 1.2),
//                   const SizedBox(height: 16),

//                   // Section 2: Order From and Bill To
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _infoTile(
//                           'Order From',
//                           so['customerName'] ?? '-',
//                         ),
//                       ),
//                       Expanded(
//                         child: _infoTile('Bill To', so['billToName'] ?? '-'),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Section 3: Date and Customer PO Number
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _infoTile(
//                           'Date',
//                           FormatUtils.formatDateForUser(
//                             DateTime.parse(so['ioDate']),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: _infoTile(
//                           'Customer PO Number',
//                           so['customerPONumber'] ?? '-',
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Section 4: Items
//                   const SizedBox(height: 24),
//                   Text(
//                     'Items',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...items.map((item) => _itemCard(context, item)),

//                   // Section 5: Amount Summary
//                   const SizedBox(height: 24),
//                   Text(
//                     'Amount Summary',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _amountRow('Basic Amount', _calculateBasicAmount()),
//                   _amountRow('Tax Amount', _calculateTotalTaxAmount()),
//                   const Divider(thickness: 1),
//                   _amountRow(
//                     'Total Amount',
//                     so['totalAmounttAfterTaxDomesticCurrency'] ?? 0,
//                     isTotal: true,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _infoTile(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//         const SizedBox(height: 4),
//         Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
//       ],
//     );
//   }

//   Widget _itemCard(BuildContext context, Map<String, dynamic> item) {
//     final theme = Theme.of(context);

//     // Calculate item amount (quantity * rate)
//     final qty = (item['qtyIUOM'] ?? 0).toDouble();
//     final rate = (item['basicPriceIUOM'] ?? 0).toDouble();
//     final amount = qty * rate;
//     final discount = (item['discountAmt'] ?? 0).toDouble();

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       elevation: 0,
//       color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.1),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Item code and name
//             Text(
//               '${item['salesItemCode'] ?? '-'} / ${item['salesItemDesc'] ?? '-'}',
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 12),

//             // Quantity, Rate, Amount
//             Row(
//               children: [
//                 Expanded(
//                   child: _itemDetailTile(
//                     'Quantity',
//                     '${qty.toStringAsFixed(0)} ${item['uom'] ?? ''}',
//                   ),
//                 ),
//                 Expanded(
//                   child: _itemDetailTile('Rate', rate.toStringAsFixed(2)),
//                 ),
//                 Expanded(
//                   child: _itemDetailTile('Amount', amount.toStringAsFixed(2)),
//                 ),
//               ],
//             ),

//             // Discount if applicable
//             if (discount > 0) ...[
//               const SizedBox(height: 8),
//               _itemDetailTile('Discount', discount.toStringAsFixed(2)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _itemDetailTile(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _amountRow(String label, dynamic value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             value is num ? value.toStringAsFixed(2) : value.toString(),
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: isTotal ? 16 : 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/sales_order/models/sales_order.dart';
import 'package:nhapp/pages/sales_order/service/sales_order_service.dart';
import 'package:nhapp/utils/format_utils.dart';
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
  String? error;
  bool loading = true;

  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
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

  Future<void> _handleLocation() async {
    if (detail?.salesOrderDetails == null) return;

    final so = detail!.salesOrderDetails;
    final address = so['fullAddress'] ?? '';
    final cityName = so['cityName'] ?? '';
    final pinCode = so['pinCode'] ?? '';

    if (address.isEmpty && cityName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No address information available')),
      );
      return;
    }

    final fullAddress = '$address, $cityName $pinCode'.trim();
    final encodedAddress = Uri.encodeComponent(fullAddress);
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

  // Calculate total tax amount from rate structure details
  double _calculateTotalTaxAmount() {
    if (detail?.rateStructureDetails == null) return 0;

    double totalTax = 0;
    for (var rateDetail in detail!.rateStructureDetails) {
      // Only include tax types (M, N, I) - CGST, SGST, IGST, etc.
      if (rateDetail['taxType'] == 'M' ||
          rateDetail['taxType'] == 'N' ||
          rateDetail['taxType'] == 'I') {
        totalTax += (rateDetail['rateAmount'] ?? 0).toDouble();
      }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Order Details'),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: _viewPdf,
            tooltip: 'View PDF',
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
            onPressed: _isSharing ? null : _handleShare,
            tooltip: 'Share PDF',
          ),
          // IconButton(
          //   icon: const Icon(Icons.location_on),
          //   onPressed: _handleLocation,
          //   tooltip: 'View Location',
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
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
                        child: _infoTile('Bill To', so['billToName'] ?? '-'),
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
}
