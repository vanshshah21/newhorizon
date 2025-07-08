// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
// import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
// import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
// import 'package:nhapp/pages/proforma_invoice/pages/proforma_invoice_pdf_loader_page.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class ProformaInvoiceDetailsPage extends StatefulWidget {
//   final ProformaInvoice invoice;

//   const ProformaInvoiceDetailsPage({required this.invoice, super.key});

//   @override
//   State<ProformaInvoiceDetailsPage> createState() =>
//       _ProformaInvoiceDetailsPageState();
// }

// class _ProformaInvoiceDetailsPageState
//     extends State<ProformaInvoiceDetailsPage> {
//   ProformaInvoiceDetails? details;
//   final ProformaInvoiceService service = ProformaInvoiceService();
//   String? error;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//   }

//   Future<void> _fetchDetails() async {
//     try {
//       final d = await service.fetchProformaInvoiceDetails(
//         invSiteId: widget.invoice.siteId,
//         invYear: widget.invoice.year,
//         invGroup: widget.invoice.groupCode,
//         invNumber: widget.invoice.number,
//         piOn: widget.invoice.piOn,
//         fromLocationId: widget.invoice.fromLocationId,
//         custCode: widget.invoice.custCode,
//       );
//       if (!mounted) return;
//       setState(() {
//         details = d;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   void _viewPdf() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => ProformaInvoicePdfLoaderPage(
//               invoice: widget.invoice,
//               service: service,
//             ),
//       ),
//     );
//   }

//   Future<void> _downloadPdf() async {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Preparing PDF for download...')),
//       );

//       final pdfUrl = await service.fetchProformaInvoicePdfUrl(widget.invoice);

//       if (!mounted) return;

//       if (pdfUrl.isEmpty) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('PDF not available')));
//         return;
//       }

//       final uri = Uri.parse(pdfUrl);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('PDF download started')));
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Cannot open PDF URL')));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surfaceContainerLowest,
//       appBar: AppBar(
//         title: const Text('Proforma Details'),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.picture_as_pdf),
//             onPressed: _viewPdf,
//             tooltip: 'View PDF',
//           ),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: _downloadPdf,
//             tooltip: 'Download PDF',
//           ),
//         ],
//       ),
//       body: _buildBody(context),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     if (isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading details...'),
//           ],
//         ),
//       );
//     }

//     if (error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
//             const SizedBox(height: 16),
//             Text(
//               'Error loading details',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 error!,
//                 textAlign: TextAlign.center,
//                 style: Theme.of(
//                   context,
//                 ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() {
//                   isLoading = true;
//                   error = null;
//                 });
//                 _fetchDetails();
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (details == null) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.description_outlined, size: 64, color: Colors.grey),
//             SizedBox(height: 16),
//             Text('No details found'),
//           ],
//         ),
//       );
//     }

//     final header = details!.headerDetail;
//     final salesOrder = details!.salesOrderDetail ?? {};
//     final items = (details!.gridDetail['itemDetail'] as List?) ?? [];

//     return RefreshIndicator(
//       onRefresh: _fetchDetails,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeaderCard(context, header, salesOrder),
//             const SizedBox(height: 16),
//             // Only show items section if there are items
//             if (items.isNotEmpty) ...[
//               _buildItemsSection(context, items),
//               const SizedBox(height: 16),
//             ],
//             _buildSummaryCard(context, header, items),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderCard(
//     BuildContext context,
//     Map<String, dynamic> header,
//     Map<String, dynamic> salesOrder,
//   ) {
//     final theme = Theme.of(context);

//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Number
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Number',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: theme.colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                       ),
//                       Text(
//                         header['invNumber']?.toString() ?? 'N/A',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Customer Name
//             _buildDetailRow(
//               'Customer Name',
//               header['customerName']?.toString() ?? 'N/A',
//               Icons.business,
//             ),
//             const SizedBox(height: 12),

//             // Select Preference (using currency code as preference)
//             _buildDetailRow(
//               'Select Preference',
//               header['invCurrCode']?.toString() ??
//                   salesOrder['currCode']?.toString() ??
//                   'N/A',
//               Icons.tune,
//             ),
//             const SizedBox(height: 12),

