// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
// import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';

// class AddItemPage extends StatefulWidget {
//   final ProformaInvoiceService service;
//   final List<RateStructure> rateStructures;
//   final List<ProformaItem> existingItems; // Add this parameter
//   final bool isDuplicateAllowed; // Add this parameter

//   const AddItemPage({
//     super.key,
//     required this.service,
//     required this.rateStructures,
//     required this.existingItems,
//     required this.isDuplicateAllowed,
//   });

//   @override
//   State<AddItemPage> createState() => _AddItemPageState();
// }

// class _AddItemPageState extends State<AddItemPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController itemNameController = TextEditingController();
//   final TextEditingController qtyController = TextEditingController(text: "1");
//   final TextEditingController basicRateController = TextEditingController();
//   final TextEditingController discountPercentageController =
//       TextEditingController();
//   final TextEditingController discountAmountController =
//       TextEditingController();

//   SalesItem? selectedItem;
//   String discountType = "None";
//   DiscountCode? selectedDiscountCode;
//   List<DiscountCode> discountCodes = [];
//   String? selectedRateStructure;
//   List<Map<String, dynamic>> rateStructureRows = [];
//   bool _isLoading = false;
//   bool _formDirty = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadDiscountCodes();
//   }

//   @override
//   void dispose() {
//     itemNameController.dispose();
//     qtyController.dispose();
//     basicRateController.dispose();
//     discountPercentageController.dispose();
//     discountAmountController.dispose();
//     super.dispose();
//   }

//   bool _formIsDirty() {
//     return _formDirty ||
//         itemNameController.text.isNotEmpty ||
//         qtyController.text != "1" ||
//         basicRateController.text.isNotEmpty ||
//         discountPercentageController.text.isNotEmpty ||
//         discountAmountController.text.isNotEmpty;
//   }

//   void _setDirty() {
//     if (!_formDirty) setState(() => _formDirty = true);
//   }

//   Future<void> _loadDiscountCodes() async {
//     try {
//       discountCodes = await widget.service.fetchDiscountCodes();
//       if (discountCodes.isNotEmpty) {
//         setState(() {
//           selectedDiscountCode = discountCodes.first;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error loading discount codes: $e");
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         if (_formIsDirty()) {
//           final shouldLeave = await showDialog<bool>(
//             context: context,
//             builder:
//                 (context) => AlertDialog(
//                   title: const Text("Discard changes?"),
//                   content: const Text(
//                     "You have unsaved changes. Do you want to discard them?",
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, false),
//                       child: const Text("Cancel"),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.pop(context, true),
//                       child: const Text("Discard"),
//                     ),
//                   ],
//                 ),
//           );
//           return shouldLeave ?? false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         appBar: AppBar(title: const Text("Add Item")),
//         body:
//             _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Form(
//                   key: _formKey,
//                   child: SingleChildScrollView(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildItemNameField(),
//                         const SizedBox(height: 16),
//                         _buildQuantityField(),
//                         const SizedBox(height: 16),
//                         _buildBasicRateField(),
//                         const SizedBox(height: 16),
//                         _buildDiscountCodeField(),
//                         const SizedBox(height: 16),
//                         _buildDiscountTypeField(),
//                         if (discountType == "Percentage") ...[
//                           const SizedBox(height: 16),
//                           _buildDiscountPercentageField(),
//                         ],
//                         if (discountType == "Value") ...[
//                           const SizedBox(height: 16),
//                           _buildDiscountAmountField(),
//                         ],
//                         const SizedBox(height: 16),
//                         _buildRateStructureField(),
//                         const SizedBox(height: 24),
//                         _buildSubmitButton(),
//                       ],
//                     ),
//                   ),
//                 ),
//       ),
//     );
//   }

//   Widget _buildDiscountCodeField() {
//     return DropdownButtonFormField<DiscountCode>(
//       value: selectedDiscountCode,
//       decoration: const InputDecoration(
//         labelText: "Discount Code",
//         border: OutlineInputBorder(),
//       ),
//       isExpanded: true,
//       items:
//           discountCodes.map((discountCode) {
//             return DropdownMenuItem<DiscountCode>(
//               value: discountCode,
//               child: Text(
//                 discountCode.codeFullName,
//                 style: const TextStyle(fontSize: 14),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }).toList(),
//       onChanged: (val) {
//         setState(() {
//           selectedDiscountCode = val;
//           _formDirty = true;
//         });
//       },
//       validator: (value) => value == null ? "Discount Code is required" : null,
//     );
//   }

