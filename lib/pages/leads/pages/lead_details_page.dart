// // import 'package:flutter/material.dart';
// // import '../models/lead_data.dart';
// // import '../models/lead_detail_data.dart';
// // import '../services/lead_service.dart';

// // class LeadDetailPage extends StatefulWidget {
// //   final LeadData lead;

// //   const LeadDetailPage({required this.lead, Key? key}) : super(key: key);

// //   @override
// //   State<LeadDetailPage> createState() => _LeadDetailPageState();
// // }

// // class _LeadDetailPageState extends State<LeadDetailPage> {
// //   LeadDetailData? detail;
// //   String? error;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchDetail();
// //   }

// //   Future<void> _fetchDetail() async {
// //     LeadService service = LeadService();
// //     try {
// //       final data = await service.fetchLeadDetails(
// //         customerCode: widget.lead.customerCode,
// //         salesmanCode: widget.lead.salesmanCode,
// //         inquiryYear: widget.lead.inquiryYear,
// //         inquiryGroup: widget.lead.inquiryGroup,
// //         inquirySiteCode: widget.lead.locationCode,
// //         inquiryNumber: widget.lead.inquiryNumber,
// //         inquiryID: widget.lead.inquiryID,
// //       );
// //       if (!mounted) return;
// //       setState(() => detail = data);
// //     } catch (e) {
// //       if (!mounted) return;
// //       setState(() => error = 'Error: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     if (error != null) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Lead Details')),
// //         body: Center(child: Text(error!)),
// //       );
// //     }
// //     if (detail == null) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Lead Details')),
// //         body: const Center(child: CircularProgressIndicator()),
// //       );
// //     }
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Lead Details')),
// //       body: ListView(
// //         padding: const EdgeInsets.all(16),
// //         children: [
// //           Text(
// //             'Inquiry #: ${detail!.inquiryNumber}',
// //             style: Theme.of(context).textTheme.titleLarge,
// //           ),
// //           const SizedBox(height: 8),
// //           Text('Customer: ${detail!.customerFullName}'),
// //           Text('Salesman: ${detail!.salesmanFullName}'),
// //           Text('Region: ${detail!.regionFullName}'),
// //           Text('Consultant: ${detail!.consultantFullName}'),
// //           Text('Date: ${detail!.inquiryDate.split('T').first}'),
// //           Text('Status: ${detail!.inquiryStatus}'),
// //           Text('Remarks: ${detail!.remarks}'),
// //           const Divider(height: 32),
// //           Text('Items:', style: Theme.of(context).textTheme.titleMedium),
// //           ...detail!.inqEntryItemModel.map(
// //             (item) => Card(
// //               margin: const EdgeInsets.symmetric(vertical: 4),
// //               child: ListTile(
// //                 title: Text(item.itemName),
// //                 subtitle: Text(
// //                   'Code: ${item.salesItemCode}\n'
// //                   'Qty: ${item.itemQty}\n'
// //                   'Price: ${item.basicPrice}\n'
// //                   'UOM: ${item.uom}\n'
// //                   'Type: ${item.salesItemType}',
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import '../models/lead_data.dart';
// // import '../models/lead_detail_data.dart';
// // import '../services/lead_service.dart';

// // class InquiryDetailsPage extends StatefulWidget {
// //   final LeadData lead;
// //   const InquiryDetailsPage({required this.lead, super.key});

// //   @override
// //   State<InquiryDetailsPage> createState() => _InquiryDetailsPageState();
// // }

// // class _InquiryDetailsPageState extends State<InquiryDetailsPage> {
// //   LeadDetailData? data;
// //   String? error;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchDetail();
// //   }

// //   Future<void> _fetchDetail() async {
// //     LeadService service = LeadService();
// //     try {
// //       final detail = await service.fetchLeadDetails(
// //         customerCode: widget.lead.customerCode,
// //         salesmanCode: widget.lead.salesmanCode,
// //         inquiryYear: widget.lead.inquiryYear,
// //         inquiryGroup: widget.lead.inquiryGroup,
// //         inquirySiteCode: widget.lead.locationCode,
// //         inquiryNumber: widget.lead.inquiryNumber,
// //         inquiryID: widget.lead.inquiryID,
// //       );
// //       if (!mounted) return;
// //       setState(() => data = detail);
// //     } catch (e) {
// //       if (!mounted) return;
// //       setState(() => error = 'Error: $e');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);

// //     if (error != null) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Inquiry Details')),
// //         body: Center(child: Text(error!)),
// //       );
// //     }
// //     if (data == null) {
// //       return Scaffold(
// //         appBar: AppBar(title: const Text('Inquiry Details')),
// //         body: const Center(child: CircularProgressIndicator()),
// //       );
// //     }

