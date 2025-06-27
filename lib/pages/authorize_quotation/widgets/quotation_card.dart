// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';

// class QuotationCard extends StatelessWidget {
//   final QuotationData qtn;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const QuotationCard({
//     required this.qtn,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ExpansionTile(
//         title: Text(
//           'QTN#: ${qtn.qtnNumber} | Customer: ${qtn.customerFullName}',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           'Date: ${qtn.date.toLocal().toString().split(' ')[0]} | Site: ${qtn.siteFullName}',
//         ),
//         children: [
//           ...qtn.itemDetailsList.map(
//             (item) => ListTile(
//               title: Text('${item.itemName} (${item.itemCode})'),
//               subtitle: Text(
//                 'Qty: ${item.qty} ${item.uom} | Rate: ${item.rate.toStringAsFixed(2)}',
//               ),
//             ),
//           ),
//           OverflowBar(
//             children: [
//               TextButton.icon(
//                 icon: const Icon(Icons.picture_as_pdf),
//                 label: const Text('PDF'),
//                 onPressed: onPdfTap,
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.check),
//                 label: const Text('Authorize'),
//                 onPressed: qtn.isAuthorized ? null : onAuthorizeTap,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class QuotationCard extends StatefulWidget {
//   final QuotationData qtn;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const QuotationCard({
//     required this.qtn,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<QuotationCard> createState() => _QuotationCardState();
// }