//   Widget _buildItemNameField() {
//     return TypeAheadField<SalesItem>(
//       debounceDuration: const Duration(milliseconds: 400),
//       controller: itemNameController,
//       builder: (context, controller, focusNode) {
//         return TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           decoration: const InputDecoration(
//             labelText: "Item Name",
//             border: OutlineInputBorder(),
//           ),
//           onChanged: (_) => _setDirty(),
//           validator:
//               (val) =>
//                   val == null || val.isEmpty ? "Item Name is required" : null,
//         );
//       },
//       suggestionsCallback: (pattern) async {
//         if (pattern.length < 4) return [];
//         try {
//           final allItems = await widget.service.fetchSalesItemList(pattern);

//           if (!widget.isDuplicateAllowed) {
//             // Filter out items that are already added
//             final addedItemCodes =
//                 widget.existingItems.map((item) => item.itemCode).toSet();
//             return allItems
//                 .where((item) => !addedItemCodes.contains(item.itemCode))
//                 .toList();
//           }

//           return allItems;
//         } catch (e) {
//           return [];
//         }
//       },
//       itemBuilder: (context, suggestion) {
//         return ListTile(
//           title: Text(suggestion.itemName),
//           subtitle: Text(suggestion.itemCode),
//         );
//       },
//       onSelected: (suggestion) async {
//         // Check for duplicates if not allowed
//         if (!widget.isDuplicateAllowed) {
//           final isDuplicate = widget.existingItems.any(
//             (item) => item.itemCode == suggestion.itemCode,
//           );
//           if (isDuplicate) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("This item is already added"),
//                 backgroundColor: Colors.red,
//               ),
//             );
//             return;
//           }
//         }

//         setState(() {
//           selectedItem = suggestion;
//           itemNameController.text = suggestion.itemName;
//           basicRateController.text = "0";
//           qtyController.text = "1";
//           discountPercentageController.clear();
//           discountAmountController.clear();
//           _formDirty = true;
//         });
//       },
//       hideOnEmpty: true,
//       hideOnError: true,
//       hideOnLoading: false,
//       animationDuration: const Duration(milliseconds: 300),
//     );
//   }

//   Widget _buildQuantityField() {
//     return TextFormField(
//       controller: qtyController,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         labelText:
//             selectedItem == null
//                 ? "Quantity (min 1)"
//                 : "Quantity (${selectedItem!.salesUOM})",
//         border: const OutlineInputBorder(),
//       ),
//       onChanged: (_) => _setDirty(),
//       validator: (value) {
//         if (value == null || value.isEmpty) return "Quantity is required";
//         final qty = double.tryParse(value);
//         if (qty == null || qty < 1) return "Minimum quantity is 1";
//         return null;
//       },
//     );
//   }

