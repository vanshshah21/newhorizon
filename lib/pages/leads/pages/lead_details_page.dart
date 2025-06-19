// import 'package:flutter/material.dart';
// import '../models/lead_data.dart';
// import '../models/lead_detail_data.dart';
// import '../services/lead_service.dart';

// class LeadDetailPage extends StatefulWidget {
//   final LeadData lead;

//   const LeadDetailPage({required this.lead, Key? key}) : super(key: key);

//   @override
//   State<LeadDetailPage> createState() => _LeadDetailPageState();
// }

// class _LeadDetailPageState extends State<LeadDetailPage> {
//   LeadDetailData? detail;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     LeadService service = LeadService();
//     try {
//       final data = await service.fetchLeadDetails(
//         customerCode: widget.lead.customerCode,
//         salesmanCode: widget.lead.salesmanCode,
//         inquiryYear: widget.lead.inquiryYear,
//         inquiryGroup: widget.lead.inquiryGroup,
//         inquirySiteCode: widget.lead.locationCode,
//         inquiryNumber: widget.lead.inquiryNumber,
//         inquiryID: widget.lead.inquiryID,
//       );
//       if (!mounted) return;
//       setState(() => detail = data);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => error = 'Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Lead Details')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (detail == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Lead Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(title: const Text('Lead Details')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           Text(
//             'Inquiry #: ${detail!.inquiryNumber}',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 8),
//           Text('Customer: ${detail!.customerFullName}'),
//           Text('Salesman: ${detail!.salesmanFullName}'),
//           Text('Region: ${detail!.regionFullName}'),
//           Text('Consultant: ${detail!.consultantFullName}'),
//           Text('Date: ${detail!.inquiryDate.split('T').first}'),
//           Text('Status: ${detail!.inquiryStatus}'),
//           Text('Remarks: ${detail!.remarks}'),
//           const Divider(height: 32),
//           Text('Items:', style: Theme.of(context).textTheme.titleMedium),
//           ...detail!.inqEntryItemModel.map(
//             (item) => Card(
//               margin: const EdgeInsets.symmetric(vertical: 4),
//               child: ListTile(
//                 title: Text(item.itemName),
//                 subtitle: Text(
//                   'Code: ${item.salesItemCode}\n'
//                   'Qty: ${item.itemQty}\n'
//                   'Price: ${item.basicPrice}\n'
//                   'UOM: ${item.uom}\n'
//                   'Type: ${item.salesItemType}',
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/lead_data.dart';
// import '../models/lead_detail_data.dart';
// import '../services/lead_service.dart';

// class InquiryDetailsPage extends StatefulWidget {
//   final LeadData lead;
//   const InquiryDetailsPage({required this.lead, super.key});

//   @override
//   State<InquiryDetailsPage> createState() => _InquiryDetailsPageState();
// }

// class _InquiryDetailsPageState extends State<InquiryDetailsPage> {
//   LeadDetailData? data;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetail();
//   }