//             // Quotation Number (using SO number if available)
//             _buildDetailRow(
//               'Quotation Number',
//               salesOrder['soNumber']?.toString().isNotEmpty == true
//                   ? salesOrder['soNumber'].toString()
//                   : 'N/A',
//               Icons.description,
//             ),
//             const SizedBox(height: 12),

//             // Customer PO Number
//             _buildDetailRow(
//               'Customer PO Number',
//               header['customerPoNumber']?.toString().isNotEmpty == true
//                   ? header['customerPoNumber'].toString()
//                   : salesOrder['poCustomerNumber']?.toString() ?? 'N/A',
//               Icons.receipt_long,
//             ),
//             const SizedBox(height: 12),

//             // Date
//             _buildDetailRow(
//               'Date',
//               _formatDate(header['invIssueDate']?.toString()),
//               Icons.calendar_today,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, IconData icon) {
//     final theme = Theme.of(context);
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 16, color: theme.colorScheme.primary),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.7),
//                 ),
//               ),
//               Text(
//                 value,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemsSection(BuildContext context, List items) {
//     final theme = Theme.of(context);

//     return Card(
//       elevation: 2,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.inventory_2_outlined,
//                   color: theme.colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Items (${items.length})',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           ...items.asMap().entries.map((entry) {
//             final index = entry.key;
//             final item = entry.value;
//             return _buildItemCard(context, item, index);
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemCard(
//     BuildContext context,
//     Map<String, dynamic> item,
//     int index,
//   ) {
//     final theme = Theme.of(context);
//     final qty =
//         double.tryParse(
//           item['invoiceQty']?.toString() ?? item['qty']?.toString() ?? '0',
//         ) ??
//         0.0;
//     final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0.0;
//     final amount = qty * rate;
//     final discountedRate = amount - (item['totalDiscountedBasic'] ?? 0.0);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Item Code/Name header
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${index + 1}',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item['itemCode']?.toString() ?? 'N/A',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       item['itemName']?.toString() ?? 'N/A',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Item details grid
//           Row(
//             children: [
//               Expanded(
//                 child: _buildItemDetail(
//                   'Quantity',
//                   '$qty ${item['suom'] ?? ''}',
//                 ),
//               ),
//               Expanded(
//                 child: _buildItemDetail('Rate', FormatUtils.formatAmount(rate)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           Row(
//             children: [
//               Expanded(
//                 child: _buildItemDetail(
//                   'Amount',
//                   FormatUtils.formatAmount(amount),
//                 ),
//               ),
//               Expanded(
//                 child: _buildItemDetail(
//                   'Discount',
//                   FormatUtils.formatAmount(discountedRate),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemDetail(String label, String value) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//           ),
//         ),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard(
//     BuildContext context,
//     Map<String, dynamic> header,
//     List items,
//   ) {
//     final theme = Theme.of(context);

//     // Get amounts from header based on API response structure
//     double basicAmount =
//         double.tryParse(header['invBacAmount']?.toString() ?? '0') ?? 0.0;
//     double discountValue =
//         double.tryParse(header['invDiscountValue']?.toString() ?? '0') ?? 0.0;
//     double discountedAmount = basicAmount - discountValue;
//     double taxAmount =
//         double.tryParse(header['invTax']?.toString() ?? '0') ?? 0.0;
//     double totalAmount =
//         double.tryParse(header['invAmount']?.toString() ?? '0') ?? 0.0;

//     // If total amount is not available, calculate from items
//     if (totalAmount == 0.0 && items.isNotEmpty) {
//       for (var item in items) {
//         totalAmount =
//             double.tryParse(item['totalValue']?.toString() ?? '0') ?? 0.0;
//       }
//     }

//     // If basic amount is not available from header, calculate from items
//     if (basicAmount == 0.0 && items.isNotEmpty) {
//       for (var item in items) {
//         basicAmount +=
//             double.tryParse(item['totalBasicValue']?.toString() ?? '0') ?? 0.0;
//       }
//     }

//     return Card(
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.calculate_outlined,
//                   color: theme.colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Amount Summary',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             _buildSummaryRow(
//               'Basic Amount',
//               FormatUtils.formatAmount(basicAmount),
//             ),
//             const SizedBox(height: 8),

//             _buildSummaryRow(
//               'Discounted Amount',
//               FormatUtils.formatAmount(discountedAmount),
//             ),
//             const SizedBox(height: 8),

//             _buildSummaryRow('Tax Amount', FormatUtils.formatAmount(taxAmount)),

//             const Divider(height: 24),

//             _buildSummaryRow(
//               'Total Amount',
//               FormatUtils.formatAmount(totalAmount),
//               isTotal: true,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
//     final theme = Theme.of(context);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style:
//               isTotal
//                   ? theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   )
//                   : theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//         ),
//         Text(
//           value,
//           style:
//               isTotal
//                   ? theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   )
//                   : theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//         ),
//       ],
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'N/A';
//     try {
//       final date = DateTime.parse(dateString);
//       return FormatUtils.formatDateForUser(date);
//     } catch (e) {
//       return dateString.split('T').first;
//     }
//   }
// }

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:external_path/external_path.dart';
// import 'package:open_file/open_file.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
// import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
// import 'package:nhapp/pages/proforma_invoice/service/proforma_invoice_service.dart';
// import 'package:nhapp/pages/proforma_invoice/pages/proforma_invoice_pdf_loader_page.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class ProformaInvoiceDetailsPage extends StatefulWidget {
//   final ProformaInvoice invoice;

//   const ProformaInvoiceDetailsPage({required this.invoice, super.key});

//   @override
//   State<ProformaInvoiceDetailsPage> createState() =>
//       _ProformaInvoiceDetailsPageState();
// }

// class _ProformaInvoiceDetailsPageState
//     extends State<ProformaInvoiceDetailsPage> {
//   ProformaInvoiceDetails? details;
//   final ProformaInvoiceService service = ProformaInvoiceService();
//   String? error;
//   bool isLoading = true;

//   bool _isDownloading = false;
//   bool _isSharing = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//   }

//   Future<void> _fetchDetails() async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//     try {
//       final d = await service.fetchProformaInvoiceDetails(
//         invSiteId: widget.invoice.siteId,
//         invYear: widget.invoice.year,
//         invGroup: widget.invoice.groupCode,
//         invNumber: widget.invoice.number,
//         piOn: widget.invoice.piOn,
//         fromLocationId: widget.invoice.fromLocationId,
//         custCode: widget.invoice.custCode,
//       );
//       if (!mounted) return;
//       setState(() {
//         details = d;
//         isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         error = e.toString();
//         isLoading = false;
//       });
//     }
//   }

//   void _viewPdf() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => ProformaInvoicePdfLoaderPage(
//               invoice: widget.invoice,
//               service: service,
//             ),
//       ),
//     );
//   }

//   /* ---------- Permission helper ---------- */

//   Future<bool> _ensureStoragePermission() async {
//     if (!Platform.isAndroid) return true;

//     try {
//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;
//       final sdkInt = androidInfo.version.sdkInt;

//       Permission permission;
//       if (sdkInt >= 30) {
//         permission = Permission.manageExternalStorage;
//       } else {
//         permission = Permission.storage;
//       }

//       var status = await permission.status;

//       if (status.isGranted) return true;

//       if (status.isDenied) {
//         final shouldRequest = await _showPermissionDialog(
//           title: 'Storage Permission Required',
//           message:
//               'This app needs storage permission to download PDF files to your device. '
//               'Please allow storage access in the next dialog.',
//         );

//         if (!shouldRequest) return false;

//         status = await permission.request();
//         return status.isGranted;
//       }

//       if (status.isPermanentlyDenied) {
//         final openSettings = await _showPermissionDialog(
//           title: 'Permission Permanently Denied',
//           message:
//               'Storage permission has been permanently denied. '
//               'Please go to Settings > Apps > [Your App] > Permissions and enable Storage access.',
//           showSettingsButton: true,
//         );

//         if (openSettings) {
//           await openAppSettings();
//           return await permission.isGranted;
//         }
//         return false;
//       }

//       return false;
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error checking permissions: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//       return false;
//     }
//   }

//   Future<bool> _showPermissionDialog({
//     required String title,
//     required String message,
//     bool showSettingsButton = false,
//   }) async {
//     return await showDialog<bool>(
//           context: context,
//           barrierDismissible: false,
//           builder:
//               (context) => AlertDialog(
//                 title: Text(title),
//                 content: Text(message),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: Text(showSettingsButton ? 'Open Settings' : 'Allow'),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }

//   /* ---------- Path helpers ---------- */

//   Future<String> _cacheDir() async => (await getTemporaryDirectory()).path;

//   Future<String> _downloadsDir() async {
//     if (Platform.isAndroid) {
//       return await ExternalPath.getExternalStoragePublicDirectory(
//         ExternalPath.DIRECTORY_DOWNLOAD,
//       );
//     }
//     return (await getApplicationDocumentsDirectory()).path;
//   }

//   /* ---------- Downloader ---------- */

//   Future<String?> _downloadPdfFile({required bool toCache}) async {
//     final pdfUrl = await service.fetchProformaInvoicePdfUrl(widget.invoice);

//     if (pdfUrl.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('PDF not available')));
//       }
//       return null;
//     }

//     if (!toCache && !(await _ensureStoragePermission())) return null;

//     final dir = toCache ? await _cacheDir() : await _downloadsDir();
//     final name =
//         'ProformaInvoice_${widget.invoice.number}_${DateTime.now().millisecondsSinceEpoch}.pdf';
//     final path = '$dir/$name';

//     final file = File(path);
//     if (await file.exists()) return path;

//     try {
//       await Dio().download(pdfUrl, path);
//       return path;
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
//       }
//       return null;
//     }
//   }

//   /* ---------- Download ---------- */

//   Future<void> _handleDownload() async {
//     if (_isDownloading) return;
//     setState(() => _isDownloading = true);

//     try {
//       final path = await _downloadPdfFile(toCache: false);
//       if (path == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Download cancelled or permission denied'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//         return;
//       }

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'PDF saved to ${Platform.isAndroid ? "Downloads" : "Documents"} folder',
//           ),
//           action: SnackBarAction(
//             label: 'Open',
//             onPressed: () => OpenFile.open(path),
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isDownloading = false);
//     }
//   }