// //     final isDark = theme.brightness == Brightness.dark;
// //     final cardColor = theme.cardColor;
// //     final borderColor = theme.dividerColor;

// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       appBar: AppBar(title: const Text('Inquiry Details')),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
// //         child: Center(
// //           child: ConstrainedBox(
// //             constraints: const BoxConstraints(maxWidth: 800),
// //             child: Card(
// //               color: cardColor,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(24),
// //                 side: BorderSide(color: borderColor, width: 2),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.stretch,
// //                 children: [
// //                   // CardHeader
// //                   Container(
// //                     padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
// //                     decoration: BoxDecoration(
// //                       border: Border(
// //                         bottom: BorderSide(color: borderColor, width: 1),
// //                       ),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           "Inquiry Details",
// //                           style: theme.textTheme.titleLarge?.copyWith(
// //                             fontWeight: FontWeight.w600,
// //                             fontSize: 24,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           "View inquiry details for reference.",
// //                           style: theme.textTheme.bodySmall?.copyWith(
// //                             color: isDark ? Colors.grey[400] : Colors.grey[700],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   // CardContent (Main Details)
// //                   Padding(
// //                     padding: const EdgeInsets.all(24),
// //                     child: LayoutBuilder(
// //                       builder: (context, constraints) {
// //                         final isWide = constraints.maxWidth > 600;
// //                         if (isWide) {
// //                           return Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     _DetailField(
// //                                       label: "Inquiry ID",
// //                                       child: _ReadOnlyInput(
// //                                         value: data!.inquiryID.toString(),
// //                                       ),
// //                                     ),
// //                                     _DetailField(
// //                                       label: "Customer",
// //                                       child: Text(
// //                                         "${data!.customerCode} - ${data!.customerName}",
// //                                         style: theme.textTheme.bodyMedium
// //                                             ?.copyWith(
// //                                               color:
// //                                                   isDark
// //                                                       ? Colors.grey[300]
// //                                                       : Colors.grey[800],
// //                                             ),
// //                                       ),
// //                                     ),
// //                                     _DetailField(
// //                                       label: "Sales Team",
// //                                       child: Text(
// //                                         "${data!.salesmanName} (${data!.salesmanCode})",
// //                                         style: theme.textTheme.bodyMedium
// //                                             ?.copyWith(
// //                                               color:
// //                                                   isDark
// //                                                       ? Colors.grey[300]
// //                                                       : Colors.grey[800],
// //                                             ),
// //                                       ),
// //                                     ),
// //                                     _DetailField(
// //                                       label: "Region",
// //                                       child: _ReadOnlyInput(
// //                                         value: data!.salesRegionCodeDesc,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 32),
// //                               Expanded(
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     _DetailField(
// //                                       label: "Inquiry Date",
// //                                       child: _ReadOnlyInput(
// //                                         value: DateFormat.yMd().format(
// //                                           DateTime.parse(data!.inquiryDate),
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     _DetailField(
// //                                       label: "Consultant",
// //                                       child: Text(
// //                                         data!.consultantFullName,
// //                                         style: theme.textTheme.bodyMedium
// //                                             ?.copyWith(
// //                                               color:
// //                                                   isDark
// //                                                       ? Colors.grey[300]
// //                                                       : Colors.grey[800],
// //                                             ),
// //                                       ),
// //                                     ),
// //                                     _DetailField(
// //                                       label: "Inquiry Number",
// //                                       child: _ReadOnlyInput(
// //                                         value: data!.inquiryNumber,
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         } else {
// //                           return Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               _DetailField(
// //                                 label: "Inquiry ID",
// //                                 child: _ReadOnlyInput(
// //                                   value: data!.inquiryID.toString(),
// //                                 ),
// //                               ),
// //                               _DetailField(
// //                                 label: "Customer",
// //                                 child: Text(
// //                                   "${data!.customerCode} - ${data!.customerName}",
// //                                   style: theme.textTheme.bodyMedium?.copyWith(
// //                                     color:
// //                                         isDark
// //                                             ? Colors.grey[300]
// //                                             : Colors.grey[800],
// //                                   ),
// //                                 ),
// //                               ),
// //                               _DetailField(
// //                                 label: "Sales Team",
// //                                 child: Text(
// //                                   "${data!.salesmanName} (${data!.salesmanCode})",
// //                                   style: theme.textTheme.bodyMedium?.copyWith(
// //                                     color:
// //                                         isDark
// //                                             ? Colors.grey[300]
// //                                             : Colors.grey[800],
// //                                   ),
// //                                 ),
// //                               ),
// //                               _DetailField(
// //                                 label: "Region",
// //                                 child: _ReadOnlyInput(
// //                                   value: data!.salesRegionCodeDesc,
// //                                 ),
// //                               ),
// //                               const SizedBox(height: 24),
// //                               _DetailField(
// //                                 label: "Inquiry Date",
// //                                 child: _ReadOnlyInput(
// //                                   value: DateFormat.yMd().format(
// //                                     DateTime.parse(data!.inquiryDate),
// //                                   ),
// //                                 ),
// //                               ),
// //                               _DetailField(
// //                                 label: "Consultant",
// //                                 child: Text(
// //                                   data!.consultantFullName,
// //                                   style: theme.textTheme.bodyMedium?.copyWith(
// //                                     color:
// //                                         isDark
// //                                             ? Colors.grey[300]
// //                                             : Colors.grey[800],
// //                                   ),
// //                                 ),
// //                               ),
// //                               _DetailField(
// //                                 label: "Inquiry Number",
// //                                 child: _ReadOnlyInput(
// //                                   value: data!.inquiryNumber,
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                   // CardHeader for Items
// //                   Container(
// //                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
// //                     decoration: BoxDecoration(
// //                       border: Border(
// //                         bottom: BorderSide(color: borderColor, width: 1),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       "Items",
// //                       style: theme.textTheme.titleMedium?.copyWith(
// //                         fontWeight: FontWeight.w500,
// //                         fontSize: 18,
// //                       ),
// //                     ),
// //                   ),
// //                   // CardContent (Table)
// //                   Padding(
// //                     padding: const EdgeInsets.all(24),
// //                     child: SingleChildScrollView(
// //                       scrollDirection: Axis.horizontal,
// //                       child: DataTable(
// //                         columns: const [
// //                           DataColumn(label: Text("Item Code")),
// //                           DataColumn(label: Text("Quantity")),
// //                           DataColumn(label: Text("UOM")),
// //                           DataColumn(label: Text("Price")),
// //                         ],
// //                         rows:
// //                             data!.inqEntryItemModel
// //                                 .map(
// //                                   (item) => DataRow(
// //                                     cells: [
// //                                       DataCell(Text(item.salesItemCode)),
// //                                       DataCell(Text(item.itemQty.toString())),
// //                                       DataCell(Text(item.uom)),
// //                                       DataCell(Text("₹${item.basicPrice}")),
// //                                     ],
// //                                   ),
// //                                 )
// //                                 .toList(),
// //                         headingRowColor: MaterialStateProperty.all(
// //                           theme.colorScheme.surfaceVariant.withOpacity(0.2),
// //                         ),
// //                         dataRowColor: MaterialStateProperty.all(
// //                           theme.colorScheme.surface,
// //                         ),
// //                         border: TableBorder(
// //                           horizontalInside: BorderSide(
// //                             color: borderColor,
// //                             width: 1,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   // CardFooter
// //                   Padding(
// //                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       children: [
// //                         SizedBox(
// //                           width: 200,
// //                           child: OutlinedButton(
// //                             onPressed: () {
// //                               Navigator.of(context).maybePop();
// //                             },
// //                             child: const Text("Back to List"),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // Helper for detail fields
// // class _DetailField extends StatelessWidget {
// //   final String label;
// //   final Widget child;
// //   const _DetailField({required this.label, required this.child, super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 20),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [Label(label), const SizedBox(height: 6), child],
// //       ),
// //     );
// //   }
// // }

// // // Read-only input style
// // class _ReadOnlyInput extends StatelessWidget {
// //   final String value;
// //   const _ReadOnlyInput({required this.value, super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final isDark = theme.brightness == Brightness.dark;
// //     return TextFormField(
// //       initialValue: value,
// //       readOnly: true,
// //       style: theme.textTheme.bodyMedium,
// //       decoration: InputDecoration(
// //         filled: true,
// //         fillColor: isDark ? theme.inputDecorationTheme.fillColor : Colors.white,
// //         border: InputBorder.none,
// //         enabledBorder: InputBorder.none,
// //         focusedBorder: InputBorder.none,
// //         contentPadding: const EdgeInsets.symmetric(
// //           vertical: 10,
// //           horizontal: 12,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // Label widget for field titles
// // class Label extends StatelessWidget {
// //   final String text;
// //   const Label(this.text, {super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Text(
// //       text,
// //       style: Theme.of(context).textTheme.labelMedium?.copyWith(
// //         color: Theme.of(context).colorScheme.primary,
// //       ),
// //     );
// //   }
// // }

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/pages/leads/pages/lead_pdf_loader_page.dart';
import 'package:nhapp/pages/quotation/pages/add_quotation_page.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  String? error;

  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