// class _QuotationCardState extends State<QuotationCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late AnimationController _animationController;
//   late Animation<double> _expandAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: Column(
//         children: [
//           // Main content
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header row with QTN number and status
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'QTN #${widget.qtn.qtnNumber}',
//                             style: theme.textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             widget.qtn.customerFullName,
//                             style: theme.textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Authorization status badge
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             widget.qtn.isAuthorized
//                                 ? Colors.green.withOpacity(0.1)
//                                 : Colors.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color:
//                               widget.qtn.isAuthorized
//                                   ? Colors.green
//                                   : Colors.orange,
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             widget.qtn.isAuthorized
//                                 ? Icons.check_circle
//                                 : Icons.pending,
//                             size: 16,
//                             color:
//                                 widget.qtn.isAuthorized
//                                     ? Colors.green
//                                     : Colors.orange,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             widget.qtn.isAuthorized ? 'Authorized' : 'Pending',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color:
//                                   widget.qtn.isAuthorized
//                                       ? Colors.green
//                                       : Colors.orange,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // Details section
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.surface,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: theme.colorScheme.outline.withOpacity(0.2),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildDetailRow(
//                         context,
//                         'Site',
//                         widget.qtn.siteFullName,
//                         Icons.location_on_outlined,
//                       ),
//                       const SizedBox(height: 8),
//                       _buildDetailRow(
//                         context,
//                         'Date',
//                         FormatUtils.formatDateForUser(widget.qtn.date),
//                         Icons.calendar_today_outlined,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // Action buttons and expand section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Item count and expand button
//                     InkWell(
//                       onTap: () {
//                         setState(() {
//                           _expanded = !_expanded;
//                           if (_expanded) {
//                             _animationController.forward();
//                           } else {
//                             _animationController.reverse();
//                           }
//                         });
//                       },
//                       borderRadius: BorderRadius.circular(8),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.inventory_2_outlined,
//                               size: 16,
//                               color: theme.colorScheme.primary,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               '${widget.qtn.itemDetailsList.length} item${widget.qtn.itemDetailsList.length == 1 ? '' : 's'}',
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: theme.colorScheme.primary,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             AnimatedBuilder(
//                               animation: _expandAnimation,
//                               builder: (context, child) {
//                                 return Transform.rotate(
//                                   angle: _expandAnimation.value * 3.14159,
//                                   child: Icon(
//                                     Icons.keyboard_arrow_down,
//                                     size: 20,
//                                     color: theme.colorScheme.primary,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     // Action buttons
//                     Row(
//                       children: [
//                         OutlinedButton.icon(
//                           onPressed: widget.onPdfTap,
//                           icon: const Icon(
//                             Icons.picture_as_pdf_outlined,
//                             size: 18,
//                           ),
//                           label: const Text('PDF'),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton.icon(
//                           onPressed:
//                               widget.qtn.isAuthorized
//                                   ? null
//                                   : widget.onAuthorizeTap,
//                           icon: Icon(
//                             widget.qtn.isAuthorized
//                                 ? Icons.check_circle
//                                 : Icons.check_circle_outline,
//                             size: 18,
//                           ),
//                           label: Text(
//                             widget.qtn.isAuthorized
//                                 ? 'Authorized'
//                                 : 'Authorize',
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 8,
//                             ),
//                             backgroundColor:
//                                 widget.qtn.isAuthorized ? Colors.green : null,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // Expandable item details
//           AnimatedSize(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             child:
//                 _expanded
//                     ? Container(
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surfaceVariant.withOpacity(
//                           0.3,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(12),
//                           bottomRight: Radius.circular(12),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.list_alt,
//                                   size: 18,
//                                   color: theme.colorScheme.primary,
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   'Item Details',
//                                   style: theme.textTheme.titleSmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: theme.colorScheme.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           ...widget.qtn.itemDetailsList.asMap().entries.map(
//                             (entry) =>
//                                 _buildItemCard(context, entry.value, entry.key),
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                       ),
//                     )
//                     : const SizedBox.shrink(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//   ) {
//     final theme = Theme.of(context);

//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(6),
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
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildItemCard(BuildContext context, dynamic item, int index) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Item header
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '#${index + 1}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   '${item.itemName} (${item.itemCode})',
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           // Item details in grid
//           Row(
//             children: [
//               Expanded(
//                 child: _buildItemDetail(
//                   context,
//                   'Quantity',
//                   '${item.qty} ${item.uom}',
//                 ),
//               ),
//               Expanded(
//                 child: _buildItemDetail(
//                   context,
//                   'Rate',
//                   item.rate.toStringAsFixed(2),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildItemDetail(BuildContext context, String label, String value) {
//     final theme = Theme.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//             fontWeight: FontWeight.w500,
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
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
// import 'package:nhapp/utils/format_utils.dart';

// class QuotationCard extends StatefulWidget {
//   final QuotationData qtn;
//   final VoidCallback onPdfTap;
//   final VoidCallback onAuthorizeTap;

//   const QuotationCard({
//     required this.qtn,
//     required this.onPdfTap,
//     required this.onAuthorizeTap,
//     super.key,
//   });

//   @override
//   State<QuotationCard> createState() => _QuotationCardState();
// }

// class _QuotationCardState extends State<QuotationCard>
//     with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   late final AnimationController _animationController;
//   late final Animation<double> _expandAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _toggleExpand() {
//     setState(() {
//       _expanded = !_expanded;
//       if (_expanded) {
//         _animationController.forward();
//       } else {
//         _animationController.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Slidable(
//       key: ValueKey(widget.qtn.qtnID),
//       endActionPane: ActionPane(
//         motion: const DrawerMotion(),
//         children: [
//           SlidableAction(
//             onPressed: (_) => widget.onPdfTap(),
//             backgroundColor: Colors.blue.shade600,
//             foregroundColor: Colors.white,
//             icon: Icons.picture_as_pdf_outlined,
//             label: 'PDF',
//             borderRadius: const BorderRadius.horizontal(
//               left: Radius.circular(12),
//             ),
//           ),
//           SlidableAction(
//             onPressed:
//                 widget.qtn.isAuthorized ? null : (_) => widget.onAuthorizeTap(),
//             backgroundColor: Colors.green.shade600,
//             foregroundColor: Colors.white,
//             icon: Icons.check_circle_outline,
//             label: 'Authorize',
//             borderRadius: const BorderRadius.horizontal(
//               right: Radius.circular(12),
//             ),
//           ),
//         ],
//       ),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         child: Column(
//           children: [
//             // Main content
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'QTN #${widget.qtn.qtnNumber}',
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: theme.primaryColor,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               widget.qtn.customerFullName,
//                               style: theme.textTheme.titleSmall?.copyWith(
//                                 fontWeight: FontWeight.w600,
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   // Details section
//                   _DetailSection(qtn: widget.qtn),
//                   const SizedBox(height: 12),
//                   // Expand/Collapse button and action hint
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       InkWell(
//                         onTap: _toggleExpand,
//                         borderRadius: BorderRadius.circular(8),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 8,
//                           ),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.inventory_2_outlined,
//                                 size: 16,
//                                 color: Colors.blue,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '${widget.qtn.itemDetailsList.length} item${widget.qtn.itemDetailsList.length == 1 ? '' : 's'}',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   color: theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               AnimatedBuilder(
//                                 animation: _expandAnimation,
//                                 builder: (context, child) {
//                                   return Transform.rotate(
//                                     angle: _expandAnimation.value * 3.14159,
//                                     child: const Icon(
//                                       Icons.keyboard_arrow_down,
//                                       size: 20,
//                                       color: Colors.blue,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.swipe_left,
//                             size: 16,
//                             color: theme.colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             'Swipe for actions',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(
//                                 0.5,
//                               ),
//                               fontStyle: FontStyle.italic,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // Expandable item details
//             AnimatedSize(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//               child:
//                   _expanded
//                       ? _ItemDetailsList(items: widget.qtn.itemDetailsList)
//                       : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DetailSection extends StatelessWidget {
//   final QuotationData qtn;
//   const _DetailSection({required this.qtn});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           _buildDetailRow(
//             context,
//             'Site',
//             qtn.siteFullName,
//             Icons.location_on_outlined,
//           ),
//           const SizedBox(height: 8),
//           _buildDetailRow(
//             context,
//             'Date',
//             FormatUtils.formatDateForUser(qtn.date),
//             Icons.calendar_today_outlined,
//           ),
//           // const SizedBox(height: 8),
//           // _buildDetailRow(
//           //   context,
//           //   'Revision',
//           //   qtn.revisionNo.toString(),
//           //   Icons.repeat,
//           // ),
//         ],
//       ),
//     );
//   }

//   static Widget _buildDetailRow(
//     BuildContext context,
//     String label,
//     String value,
//     IconData icon,
//   ) {
//     final theme = Theme.of(context);
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(6),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(6),
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
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ItemDetailsList extends StatelessWidget {
//   final List<QuotationItem> items;
//   const _ItemDetailsList({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     // Use ListView.builder for better performance with many items
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       itemBuilder: (context, index) {
//         final item = items[index];
//         return Container(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: theme.colorScheme.surface,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//               color: theme.colorScheme.outline.withOpacity(0.2),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Item header
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '#${index + 1}',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.primary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       item.itemCode,
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // Item description
//               Text(
//                 item.itemName,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.8),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               // Item details in grid
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildItemDetail(
//                       context,
//                       'Quantity',
//                       '${item.qty} ${item.uom}',
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildItemDetail(
//                       context,
//                       'Rate',
//                       item.rate.toStringAsFixed(2),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   static Widget _buildItemDetail(
//     BuildContext context,
//     String label,
//     String value,
//   ) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: theme.textTheme.bodySmall?.copyWith(
//             color: theme.colorScheme.onSurface.withOpacity(0.7),
//             fontWeight: FontWeight.w500,
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
// }

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/utils/format_utils.dart';

class QuotationCard extends StatefulWidget {
  final QuotationData qtn;
  final VoidCallback onPdfTap;
  final VoidCallback onAuthorizeTap;

  const QuotationCard({
    required this.qtn,
    required this.onPdfTap,
    required this.onAuthorizeTap,
    super.key,
  });

  @override
  State<QuotationCard> createState() => _QuotationCardState();
}

class _QuotationCardState extends State<QuotationCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(widget.qtn.qtnID),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onPdfTap(),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            icon: Icons.picture_as_pdf_outlined,
            label: 'PDF',
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
          ),
          SlidableAction(
            onPressed:
                widget.qtn.isAuthorized ? null : (_) => widget.onAuthorizeTap(),
            backgroundColor:
                widget.qtn.isAuthorized
                    ? Colors.grey.shade400
                    : Colors.green.shade600,
            foregroundColor: Colors.white,
            icon:
                widget.qtn.isAuthorized
                    ? Icons.check_circle
                    : Icons.check_circle_outline,
            label: widget.qtn.isAuthorized ? 'Authorized' : 'Authorize',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        // elevation: 2,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            // Main content
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with QTN number and status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'QTN #${widget.qtn.qtnNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.qtn.customerFullName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Details section
                  // _DetailSection(qtn: widget.qtn),

                  // const SizedBox(height: 12),

                  // Expand/Collapse button and action hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: _toggleExpand,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.qtn.itemDetailsList.length} item${widget.qtn.itemDetailsList.length == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _expandAnimation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _expandAnimation.value * 3.14159,
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 20,
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action hint
                      Row(
                        children: [
                          Icon(
                            Icons.swipe_left,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Swipe for actions',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Expandable item details
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child:
                  _expanded
                      ? Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.list_alt,
                                    size: 18,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Item Details',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _ItemDetailsList(items: widget.qtn.itemDetailsList),
                            const SizedBox(height: 8),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final QuotationData qtn;
  const _DetailSection({required this.qtn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // _buildDetailRow(
          //   context,
          //   'Site',
          //   qtn.siteFullName,
          //   Icons.location_on_outlined,
          // ),
          // const SizedBox(height: 8),
          _buildDetailRow(
            context,
            'Date',
            FormatUtils.formatDateForUser(qtn.date),
            Icons.calendar_today_outlined,
          ),
          // const SizedBox(height: 8),
          // _buildDetailRow(
          //   context,
          //   'Revision',
          //   qtn.revisionNo.toString(),
          //   Icons.repeat_outlined,
          // ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemDetailsList extends StatelessWidget {
  final List<QuotationItem> items;
  const _ItemDetailsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          items.asMap().entries.map((entry) {
            return _buildItemCard(context, entry.value, entry.key);
          }).toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, QuotationItem item, int index) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${index + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.itemCode,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Item description
          Text(
            item.itemName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 8),

          // Item details in grid
          Row(
            children: [
              Expanded(
                child: _buildItemDetail(
                  context,
                  'Quantity',
                  '${FormatUtils.formatQuantity(item.qty)} ${item.uom}',
                ),
              ),
              Expanded(
                child: _buildItemDetail(
                  context,
                  'Rate',
                  FormatUtils.formatAmount(item.rate),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Amount (highlighted)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  FormatUtils.formatAmount(item.qty * item.rate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildItemDetail(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