//   /* ---------- Share ---------- */

//   Future<void> _handleShare() async {
//     if (_isSharing) return;
//     setState(() => _isSharing = true);

//     try {
//       final path = await _downloadPdfFile(toCache: true);
//       if (path == null) throw Exception('Unable to prepare PDF');

//       await Share.shareXFiles(
//         [XFile(path, name: 'ProformaInvoice_${widget.invoice.number}.pdf')],
//         text: 'Proforma Invoice ${widget.invoice.number} PDF',
//         subject: 'Proforma Invoice ${widget.invoice.number} PDF',
//       );
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isSharing = false);
//     }
//   }

//   /* ---------- Location ---------- */

//   Future<void> _handleLocation() async {
//     if (details?.headerDetail == null) return;

//     final header = details!.headerDetail;
//     final customerName = header['customerName'] ?? '';

//     if (customerName.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No customer information available')),
//       );
//       return;
//     }

//     final encodedAddress = Uri.encodeComponent(customerName);
//     final mapUrl =
//         'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

//     try {
//       final uri = Uri.parse(mapUrl);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Cannot open maps application')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
//       }
//     }
//   }

//   // Calculate tax amount from rate structure details
//   double _calculateTotalTaxAmount() {
//     if (details?.gridDetail == null) return 0;