//   Widget _buildBasicRateField() {
//     return TextFormField(
//       controller: basicRateController,
//       keyboardType: TextInputType.number,
//       decoration: const InputDecoration(
//         labelText: "Basic Rate",
//         border: OutlineInputBorder(),
//       ),
//       onChanged: (_) => _setDirty(),
//       validator: (value) {
//         if (value == null || value.isEmpty) return "Basic Rate is required";
//         final rate = double.tryParse(value);
//         if (rate == null || rate <= 0) {
//           return "Basic Rate must be greater than 0";
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildDiscountTypeField() {
//     return DropdownButtonFormField<String>(
//       value: discountType,
//       decoration: const InputDecoration(
//         labelText: "Discount Type",
//         border: OutlineInputBorder(),
//       ),
//       items: [
//         const DropdownMenuItem(value: "None", child: Text("None")),
//         const DropdownMenuItem(value: "Percentage", child: Text("Percentage")),
//         const DropdownMenuItem(value: "Value", child: Text("Value")),
//       ],
//       onChanged: (val) {
//         if (val != null) {
//           setState(() {
//             discountType = val;
//             discountPercentageController.clear();
//             discountAmountController.clear();
//             _formDirty = true;
//           });
//         }
//       },
//     );
//   }

//   Widget _buildDiscountPercentageField() {
//     return TextFormField(
//       controller: discountPercentageController,
//       keyboardType: TextInputType.number,
//       decoration: const InputDecoration(
//         labelText: "Discount Percentage (1-99)",
//         border: OutlineInputBorder(),
//       ),
//       onChanged: (_) => _setDirty(),
//       validator: (value) {
//         if (discountType == "Percentage") {
//           if (value == null || value.isEmpty) {
//             return "Discount Percentage is required";
//           }
//           final perc = double.tryParse(value);
//           if (perc == null || perc < 1 || perc >= 100) {
//             return "Value must be between 1 and 99";
//           }
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildDiscountAmountField() {
//     return TextFormField(
//       controller: discountAmountController,
//       keyboardType: TextInputType.number,
//       decoration: const InputDecoration(
//         labelText: "Discount Amount (less than total amount)",
//         border: OutlineInputBorder(),
//       ),
//       onChanged: (_) => _setDirty(),
//       validator: (value) {
//         if (discountType == "Value") {
//           if (value == null || value.isEmpty) {
//             return "Discount Amount is required";
//           }
//           final disc = double.tryParse(value);
//           final rate = double.tryParse(basicRateController.text) ?? 0;
//           final qty = double.tryParse(qtyController.text) ?? 1;
//           final totalAmount = rate * qty;
//           if (disc == null || disc >= totalAmount) {
//             return "Discount must be less than total amount";
//           }
//         }
//         return null;
//       },
//     );
//   }

//   // Widget _buildRateStructureField() {
//   //   return DropdownButtonFormField<String>(
//   //     value: selectedRateStructure,
//   //     decoration: const InputDecoration(
//   //       labelText: "Rate Structure",
//   //       border: OutlineInputBorder(),
//   //     ),
//   //     isExpanded: true,
//   //     selectedItemBuilder: (context) {
//   //       return widget.rateStructures.map((rs) {
//   //         return SizedBox(
//   //           width: 200,
//   //           child: Text(
//   //             rs.rateStructFullName,
//   //             overflow: TextOverflow.ellipsis,
//   //             style: const TextStyle(color: Colors.black),
//   //           ),
//   //         );
//   //       }).toList();
//   //     },
//   //     items:
//   //         widget.rateStructures.map((rs) {
//   //           return DropdownMenuItem<String>(
//   //             value: rs.rateStructCode,
//   //             child: Text(
//   //               rs.rateStructFullName,
//   //               style: const TextStyle(fontSize: 14),
//   //             ),
//   //           );
//   //         }).toList(),
//   //     onChanged: (val) async {
//   //       setState(() {
//   //         selectedRateStructure = val;
//   //         _formDirty = true;
//   //       });
//   //       if (val != null) {
//   //         rateStructureRows = await widget.service.fetchRateStructureDetails(
//   //           val,
//   //         );
//   //       }
//   //     },
//   //     validator: (value) => value == null ? "Rate Structure is required" : null,
//   //   );
//   // }
//   Widget _buildRateStructureField() {
//     return DropdownButtonFormField<String>(
//       isDense: true,
//       isExpanded: true, // Key property to handle text overflow
//       value: selectedRateStructure,
//       decoration: const InputDecoration(
//         labelText: "Rate Structure",
//         border: OutlineInputBorder(),
//       ),
//       items:
//           widget.rateStructures.map((rs) {
//             return DropdownMenuItem<String>(
//               value: rs.rateStructCode,
//               child: Text(
//                 rs.rateStructFullName,
//                 softWrap: true,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(fontSize: 14),
//               ),
//             );
//           }).toList(),
//       onChanged: (val) async {
//         setState(() {
//           selectedRateStructure = val;
//           _formDirty = true;
//         });
//         if (val != null) {
//           rateStructureRows = await widget.service.fetchRateStructureDetails(
//             val,
//           );
//         }
//       },
//       validator: (value) => value == null ? "Rate Structure is required" : null,
//     );
//   }

//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isLoading ? null : _addItem,
//         child:
//             _isLoading
//                 ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                 : const Text("Add"),
//       ),
//     );
//   }

//   // Future<void> _addItem() async {
//   //   if (!_formKey.currentState!.validate()) return;

//   //   final qty = double.parse(qtyController.text);
//   //   final basicRate = double.parse(basicRateController.text);

//   //   double discountAmount = 0;
//   //   double? discountPercentage;

//   //   // Discount calculation logic - exactly same as sales order
//   //   if (discountType == "Percentage") {
//   //     discountPercentage = double.parse(discountPercentageController.text);
//   //     final totalBeforeDiscount = basicRate * qty;
//   //     discountAmount = totalBeforeDiscount * (discountPercentage / 100);
//   //   } else if (discountType == "Value") {
//   //     discountAmount = double.parse(discountAmountController.text);
//   //     final totalBeforeDiscount = basicRate * qty;
//   //     discountPercentage =
//   //         totalBeforeDiscount > 0
//   //             ? (discountAmount / totalBeforeDiscount) * 100
//   //             : 0;
//   //   }

//   //   setState(() => _isLoading = true);

//   //   try {
//   //     final totalBeforeDiscount = basicRate * qty;
//   //     final discountedValue = totalBeforeDiscount - discountAmount;

//   //     if (discountedValue < 0) {
//   //       throw Exception("Discount amount cannot be greater than total amount");
//   //     }

//   //     // Build RateStructureDetails for this item - same as sales order
//   //     final rateStructureDetails = widget.service.buildRateStructureDetails(
//   //       rateStructureRows,
//   //       selectedItem?.itemCode ?? "TEMP",
//   //       1, // itmModelRefNo
//   //     );

//   //     debugPrint("Original Rate Structure Details: $rateStructureDetails");

//   //     // Calculate rate structure amount - same as sales order
//   //     final rateStructureResponse = await widget.service.calculateRateStructure(
//   //       discountedValue,
//   //       selectedRateStructure!,
//   //       rateStructureDetails,
//   //       selectedItem?.itemCode ?? "TEMP",
//   //     );

//   //     debugPrint("Rate Structure Response: $rateStructureResponse");

//   //     // Check for success in the response - same as sales order
//   //     if (rateStructureResponse['success'] == true) {
//   //       final data = rateStructureResponse['data'];

//   //       // Get the calculated rate amounts from listCalcRateReturnDetails
//   //       final List<dynamic> calculatedRateDetails =
//   //           data['listCalcRateReturnDetails'] ?? [];

//   //       // Get the complete rate structure details from rateStructureDetails
//   //       final List<dynamic> completeRateStructure =
//   //           data['rateStructureDetails'] ?? [];

//   //       debugPrint("Calculated Rate Details: $calculatedRateDetails");
//   //       debugPrint("Complete Rate Structure: $completeRateStructure");

//   //       // Update rateAmount in completeRateStructure by matching rateCode
//   //       double totalTax = 0.0;

//   //       for (final completeDetail in completeRateStructure) {
//   //         final rateCode = completeDetail['rateCode'];

//   //         // Find matching calculated rate detail
//   //         final calculatedDetail = calculatedRateDetails.firstWhere(
//   //           (calc) => calc['rateCode'] == rateCode,
//   //           orElse: () => null,
//   //         );

//   //         // Update rateAmount from calculated details if found
//   //         if (calculatedDetail != null) {
//   //           final calculatedAmount =
//   //               (calculatedDetail['rateAmount'] ?? 0.0).toDouble();
//   //           completeDetail['rateAmount'] = calculatedAmount;
//   //           totalTax += calculatedAmount;

//   //           debugPrint(
//   //             "Rate Code: $rateCode, Updated Amount: $calculatedAmount",
//   //           );
//   //         } else {
//   //           // Keep original rateAmount if no calculated amount found
//   //           final originalAmount =
//   //               (completeDetail['rateAmount'] ?? 0.0).toDouble();
//   //           totalTax += originalAmount;

//   //           debugPrint(
//   //             "Rate Code: $rateCode, Original Amount: $originalAmount",
//   //           );
//   //         }
//   //       }

//   //       debugPrint("Final Rate Structure: $completeRateStructure");
//   //       debugPrint("Total Tax Amount: $totalTax");

//   //       // Calculate total amount
//   //       final totalAmount = discountedValue + totalTax;

//   //       final item = ProformaItem(
//   //         itemName: itemNameController.text,
//   //         itemCode: selectedItem?.itemCode ?? "TEMP",
//   //         qty: qty,
//   //         basicRate: basicRate,
//   //         uom: selectedItem?.salesUOM ?? "NOS",
//   //         discountType: discountType,
//   //         discountPercentage:
//   //             discountType == "Percentage" ? discountPercentage : null,
//   //         discountAmount: discountAmount > 0 ? discountAmount : null,
//   //         rateStructure: selectedRateStructure!,
//   //         taxAmount: totalTax,
//   //         totalAmount: totalAmount,
//   //         rateStructureRows: List<Map<String, dynamic>>.from(
//   //           completeRateStructure,
//   //         ),
//   //         lineNo: 0, // will be set in main form
//   //         hsnAccCode: selectedItem?.hsnCode ?? '',
//   //       );

//   //       Navigator.pop(context, item);
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(
//   //           content: Text(
//   //             "Error: ${rateStructureResponse['errorMessage'] ?? 'Calculation failed'}",
//   //           ),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //     }
//   //   } catch (e, stackTrace) {
//   //     debugPrint("Error in _addItem: $e");
//   //     debugPrint("Stack trace: $stackTrace");
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Error calculating item: ${e.toString()}")),
//   //     );
//   //   } finally {
//   //     setState(() => _isLoading = false);
//   //   }
//   // }
//   Future<void> _addItem() async {
//     if (!_formKey.currentState!.validate()) return;

//     final qty = double.parse(qtyController.text);
//     final basicRate = double.parse(basicRateController.text);

//     double discountAmount = 0;
//     double? discountPercentage;

//     // Discount calculation logic - exactly same as sales order
//     if (discountType == "Percentage") {
//       discountPercentage = double.parse(discountPercentageController.text);
//       final totalBeforeDiscount = basicRate * qty;
//       discountAmount = totalBeforeDiscount * (discountPercentage / 100);
//     } else if (discountType == "Value") {
//       discountAmount = double.parse(discountAmountController.text);
//       final totalBeforeDiscount = basicRate * qty;
//       discountPercentage =
//           totalBeforeDiscount > 0
//               ? (discountAmount / totalBeforeDiscount) * 100
//               : 0;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final totalBeforeDiscount = basicRate * qty;
//       final discountedValue = totalBeforeDiscount - discountAmount;

//       if (discountedValue < 0) {
//         throw Exception("Discount amount cannot be greater than total amount");
//       }

//       // Build RateStructureDetails for this item - same as sales order
//       final rateStructureDetails = widget.service.buildRateStructureDetails(
//         rateStructureRows,
//         selectedItem?.itemCode ?? "TEMP",
//         1, // itmModelRefNo
//       );

//       debugPrint("Original Rate Structure Details: $rateStructureDetails");

//       // Calculate rate structure amount - same as sales order
//       final rateStructureResponse = await widget.service.calculateRateStructure(
//         discountedValue,
//         selectedRateStructure!,
//         rateStructureDetails,
//         selectedItem?.itemCode ?? "TEMP",
//       );

//       debugPrint("Rate Structure Response: $rateStructureResponse");

//       // Check for success in the response - same as sales order
//       if (rateStructureResponse['success'] == true) {
//         final data = rateStructureResponse['data'];
//         final updatedRateStructureDetails =
//             data['listCalcRateReturnDetails'] ?? data['rateStructureDetails'];

//         double totalTax = 0.0;
//         if (updatedRateStructureDetails != null) {
//           for (final rateDetail in updatedRateStructureDetails) {
//             final rateAmount = (rateDetail['rateAmount'] ?? 0.0).toDouble();
//             totalTax += rateAmount;
//           }
//         }

//         final totalAmount = discountedValue + totalTax;

//         final item = ProformaItem(
//           itemName: itemNameController.text,
//           itemCode: selectedItem?.itemCode ?? "TEMP",
//           qty: qty,
//           basicRate: basicRate,
//           uom: selectedItem?.salesUOM ?? "NOS",
//           discountType: discountType,
//           discountPercentage:
//               discountType == "Percentage" ? discountPercentage : null,
//           discountAmount: discountAmount > 0 ? discountAmount : null,
//           rateStructure: selectedRateStructure!,
//           taxAmount: totalTax,
//           totalAmount: totalAmount,
//           rateStructureRows:
//               updatedRateStructureDetails != null
//                   ? List<Map<String, dynamic>>.from(updatedRateStructureDetails)
//                   : rateStructureRows,
//           lineNo: 0, // will be set in main form
//           hsnAccCode: selectedItem?.hsnCode ?? '',
//         );

//         Navigator.pop(context, item);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               "Error: ${rateStructureResponse['errorMessage'] ?? 'Calculation failed'}",
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e, stackTrace) {
//       debugPrint("Error in _addItem: $e");
//       debugPrint("Stack trace: $stackTrace");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error calculating item: ${e.toString()}")),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';

class AddItemPage extends StatefulWidget {
  final ProformaInvoiceService service;
  final List<RateStructure> rateStructures;
  final List<ProformaItem> existingItems; // Add this parameter
  final bool isDuplicateAllowed; // Add this parameter

  const AddItemPage({
    super.key,
    required this.service,
    required this.rateStructures,
    required this.existingItems,
    required this.isDuplicateAllowed,
  });

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController qtyController = TextEditingController(text: "1");
  final TextEditingController basicRateController = TextEditingController();
  final TextEditingController discountPercentageController =
      TextEditingController();
  final TextEditingController discountAmountController =
      TextEditingController();

  SalesItem? selectedItem;
  String discountType = "None";
  DiscountCode? selectedDiscountCode;
  List<DiscountCode> discountCodes = [];
  String? selectedRateStructure;
  List<Map<String, dynamic>> rateStructureRows = [];
  bool _isLoading = false;
  bool _formDirty = false;

  @override
  void initState() {
    super.initState();
    _loadDiscountCodes();
  }

  @override
  void dispose() {
    itemNameController.dispose();
    qtyController.dispose();
    basicRateController.dispose();
    discountPercentageController.dispose();
    discountAmountController.dispose();
    super.dispose();
  }

  bool _formIsDirty() {
    return _formDirty ||
        itemNameController.text.isNotEmpty ||
        qtyController.text != "1" ||
        basicRateController.text.isNotEmpty ||
        discountPercentageController.text.isNotEmpty ||
        discountAmountController.text.isNotEmpty;
  }

  void _setDirty() {
    if (!_formDirty) setState(() => _formDirty = true);
  }

  Future<void> _loadDiscountCodes() async {
    try {
      discountCodes = await widget.service.fetchDiscountCodes();
      if (discountCodes.isNotEmpty) {
        setState(() {
          selectedDiscountCode = discountCodes.first; // Set default selection
        });
      }
    } catch (e) {
      debugPrint("Error loading discount codes: $e");
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_formIsDirty()) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Discard changes?"),
                  content: const Text(
                    "You have unsaved changes. Do you want to discard them?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Discard"),
                    ),
                  ],
                ),
          );
          return shouldLeave ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Add Item")),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildItemNameField(),
                        const SizedBox(height: 16),
                        _buildQuantityField(),
                        const SizedBox(height: 16),
                        _buildBasicRateField(),
                        const SizedBox(height: 16),
                        _buildDiscountCodeField(),
                        const SizedBox(height: 16),
                        _buildDiscountTypeField(),
                        if (discountType == "Percentage") ...[
                          const SizedBox(height: 16),
                          _buildDiscountPercentageField(),
                        ],
                        if (discountType == "Value") ...[
                          const SizedBox(height: 16),
                          _buildDiscountAmountField(),
                        ],
                        const SizedBox(height: 16),
                        _buildRateStructureField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildDiscountCodeField() {
    return DropdownButtonFormField<DiscountCode>(
      value: selectedDiscountCode,
      decoration: const InputDecoration(
        labelText: "Discount Code",
        border: OutlineInputBorder(),
      ),
      isExpanded: true,
      items:
          discountCodes.map((discountCode) {
            return DropdownMenuItem<DiscountCode>(
              value: discountCode,
              child: Text(
                discountCode.codeFullName,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: (val) {
        setState(() {
          selectedDiscountCode = val;
          _formDirty = true;
        });
      },
      validator: (value) => value == null ? "Discount Code is required" : null,
    );
  }

  Widget _buildItemNameField() {
    return TypeAheadField<SalesItem>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: itemNameController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: "Item Name",
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _setDirty(),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Item Name is required" : null,
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length < 4) return [];
        try {
          final allItems = await widget.service.fetchSalesItemList(pattern);

          if (!widget.isDuplicateAllowed) {
            // Filter out items that are already added
            final addedItemCodes =
                widget.existingItems.map((item) => item.itemCode).toSet();
            return allItems
                .where((item) => !addedItemCodes.contains(item.itemCode))
                .toList();
          }

          return allItems;
        } catch (e) {
          return [];
        }
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.itemName),
          subtitle: Text(suggestion.itemCode),
        );
      },
      onSelected: (suggestion) async {
        // Check for duplicates if not allowed
        if (!widget.isDuplicateAllowed) {
          final isDuplicate = widget.existingItems.any(
            (item) => item.itemCode == suggestion.itemCode,
          );
          if (isDuplicate) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("This item is already added"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }

        setState(() {
          selectedItem = suggestion;
          itemNameController.text = suggestion.itemName;
          basicRateController.text = "0";
          qtyController.text = "1";
          discountPercentageController.clear();
          discountAmountController.clear();
          _formDirty = true;
        });
      },
      hideOnEmpty: true,
      hideOnError: true,
      hideOnLoading: false,
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: qtyController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText:
            selectedItem == null
                ? "Quantity (min 1)"
                : "Quantity (${selectedItem!.salesUOM})",
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (value == null || value.isEmpty) return "Quantity is required";
        final qty = double.tryParse(value);
        if (qty == null || qty < 1) return "Minimum quantity is 1";
        return null;
      },
    );
  }

  Widget _buildBasicRateField() {
    return TextFormField(
      controller: basicRateController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Basic Rate",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (value == null || value.isEmpty) return "Basic Rate is required";
        final rate = double.tryParse(value);
        if (rate == null || rate <= 0) {
          return "Basic Rate must be greater than 0";
        }
        return null;
      },
    );
  }

  Widget _buildDiscountTypeField() {
    return DropdownButtonFormField<String>(
      value: discountType,
      decoration: const InputDecoration(
        labelText: "Discount Type",
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: "None", child: Text("None")),
        const DropdownMenuItem(value: "Percentage", child: Text("Percentage")),
        const DropdownMenuItem(value: "Value", child: Text("Value")),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() {
            discountType = val;
            discountPercentageController.clear();
            discountAmountController.clear();
            _formDirty = true;
          });
        }
      },
    );
  }

  Widget _buildDiscountPercentageField() {
    return TextFormField(
      controller: discountPercentageController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Discount Percentage (1-99)",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (discountType == "Percentage") {
          if (value == null || value.isEmpty) {
            return "Discount Percentage is required";
          }
          final perc = double.tryParse(value);
          if (perc == null || perc < 1 || perc >= 100) {
            return "Value must be between 1 and 99";
          }
        }
        return null;
      },
    );
  }

  Widget _buildDiscountAmountField() {
    return TextFormField(
      controller: discountAmountController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Discount Amount (less than total amount)",
        border: OutlineInputBorder(),
      ),
      onChanged: (_) => _setDirty(),
      validator: (value) {
        if (discountType == "Value") {
          if (value == null || value.isEmpty) {
            return "Discount Amount is required";
          }
          final disc = double.tryParse(value);
          final rate = double.tryParse(basicRateController.text) ?? 0;
          final qty = double.tryParse(qtyController.text) ?? 1;
          final totalAmount = rate * qty;
          if (disc == null || disc >= totalAmount) {
            return "Discount must be less than total amount";
          }
        }
        return null;
      },
    );
  }

  Widget _buildRateStructureField() {
    return DropdownButtonFormField<String>(
      isDense: true,
      isExpanded: true, // Key property to handle text overflow
      value: selectedRateStructure,
      decoration: const InputDecoration(
        labelText: "Rate Structure",
        border: OutlineInputBorder(),
      ),
      items:
          widget.rateStructures.map((rs) {
            return DropdownMenuItem<String>(
              value: rs.rateStructCode,
              child: Text(
                rs.rateStructFullName,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
      onChanged: (val) async {
        setState(() {
          selectedRateStructure = val;
          _formDirty = true;
        });
        if (val != null) {
          rateStructureRows = await widget.service.fetchRateStructureDetails(
            val,
          );
        }
      },
      validator: (value) => value == null ? "Rate Structure is required" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _addItem,
        child:
            _isLoading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Add"),
      ),
    );
  }

  // Future<void> _addItem() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final qty = double.parse(qtyController.text);
  //   final basicRate = double.parse(basicRateController.text);

  //   double discountAmount = 0;
  //   double? discountPercentage;

  //   // Discount calculation logic - same as sales order
  //   if (discountType == "P") {
  //     discountPercentage = double.parse(discountPercentageController.text);
  //     final totalBeforeDiscount = basicRate * qty;
  //     discountAmount = totalBeforeDiscount * (discountPercentage / 100);
  //   } else if (discountType == "V") {
  //     discountAmount = double.parse(discountAmountController.text);
  //     final totalBeforeDiscount = basicRate * qty;
  //     discountPercentage =
  //         totalBeforeDiscount > 0
  //             ? (discountAmount / totalBeforeDiscount) * 100
  //             : 0;
  //   }

  //   setState(() => _isLoading = true);

  //   try {
  //     final totalBeforeDiscount = basicRate * qty;
  //     final discountedValue = totalBeforeDiscount - discountAmount;

  //     if (discountedValue < 0) {
  //       throw Exception("Discount amount cannot be greater than total amount");
  //     }

  //     // Rate structure calculation - same as sales order
  //     final rateStructureDetails = widget.service.buildRateStructureDetails(
  //       rateStructureRows,
  //       selectedItem?.itemCode ?? "TEMP",
  //       1,
  //     );

  //     final rateStructureResponse = await widget.service.calculateRateStructure(
  //       discountedValue,
  //       selectedRateStructure!,
  //       rateStructureDetails,
  //       selectedItem?.itemCode ?? "TEMP",
  //     );

  //     if (rateStructureResponse['success'] == true) {
  //       final data = rateStructureResponse['data'];
  //       final updatedRateStructureDetails =
  //           data['listCalcRateReturnDetails'] ?? data['rateStructureDetails'];

  //       double totalTax = 0.0;
  //       if (updatedRateStructureDetails != null) {
  //         for (final rateDetail in updatedRateStructureDetails) {
  //           final rateAmount = (rateDetail['rateAmount'] ?? 0.0).toDouble();
  //           totalTax += rateAmount;
  //         }
  //       }

  //       final totalAmount = discountedValue + totalTax;

  //       final item = ProformaItem(
  //         itemName: itemNameController.text,
  //         itemCode: selectedItem?.itemCode ?? "TEMP",
  //         qty: qty,
  //         basicRate: basicRate,
  //         uom: selectedItem?.salesUOM ?? "NOS",
  //         discountType: discountType,
  //         discountPercentage: discountType == "P" ? discountPercentage : null,
  //         discountAmount: discountAmount > 0 ? discountAmount : null,
  //         rateStructure: selectedRateStructure!,
  //         taxAmount: totalTax,
  //         totalAmount: totalAmount,
  //         rateStructureRows:
  //             updatedRateStructureDetails != null
  //                 ? List<Map<String, dynamic>>.from(updatedRateStructureDetails)
  //                 : rateStructureRows,
  //         lineNo: 0, // will be set in main form
  //         hsnAccCode: selectedItem?.hsnCode ?? '',
  //       );

  //       Navigator.pop(context, item);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "Error: ${rateStructureResponse['errorMessage'] ?? 'Calculation failed'}",
  //           ),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint("Error in _addItem: $e");
  //     debugPrint("Stack trace: $stackTrace");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error calculating item: ${e.toString()}")),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }
  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(qtyController.text);
    final basicRate = double.parse(basicRateController.text);

    double discountAmount = 0;
    double? discountPercentage;

    // Discount calculation logic - same as sales order
    if (discountType == "Percentage") {
      discountPercentage = double.parse(discountPercentageController.text);
      final totalBeforeDiscount = basicRate * qty;
      discountAmount = totalBeforeDiscount * (discountPercentage / 100);
    } else if (discountType == "Value") {
      discountAmount = double.parse(discountAmountController.text);
      final totalBeforeDiscount = basicRate * qty;
      discountPercentage =
          totalBeforeDiscount > 0
              ? (discountAmount / totalBeforeDiscount) * 100
              : 0;
    }

    setState(() => _isLoading = true);

    try {
      final totalBeforeDiscount = basicRate * qty;
      final discountedValue = totalBeforeDiscount - discountAmount;

      if (discountedValue < 0) {
        throw Exception("Discount amount cannot be greater than total amount");
      }

      // Rate structure calculation - same as sales order
      final rateStructureDetails = widget.service.buildRateStructureDetails(
        rateStructureRows,
        selectedItem?.itemCode ?? "TEMP",
        1,
      );

      final rateStructureResponse = await widget.service.calculateRateStructure(
        discountedValue,
        selectedRateStructure!,
        rateStructureDetails,
        selectedItem?.itemCode ?? "TEMP",
      );

      if (rateStructureResponse['success'] == true) {
        final data = rateStructureResponse['data'];

        // Get both calculated and complete rate structure details
        final List<dynamic> calculatedRateDetails =
            data['listCalcRateReturnDetails'] ?? [];
        final List<dynamic> completeRateStructure =
            data['rateStructureDetails'] ?? [];

        debugPrint("Calculated Rate Details: $calculatedRateDetails");
        debugPrint("Complete Rate Structure: $completeRateStructure");

        // Update rateAmount in completeRateStructure by matching rateCode
        double totalTax = 0.0;

        for (final completeDetail in completeRateStructure) {
          final rateCode = completeDetail['rateCode'];

          // Find matching calculated rate detail
          final calculatedDetail = calculatedRateDetails.firstWhere(
            (calc) => calc['rateCode'] == rateCode,
            orElse: () => null,
          );

          // Update rateAmount from calculated details if found
          if (calculatedDetail != null) {
            final calculatedAmount =
                (calculatedDetail['rateAmount'] ?? 0.0).toDouble();
            completeDetail['rateAmount'] = calculatedAmount;
            totalTax += calculatedAmount;

            debugPrint(
              "Rate Code: $rateCode, Updated Amount: $calculatedAmount",
            );
          } else {
            // Keep original rateAmount if no calculated amount found
            final originalAmount =
                (completeDetail['rateAmount'] ?? 0.0).toDouble();
            totalTax += originalAmount;

            debugPrint(
              "Rate Code: $rateCode, Original Amount: $originalAmount",
            );
          }
        }

        debugPrint("Final Rate Structure: $completeRateStructure");
        debugPrint("Total Tax Amount: $totalTax");

        final totalAmount = discountedValue + totalTax;

        final item = ProformaItem(
          discountCode: selectedDiscountCode?.code ?? '',
          itemName: itemNameController.text,
          itemCode: selectedItem?.itemCode ?? "TEMP",
          qty: qty,
          basicRate: basicRate,
          uom: selectedItem?.salesUOM ?? "NOS",
          discountType: discountType,
          discountPercentage:
              discountType == "Percentage" ? discountPercentage : null,
          discountAmount: discountAmount > 0 ? discountAmount : null,
          rateStructure: selectedRateStructure!,
          taxAmount: totalTax,
          totalAmount: totalAmount,
          // Pass the updated complete rate structure instead of calculated one
          rateStructureRows: List<Map<String, dynamic>>.from(
            completeRateStructure,
          ),
          lineNo: 0, // will be set in main form
          hsnAccCode: selectedItem?.hsnCode ?? '',
        );

        Navigator.pop(context, item);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${rateStructureResponse['errorMessage'] ?? 'Calculation failed'}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error in _addItem: $e");
      debugPrint("Stack trace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error calculating item: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