//   Future<void> _fetchDetail() async {
//     LeadService service = LeadService();
//     try {
//       final detail = await service.fetchLeadDetails(
//         customerCode: widget.lead.customerCode,
//         salesmanCode: widget.lead.salesmanCode,
//         inquiryYear: widget.lead.inquiryYear,
//         inquiryGroup: widget.lead.inquiryGroup,
//         inquirySiteCode: widget.lead.locationCode,
//         inquiryNumber: widget.lead.inquiryNumber,
//         inquiryID: widget.lead.inquiryID,
//       );
//       if (!mounted) return;
//       setState(() => data = detail);
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => error = 'Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Inquiry Details')),
//         body: Center(child: Text(error!)),
//       );
//     }
//     if (data == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Inquiry Details')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final isDark = theme.brightness == Brightness.dark;
//     final cardColor = theme.cardColor;
//     final borderColor = theme.dividerColor;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(title: const Text('Inquiry Details')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 800),
//             child: Card(
//               color: cardColor,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//                 side: BorderSide(color: borderColor, width: 2),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // CardHeader
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: borderColor, width: 1),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Inquiry Details",
//                           style: theme.textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 24,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "View inquiry details for reference.",
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: isDark ? Colors.grey[400] : Colors.grey[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // CardContent (Main Details)
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: LayoutBuilder(
//                       builder: (context, constraints) {
//                         final isWide = constraints.maxWidth > 600;
//                         if (isWide) {
//                           return Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     _DetailField(
//                                       label: "Inquiry ID",
//                                       child: _ReadOnlyInput(
//                                         value: data!.inquiryID.toString(),
//                                       ),
//                                     ),
//                                     _DetailField(
//                                       label: "Customer",
//                                       child: Text(
//                                         "${data!.customerCode} - ${data!.customerName}",
//                                         style: theme.textTheme.bodyMedium
//                                             ?.copyWith(
//                                               color:
//                                                   isDark
//                                                       ? Colors.grey[300]
//                                                       : Colors.grey[800],
//                                             ),
//                                       ),
//                                     ),
//                                     _DetailField(
//                                       label: "Sales Team",
//                                       child: Text(
//                                         "${data!.salesmanName} (${data!.salesmanCode})",
//                                         style: theme.textTheme.bodyMedium
//                                             ?.copyWith(
//                                               color:
//                                                   isDark
//                                                       ? Colors.grey[300]
//                                                       : Colors.grey[800],
//                                             ),
//                                       ),
//                                     ),
//                                     _DetailField(
//                                       label: "Region",
//                                       child: _ReadOnlyInput(
//                                         value: data!.salesRegionCodeDesc,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 32),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     _DetailField(
//                                       label: "Inquiry Date",
//                                       child: _ReadOnlyInput(
//                                         value: DateFormat.yMd().format(
//                                           DateTime.parse(data!.inquiryDate),
//                                         ),
//                                       ),
//                                     ),
//                                     _DetailField(
//                                       label: "Consultant",
//                                       child: Text(
//                                         data!.consultantFullName,
//                                         style: theme.textTheme.bodyMedium
//                                             ?.copyWith(
//                                               color:
//                                                   isDark
//                                                       ? Colors.grey[300]
//                                                       : Colors.grey[800],
//                                             ),
//                                       ),
//                                     ),
//                                     _DetailField(
//                                       label: "Inquiry Number",
//                                       child: _ReadOnlyInput(
//                                         value: data!.inquiryNumber,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           );
//                         } else {
//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _DetailField(
//                                 label: "Inquiry ID",
//                                 child: _ReadOnlyInput(
//                                   value: data!.inquiryID.toString(),
//                                 ),
//                               ),
//                               _DetailField(
//                                 label: "Customer",
//                                 child: Text(
//                                   "${data!.customerCode} - ${data!.customerName}",
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color:
//                                         isDark
//                                             ? Colors.grey[300]
//                                             : Colors.grey[800],
//                                   ),
//                                 ),
//                               ),
//                               _DetailField(
//                                 label: "Sales Team",
//                                 child: Text(
//                                   "${data!.salesmanName} (${data!.salesmanCode})",
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color:
//                                         isDark
//                                             ? Colors.grey[300]
//                                             : Colors.grey[800],
//                                   ),
//                                 ),
//                               ),
//                               _DetailField(
//                                 label: "Region",
//                                 child: _ReadOnlyInput(
//                                   value: data!.salesRegionCodeDesc,
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               _DetailField(
//                                 label: "Inquiry Date",
//                                 child: _ReadOnlyInput(
//                                   value: DateFormat.yMd().format(
//                                     DateTime.parse(data!.inquiryDate),
//                                   ),
//                                 ),
//                               ),
//                               _DetailField(
//                                 label: "Consultant",
//                                 child: Text(
//                                   data!.consultantFullName,
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     color:
//                                         isDark
//                                             ? Colors.grey[300]
//                                             : Colors.grey[800],
//                                   ),
//                                 ),
//                               ),
//                               _DetailField(
//                                 label: "Inquiry Number",
//                                 child: _ReadOnlyInput(
//                                   value: data!.inquiryNumber,
//                                 ),
//                               ),
//                             ],
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                   // CardHeader for Items
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
//                     decoration: BoxDecoration(
//                       border: Border(
//                         bottom: BorderSide(color: borderColor, width: 1),
//                       ),
//                     ),
//                     child: Text(
//                       "Items",
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w500,
//                         fontSize: 18,
//                       ),
//                     ),
//                   ),
//                   // CardContent (Table)
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: DataTable(
//                         columns: const [
//                           DataColumn(label: Text("Item Code")),
//                           DataColumn(label: Text("Quantity")),
//                           DataColumn(label: Text("UOM")),
//                           DataColumn(label: Text("Price")),
//                         ],
//                         rows:
//                             data!.inqEntryItemModel
//                                 .map(
//                                   (item) => DataRow(
//                                     cells: [
//                                       DataCell(Text(item.salesItemCode)),
//                                       DataCell(Text(item.itemQty.toString())),
//                                       DataCell(Text(item.uom)),
//                                       DataCell(Text("₹${item.basicPrice}")),
//                                     ],
//                                   ),
//                                 )
//                                 .toList(),
//                         headingRowColor: MaterialStateProperty.all(
//                           theme.colorScheme.surfaceVariant.withOpacity(0.2),
//                         ),
//                         dataRowColor: MaterialStateProperty.all(
//                           theme.colorScheme.surface,
//                         ),
//                         border: TableBorder(
//                           horizontalInside: BorderSide(
//                             color: borderColor,
//                             width: 1,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // CardFooter
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         SizedBox(
//                           width: 200,
//                           child: OutlinedButton(
//                             onPressed: () {
//                               Navigator.of(context).maybePop();
//                             },
//                             child: const Text("Back to List"),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Helper for detail fields
// class _DetailField extends StatelessWidget {
//   final String label;
//   final Widget child;
//   const _DetailField({required this.label, required this.child, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [Label(label), const SizedBox(height: 6), child],
//       ),
//     );
//   }
// }

// // Read-only input style
// class _ReadOnlyInput extends StatelessWidget {
//   final String value;
//   const _ReadOnlyInput({required this.value, super.key});
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return TextFormField(
//       initialValue: value,
//       readOnly: true,
//       style: theme.textTheme.bodyMedium,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: isDark ? theme.inputDecorationTheme.fillColor : Colors.white,
//         border: InputBorder.none,
//         enabledBorder: InputBorder.none,
//         focusedBorder: InputBorder.none,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 10,
//           horizontal: 12,
//         ),
//       ),
//     );
//   }
// }

// // Label widget for field titles
// class Label extends StatelessWidget {
//   final String text;
//   const Label(this.text, {super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: Theme.of(context).textTheme.labelMedium?.copyWith(
//         color: Theme.of(context).colorScheme.primary,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nhapp/utils/format_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final borderColor = theme.dividerColor;

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Inquiry Details')),
        body: Center(child: Text(error!)),
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
      body: SingleChildScrollView(
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
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/icons/download.svg', // Path to your SVG
                              height: 20, // Optional: Set size
                              width:
                                  20, // Optional: Recolor (for single-color SVGs) // Optional: Control scaling
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filledTonal(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/icons/pdf.svg', // Path to your SVG
                              height: 20, // Optional: Set size
                              width: 20, // Optional: Control scaling
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filledTonal(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/icons/file.svg', // Path to your SVG
                              height: 20, // Optional: Set size
                              width: 20, // Optional: Control scaling
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton.filledTonal(
                            onPressed: () {},
                            icon: SvgPicture.asset(
                              'assets/icons/location.svg', // Path to your SVG
                              height: 20, // Optional: Set size
                              width: 20, // Optional: Control scaling
                            ),
                          ),
                        ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                                    style: theme.textTheme.bodyMedium?.copyWith(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text("Items", style: theme.textTheme.titleMedium),
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
    );
  }
}