//     final gridDetail = details!.gridDetail;
//     final rateStructDetail = gridDetail['rateStructDetail'] as List? ?? [];

//     double totalTax = 0;
//     for (var rateDetail in rateStructDetail) {
//       // Only include tax types (M, N, I) - CGST, SGST, IGST, etc.
//       if (rateDetail['taxType'] == 'M' ||
//           rateDetail['taxType'] == 'N' ||
//           rateDetail['taxType'] == 'I') {
//         final rateAmount =
//             double.tryParse(rateDetail['rateAmount']?.toString() ?? '0') ?? 0;
//         totalTax += rateAmount;
//       }
//     }

//     // If no tax from rate structure, use header tax
//     if (totalTax == 0) {
//       totalTax =
//           double.tryParse(details!.headerDetail['invTax']?.toString() ?? '0') ??
//           0;
//     }

//     return totalTax;
//   }

//   // Calculate basic amount from items
//   double _calculateBasicAmount() {
//     if (details?.gridDetail == null) return 0;

//     final items = details!.gridDetail['itemDetail'] as List? ?? [];
//     double basicAmount = 0;

//     for (var item in items) {
//       final qty = double.tryParse(item['invoiceQty']?.toString() ?? '0') ?? 0;
//       final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0;
//       basicAmount += qty * rate;
//     }

//     // If no items, use header basic amount
//     if (basicAmount == 0) {
//       basicAmount =
//           double.tryParse(
//             details!.headerDetail['invBacAmount']?.toString() ?? '0',
//           ) ??
//           0;
//     }

//     return basicAmount;
//   }

//   // Calculate discount amount
//   double _calculateDiscountAmount() {
//     if (details?.gridDetail == null) return 0;

//     final items = details!.gridDetail['itemDetail'] as List? ?? [];
//     double discountAmount = 0;

//     for (var item in items) {
//       discountAmount +=
//           double.tryParse(item['totalDiscountedBasic']?.toString() ?? '0') ?? 0;
//     }

//     // If no discount from items, use header discount
//     if (discountAmount == 0) {
//       discountAmount =
//           double.tryParse(
//             details!.headerDetail['invDiscountValue']?.toString() ?? '0',
//           ) ??
//           0;
//     }

//     return discountAmount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surfaceContainerLowest,
//       appBar: AppBar(
//         title: const Text('Proforma Details'),
//         elevation: 0,
//         backgroundColor: theme.colorScheme.surface,
//         actions: [
//           IconButton(
//             icon:
//                 _isDownloading
//                     ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                     : const Icon(Icons.download),
//             onPressed: _isDownloading ? null : _handleDownload,
//             tooltip: 'Download PDF',
//           ),
//           IconButton(
//             icon: const Icon(Icons.picture_as_pdf_outlined),
//             onPressed: _viewPdf,
//             tooltip: 'View PDF',
//           ),
//           IconButton(
//             icon:
//                 _isSharing
//                     ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                     : const Icon(Icons.share),
//             onPressed: _isSharing ? null : _handleShare,
//             tooltip: 'Share PDF',
//           ),
//           IconButton(
//             icon: const Icon(Icons.location_on),
//             onPressed: _handleLocation,
//             tooltip: 'View Location',
//           ),
//         ],
//       ),
//       body: _buildBody(context),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     if (isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Loading details...'),
//           ],
//         ),
//       );
//     }

//     if (error != null) {
//       return RefreshIndicator(
//         onRefresh: _fetchDetails,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.red.shade300,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading details',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   ),
//                   const SizedBox(height: 8),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32),
//                     child: Text(
//                       error!,
//                       textAlign: TextAlign.center,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: Colors.red.shade700,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: _fetchDetails,
//                     icon: const Icon(Icons.refresh),
//                     label: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     if (details == null) {
//       return RefreshIndicator(
//         onRefresh: _fetchDetails,
//         child: const SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.description_outlined, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text('No details found'),
//               ],
//             ),
//           ),
//         ),
//       );
//     }

//     final header = details!.headerDetail;
//     final salesOrder = details!.salesOrderDetail;
//     final items = (details!.gridDetail['itemDetail'] as List?) ?? [];

//     return RefreshIndicator(
//       onRefresh: _fetchDetails,
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: BorderSide(color: Theme.of(context).dividerColor, width: 1.5),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Section 1: Proforma Invoice Reference
//                 Text(
//                   'Proforma Invoice - ${header['invNumber'] ?? ''}',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 16),
//                 const Divider(thickness: 1.2),
//                 const SizedBox(height: 16),

//                 // Section 2: Customer and Currency Info
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _infoTile(
//                         'Customer Name',
//                         header['customerName'] ?? '-',
//                       ),
//                     ),
//                     Expanded(
//                       child: _infoTile(
//                         'Currency',
//                         header['invCurrCode'] ?? salesOrder['currCode'] ?? '-',
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Section 3: Date and Customer PO Number
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _infoTile(
//                         'Date',
//                         header['invIssueDate'] != null
//                             ? FormatUtils.formatDateForUser(
//                               DateTime.parse(header['invIssueDate']),
//                             )
//                             : '-',
//                       ),
//                     ),
//                     Expanded(
//                       child: _infoTile(
//                         'Customer PO Number',
//                         header['customerPoNumber']?.toString().isNotEmpty ==
//                                 true
//                             ? header['customerPoNumber'].toString()
//                             : salesOrder['poCustomerNumber']?.toString() ?? '-',
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Section 4: Items
//                 if (items.isNotEmpty) ...[
//                   const SizedBox(height: 24),
//                   Text(
//                     'Items',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...items.map((item) => _itemCard(context, item)),
//                 ],

//                 // Section 5: Amount Summary
//                 const SizedBox(height: 24),
//                 Text(
//                   'Amount Summary',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _amountRow('Basic Amount', _calculateBasicAmount()),
//                 _amountRow('Discount Amount', _calculateDiscountAmount()),
//                 _amountRow('Tax Amount', _calculateTotalTaxAmount()),
//                 const Divider(thickness: 1),
//                 _amountRow(
//                   'Total Amount',
//                   double.tryParse(header['invAmount']?.toString() ?? '0') ?? 0,
//                   isTotal: true,
//                 ),
//               ],
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

//     // Calculate item amount
//     final qty = double.tryParse(item['invoiceQty']?.toString() ?? '0') ?? 0;
//     final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0;
//     final amount = qty * rate;
//     final discount =
//         double.tryParse(item['totalDiscountedBasic']?.toString() ?? '0') ?? 0;

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
//               '${item['itemCode'] ?? '-'} / ${item['itemName'] ?? '-'}',
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
//                     '${qty.toStringAsFixed(0)} ${item['suom'] ?? ''}',
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

  @override
  void initState() {
    super.initState();
    _fetchDetails();
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

  // Calculate tax amount from rate structure details
  double _calculateTotalTaxAmount() {
    if (details?.gridDetail == null) return 0;

    final gridDetail = details!.gridDetail;
    final rateStructDetail = gridDetail['rateStructDetail'] as List? ?? [];

    double totalTax = 0;
    for (var rateDetail in rateStructDetail) {
      // Only include tax types (M, N, I) - CGST, SGST, IGST, etc.
      if (rateDetail['taxType'] == 'M' ||
          rateDetail['taxType'] == 'N' ||
          rateDetail['taxType'] == 'I') {
        final rateAmount =
            double.tryParse(rateDetail['rateAmount']?.toString() ?? '0') ?? 0;
        totalTax += rateAmount;
      }
    }

    // If no tax from rate structure, use header tax
    if (totalTax == 0) {
      totalTax =
          double.tryParse(details!.headerDetail['invTax']?.toString() ?? '0') ??
          0;
    }

    return totalTax;
  }

  // Calculate basic amount from items
  double _calculateBasicAmount() {
    if (details?.gridDetail == null) return 0;

    final items = details!.gridDetail['itemDetail'] as List? ?? [];
    double basicAmount = 0;

    for (var item in items) {
      final qty = double.tryParse(item['invoiceQty']?.toString() ?? '0') ?? 0;
      final rate = double.tryParse(item['itemRate']?.toString() ?? '0') ?? 0;
      basicAmount += qty * rate;
    }

    // If no items, use header basic amount
    if (basicAmount == 0) {
      basicAmount =
          double.tryParse(
            details!.headerDetail['invBacAmount']?.toString() ?? '0',
          ) ??
          0;
    }

    return basicAmount;
  }

  // Calculate discount amount
  double _calculateDiscountAmount() {
    if (details?.gridDetail == null) return 0;

    final items = details!.gridDetail['itemDetail'] as List? ?? [];
    double discountAmount = 0;

    for (var item in items) {
      discountAmount +=
          double.tryParse(item['discountAmount']?.toString() ?? '0') ?? 0;
    }

    // If no discount from items, use header discount
    // if (discountAmount == 0) {
    //   discountAmount =
    //       double.tryParse(
    //         details!.headerDetail['invDiscountValue']?.toString() ?? '0',
    //       ) ??
    //       0;
    // }

    return discountAmount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          onRefresh: _fetchDetails,
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
          onRefresh: _fetchDetails,
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
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _handleLocation,
            tooltip: 'View Location',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDetails,
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
                    double.tryParse(
                          header['invAmount']?.toString() ??
                              header['invDiscountValue']?.toString() ??
                              '0',
                        ) ??
                        0,
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
