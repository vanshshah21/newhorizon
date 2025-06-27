// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
// import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
// import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import '../../../utils/storage_utils.dart';

// class EditProformaInvoiceForm extends StatefulWidget {
//   final int invSiteId;
//   final String invYear;
//   final String invGroup;
//   final String invNumber;
//   final String piOn;
//   final int fromLocationId;
//   final String custCode;

//   const EditProformaInvoiceForm({
//     super.key,
//     required this.invSiteId,
//     required this.invYear,
//     required this.invGroup,
//     required this.invNumber,
//     required this.piOn,
//     required this.fromLocationId,
//     required this.custCode,
//   });

//   @override
//   State<EditProformaInvoiceForm> createState() =>
//       _EditProformaInvoiceFormState();
// }

// class _EditProformaInvoiceFormState extends State<EditProformaInvoiceForm> {
//   late ProformaInvoiceService _service;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController customerController = TextEditingController();

//   String? selectPreference;
//   DateTime? selectedDate;
//   Customer? selectedCustomer;
//   String? selectedQuotationNumber;
//   String? selectedSalesOrderNumber;
//   List<QuotationNumber> quotationNumbers = [];
//   List<SalesOrderNumber> salesOrderNumbers = [];
//   List<ProformaItem> items = [];
//   List<RateStructure> rateStructures = [];
//   late Map<String, dynamic>? companyDetails;
//   late Map<String, dynamic>? locationDetails;
//   late Map<String, dynamic>? userDetails;
//   late Map<String, dynamic>? _financeDetails;
//   List<Map<String, dynamic>> _rsGrid = [];
//   List<Map<String, dynamic>> _discountDetails = [];
//   late DateTime startDate;
//   late DateTime endDate;

//   final List<String> preferenceOptions = [
//     "On Quotation",
//     "On Sales Order",
//     "On Other",
//   ];

//   bool _isLoading = true;

//   // For update payload
//   late Map<String, dynamic> _headerDetail;

//   @override
//   void initState() {
//     super.initState();
//     _initializeForm();
//   }

//   Future<void> _initializeForm() async {
//     _service = await ProformaInvoiceService.create();
//     await _loadFinancePeriod();
//     await _loadRateStructures();
//     companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) {
//       _showError("Company details not found.");
//       return;
//     }
//     locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) {
//       _showError("Location details not found.");
//       return;
//     }
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     userDetails = tokenDetails?['user'];
//     if (userDetails == null) {
//       _showError("User details not found.");
//       return;
//     }
//     await _loadProformaData();
//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadFinancePeriod() async {
//     try {
//       _financeDetails = await StorageUtils.readJson('finance_period');
//       if (_financeDetails != null) {
//         startDate = DateTime.parse(_financeDetails!['periodSDt']);
//         endDate = DateTime.parse(_financeDetails!['periodEDt']);
//       }
//     } catch (e) {
//       startDate = DateTime.now().subtract(const Duration(days: 365));
//       endDate = DateTime.now();
//     }
//   }

//   Future<void> _loadRateStructures() async {
//     try {
//       final companyDetails = await StorageUtils.readJson('selected_company');
//       if (companyDetails == null) {
//         _showError("Company details not found.");
//         return;
//       }
//       final companyId = companyDetails['id'];
//       rateStructures = await _service.fetchRateStructures(companyId);
//     } catch (e) {
//       _showError("Failed to load rate structures: ${e.toString()}");
//     }
//   }

//   Future<void> _loadProformaData() async {
//     try {
//       final data = await _service.fetchProformaInvoiceDetails(
//         invSiteId: widget.invSiteId,
//         invYear: widget.invYear,
//         invGroup: widget.invGroup,
//         invNumber: widget.invNumber,
//         piOn: widget.piOn,
//         fromLocationId: widget.fromLocationId,
//         custCode: widget.custCode,
//       );

//       final header = data['headerDetail'];
//       final itemList = List<Map<String, dynamic>>.from(
//         data['gridDetail']['itemDetail'] ?? [],
//       );
//       final rateStructDetail = List<Map<String, dynamic>>.from(
//         data['gridDetail']['rateStructDetail'] ?? [],
//       );
//       final discountDetail = List<Map<String, dynamic>>.from(
//         data['gridDetail']['discountDetail'] ?? [],
//       );

//       // Prefill form fields
//       setState(() {
//         _headerDetail = header;
//         selectedDate = DateTime.parse(header['invIssueDate']);
//         dateController.text = FormatUtils.formatDateForUser(selectedDate!);
//         selectedCustomer = Customer(
//           customerCode: header['invCustCode'] ?? '',
//           customerName: header['customerName'] ?? '',
//           gstNumber: '', // If available
//           telephoneNo: '', // If available
//           customerFullName: header['customerName'] ?? '',
//         );
//         customerController.text = selectedCustomer!.customerName;
//         selectPreference = _mapInvOnToPreference(header['invOn']);
//         items =
//             itemList
//                 .asMap()
//                 .entries
//                 .map((e) => _mapItemDetailToProformaItem(e.value, e.key + 1))
//                 .toList();
//         _rsGrid = rateStructDetail;
//         _discountDetails = discountDetail;
//       });

//       // If needed, load quotation/sales order numbers for dropdowns
//       if (selectPreference == "On Quotation" && selectedCustomer != null) {
//         quotationNumbers = await _service.fetchQuotationNumberList(
//           selectedCustomer!.customerCode,
//         );
//       }
//       if (selectPreference == "On Sales Order" && selectedCustomer != null) {
//         salesOrderNumbers = await _service.fetchSalesOrderNumberList(
//           selectedCustomer!.customerCode,
//         );
//       }
//     } catch (e) {
//       _showError("Failed to load proforma: ${e.toString()}");
//     }
//   }

//   String _mapInvOnToPreference(String? invOn) {
//     switch (invOn) {
//       case "Q":
//         return "On Quotation";
//       case "O":
//         return "On Sales Order";
//       default:
//         return "On Other";
//     }
//   }

//   ProformaItem _mapItemDetailToProformaItem(
//     Map<String, dynamic> item,
//     int lineNo,
//   ) {
//     return ProformaItem(
//       itemName: item['itemName'] ?? '',
//       itemCode: item['itemCode'] ?? '',
//       qty: (item['qty'] ?? 0).toDouble(),
//       basicRate: (item['itemRate'] ?? 0).toDouble(),
//       uom: item['suom'] ?? 'NOS',
//       discountType:
//           (item['invDiscountType'] ?? 'None') == 'N'
//               ? 'None'
//               : item['invDiscountType'],
//       discountAmount: (item['discountAmount'] ?? 0).toDouble(),
//       discountPercentage: null, // If you have percentage, map it here
//       rateStructure: item['rateStructureCode'] ?? '',
//       taxAmount: (item['totalTax'] ?? 0).toDouble(),
//       totalAmount: (item['totalValue'] ?? 0).toDouble(),
//       rateStructureRows: null, // You can map from rateStructDetail if needed
//       lineNo: lineNo,
//       hsnAccCode: item['hsnAccCode'] ?? '',
//     );
//   }

//   Future<void> _onPreferenceChanged(String? value) async {
//     if (value == null) return;

//     setState(() {
//       selectPreference = value;
//       customerController.clear();
//       selectedCustomer = null;
//       selectedQuotationNumber = null;
//       selectedSalesOrderNumber = null;
//       quotationNumbers.clear();
//       salesOrderNumbers.clear();
//       items.clear();
//       _rsGrid.clear();
//       _discountDetails.clear();
//     });

//     try {
//       if (value == "On Quotation") {
//         await _service.fetchDefaultDocumentDetail("SQ");
//       } else if (value == "On Sales Order") {
//         await _service.fetchDefaultDocumentDetail("OB");
//       }
//     } catch (e) {
//       _showError("Failed to load document details: ${e.toString()}");
//     }
//   }

//   Future<void> _onCustomerSelected(Customer customer) async {
//     setState(() {
//       selectedCustomer = customer;
//       customerController.text = customer.customerName;
//       quotationNumbers.clear();
//       salesOrderNumbers.clear();
//       selectedQuotationNumber = null;
//       selectedSalesOrderNumber = null;
//       items.clear();
//     });

//     if (selectPreference == "On Quotation") {
//       await _loadQuotationNumbers(customer.customerCode);
//     } else if (selectPreference == "On Sales Order") {
//       await _loadSalesOrderNumbers(customer.customerCode);
//     }
//   }

//   Future<void> _loadQuotationNumbers(String customerCode) async {
//     try {
//       setState(() => _isLoading = true);
//       quotationNumbers = await _service.fetchQuotationNumberList(customerCode);
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError("Failed to load quotation numbers: ${e.toString()}");
//     }
//   }

//   Future<void> _loadSalesOrderNumbers(String customerCode) async {
//     try {
//       setState(() => _isLoading = true);
//       salesOrderNumbers = await _service.fetchSalesOrderNumberList(
//         customerCode,
//       );
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError("Failed to load sales order numbers: ${e.toString()}");
//     }
//   }

//   Future<void> _showAddItemPage() async {
//     final result = await Navigator.push<ProformaItem>(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) =>
//                 AddItemPage(service: _service, rateStructures: rateStructures),
//       ),
//     );

//     if (result != null) {
//       setState(() {
//         result.lineNo = items.length + 1;
//         items.add(result);
//       });
//     }
//   }

//   void _removeItem(int index) {
//     setState(() {
//       items.removeAt(index);
//       // Reassign line numbers
//       for (int i = 0; i < items.length; i++) {
//         items[i] = ProformaItem(
//           itemName: items[i].itemName,
//           itemCode: items[i].itemCode,
//           qty: items[i].qty,
//           basicRate: items[i].basicRate,
//           uom: items[i].uom,
//           discountType: items[i].discountType,
//           discountPercentage: items[i].discountPercentage,
//           discountAmount: items[i].discountAmount,
//           rateStructure: items[i].rateStructure,
//           taxAmount: items[i].taxAmount,
//           totalAmount: items[i].totalAmount,
//           rateStructureRows: items[i].rateStructureRows,
//           lineNo: i + 1,
//           hsnAccCode: items[i].hsnAccCode,
//         );
//       }
//     });
//   }

//   double _calculateTotalBasic() {
//     return items.fold(0.0, (sum, item) => sum + (item.basicRate * item.qty));
//   }

//   double _calculateTotalDiscount() {
//     return items.fold(0.0, (sum, item) => sum + (item.discountAmount ?? 0.0));
//   }

//   double _calculateTotalTax() {
//     return items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0.0));
//   }

//   double _calculateTotalAmount() {
//     return items.fold(0.0, (sum, item) => sum + item.totalAmount);
//   }

//   Map<String, dynamic> _buildSubmissionPayload() {
//     if (userDetails?['id'] == null) throw Exception("User ID is null");
//     if (locationDetails?['id'] == null) throw Exception("Location ID is null");
//     if (locationDetails?['code'] == null) {
//       throw Exception("Location code is null");
//     }
//     if (selectedCustomer == null) throw Exception("Customer is null");

//     List<Map<String, dynamic>> itemDetails = [];
//     List<Map<String, dynamic>> rsGrid = [];
//     List<Map<String, dynamic>> discountDetails = [];

//     double totalBasic = 0.0;
//     double totalTax = 0.0;
//     double totalAmount = 0.0;
//     double totalDiscount = 0.0;

//     final userId = userDetails?['id'] ?? 0;
//     final locationId = locationDetails?['id'] ?? 0;
//     final locationCode = locationDetails?['code'] ?? "";

//     // Build item details
//     for (int i = 0; i < items.length; i++) {
//       final item = items[i];
//       final lineNo = i + 1;

//       final itemJson = item.toSubmissionJson(userId, locationId);
//       itemJson['lineNo'] = lineNo;
//       itemJson['seqNo'] = lineNo;
//       itemDetails.add(itemJson);

//       totalBasic += (item.basicRate * item.qty);
//       totalTax += (item.taxAmount ?? 0.0);
//       totalAmount += item.totalAmount;
//       totalDiscount += (item.discountAmount ?? 0.0);
//     }

//     // Use pre-populated rsGrid and discountDetails, but update refLine numbers if needed
//     rsGrid =
//         _rsGrid.map((rs) {
//           // Find the corresponding item to get the correct line number
//           final itemIndex = items.indexWhere(
//             (item) => item.itemCode == rs['xdtdtmcd'],
//           );
//           if (itemIndex != -1) {
//             rs['refLine'] = itemIndex + 1;
//           }
//           return Map<String, dynamic>.from(rs);
//         }).toList();

//     discountDetails =
//         _discountDetails.map((disc) {
//           // Find the corresponding item to get the correct line number
//           final itemIndex = items.indexWhere(
//             (item) => item.itemCode == disc['itemCode'],
//           );
//           if (itemIndex != -1) {
//             disc['oditmlineno'] = itemIndex + 1;
//           }
//           return Map<String, dynamic>.from(disc);
//         }).toList();

//     // For manually added items (when preference is "On Other"), we need to add their rate structure details
//     if (selectPreference == "On Other") {
//       for (int i = 0; i < items.length; i++) {
//         final item = items[i];
//         final lineNo = i + 1;

//         // Add rate structure details for manually added items
//         if (item.rateStructureRows != null) {
//           for (final row in item.rateStructureRows!) {
//             rsGrid.add({
//               "docType": "PI",
//               "docSubType": "PI",
//               "xdtdtmcd": item.itemCode,
//               "rateCode": row['msprtcd'],
//               "rateStructCode": item.rateStructure,
//               "rateAmount": row['rateAmount'] ?? 0,
//               "amdSrNo": 0,
//               "perCValue": row['msprtval']?.toString() ?? "0.00",
//               "incExc": row['mspincexc'],
//               "perVal": row['mspperval'],
//               "appliedOn": row['mtrslvlno'] ?? "",
//               "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
//               "seqNo": row['mspseqno']?.toString() ?? "1",
//               "curCode": row['mprcurcode'] ?? "INR",
//               "fromLocationId": locationId,
//               "TaxTyp": row['mprtaxtyp'],
//               "refLine": lineNo,
//             });
//           }
//         }

//         // Add discount details for manually added items
//         if (item.discountAmount != null && item.discountAmount! > 0) {
//           discountDetails.add({
//             "itemCode": item.itemCode,
//             "currCode": "INR",
//             "discCode": "01",
//             "discType": item.discountType,
//             "discVal":
//                 item.discountType == "Percentage"
//                     ? item.discountPercentage ?? 0
//                     : item.discountAmount ?? 0,
//             "fromLocationId": locationId,
//             "oditmlineno": lineNo,
//           });
//         }
//       }
//     }

//     // Generate itemHeaderDetial
//     final itemHeaderDetial = _buildItemHeaderDetail(
//       totalAmount,
//       totalTax,
//       totalDiscount,
//       userId,
//       locationId,
//       locationCode,
//     );

//     // Add unique identifiers for update
//     itemHeaderDetial['invNumber'] = _headerDetail['invNumber'];
//     itemHeaderDetial['invYear'] = _headerDetail['invYear'];
//     itemHeaderDetial['invGroup'] = _headerDetail['invGroup'];
//     itemHeaderDetial['invSite'] = _headerDetail['invSite'];

//     return {
//       "action": "edit",
//       "autoNoRequired": "N",
//       "customerPoNumber": null,
//       "customerPoDate": null,
//       "itemHeaderDetial": itemHeaderDetial,
//       "itemDetail": itemDetails,
//       "rsGrid": rsGrid,
//       "discountDetail": discountDetails,
//       "termsDetail": [], // You can map terms if needed
//       "standardTerms": [],
//       "chargesDetail": [],
//       "remark": [],
//     };
//   }

//   Map<String, dynamic> _buildItemHeaderDetail(
//     double totalAmount,
//     double totalTax,
//     double totalDiscount,
//     int userId,
//     int locationId,
//     String locationCode,
//   ) {
//     final financeDetails = _financeDetails ?? {};
//     final financialYear = financeDetails['financialYear'] ?? "25-26";

//     String discountType = "None";
//     if (items.isNotEmpty) {
//       final firstItemDiscountType = items.first.discountType;
//       final allSameDiscountType = items.every(
//         (item) => item.discountType == firstItemDiscountType,
//       );
//       discountType = allSameDiscountType ? firstItemDiscountType : "Mixed";
//     }

//     final netAmount = totalAmount - totalDiscount;
//     final finalAmount = netAmount + totalTax;

//     return {
//       "autoId": _headerDetail['autoId'] ?? 0,
//       "invYear": _headerDetail['invYear'] ?? financialYear,
//       "invGroup": _headerDetail['invGroup'] ?? "PI",
//       "invSite": _headerDetail['invSite'] ?? locationId,
//       "invSiteCode": _headerDetail['invSiteCode'] ?? locationCode,
//       "invIssueDate":
//           selectedDate != null
//               ? FormatUtils.formatDateForApi(selectedDate!)
//               : "",
//       "invValue": netAmount,
//       "invAmount": finalAmount,
//       "invRoValue": finalAmount.round(),
//       "invTax": totalTax,
//       "invType": "M",
//       "invCustCode": selectedCustomer!.customerCode,
//       "invStatus": "O",
//       "invOn":
//           selectPreference == "On Quotation"
//               ? "Q"
//               : selectPreference == "On Sales Order"
//               ? "O"
//               : "T",
//       "invDiscountType": discountType,
//       "invDiscountValue": totalDiscount,
//       "invFromLocationId": locationId,
//       "invCreatedUserId": userId,
//       "invCurrCode": "INR",
//       "invRate": 1.0,
//       "invNumber": _headerDetail['invNumber'],
//       "invBacAmount": netAmount,
//       "invSiteReq": "Y",
//     };
//   }

//   Future<void> _updateProformaInvoice() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_validateForm()) return;

//     final confirmed = await _showConfirmationDialog();
//     if (!confirmed) return;

//     try {
//       setState(() => _isLoading = true);

//       final payload = _buildSubmissionPayload();

//       final success = await _service.updateProformaInvoice(payload);

//       setState(() => _isLoading = false);

//       if (success) {
//         _showSuccess("Proforma Invoice updated successfully");
//         Navigator.pop(context, true);
//       } else {
//         _showError("Failed to update Proforma Invoice");
//       }
//     } catch (e, st) {
//       setState(() => _isLoading = false);
//       debugPrint("Error stacktrace during update: $st");
//       _showError("Error during update: ${e.toString()}");
//     }
//   }

//   bool _validateForm() {
//     if (selectPreference == null) {
//       _showError("Please select a preference");
//       return false;
//     }

//     if (selectedDate == null) {
//       _showError("Please select a date");
//       return false;
//     }

//     if (selectedCustomer == null) {
//       _showError("Please select a customer");
//       return false;
//     }

//     if (selectPreference == "On Quotation" && selectedQuotationNumber == null) {
//       _showError("Please select a quotation number");
//       return false;
//     }

//     if (selectPreference == "On Sales Order" &&
//         selectedSalesOrderNumber == null) {
//       _showError("Please select a sales order number");
//       return false;
//     }

//     if (items.isEmpty) {
//       _showError("Please add at least one item");
//       return false;
//     }

//     return true;
//   }

//   Future<bool> _showConfirmationDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text("Confirm Update"),
//                 content: const Text(
//                   "Are you sure you want to update this Proforma Invoice?",
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text("Cancel"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     child: const Text("Update"),
//                   ),
//                 ],
//               ),
//         ) ??
//         false;
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Proforma Invoice"), elevation: 1),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildPreferenceDropdown(),
//                       const SizedBox(height: 16),
//                       _buildDateField(),
//                       const SizedBox(height: 16),
//                       _buildCustomerField(),
//                       const SizedBox(height: 16),
//                       if (selectPreference == "On Quotation") ...[
//                         _buildQuotationDropdown(),
//                         const SizedBox(height: 16),
//                       ],
//                       if (selectPreference == "On Sales Order") ...[
//                         _buildSalesOrderDropdown(),
//                         const SizedBox(height: 16),
//                       ],
//                       if (items.isNotEmpty) ...[
//                         _buildItemsList(),
//                         const SizedBox(height: 16),
//                       ],
//                       _buildAddItemButton(),
//                       const SizedBox(height: 16),
//                       if (items.isNotEmpty) ...[
//                         _buildTotalCard(),
//                         const SizedBox(height: 24),
//                       ],
//                       _buildSubmitButton(),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildPreferenceDropdown() {
//     return DropdownButtonFormField<String>(
//       decoration: const InputDecoration(
//         labelText: "Select Preference",
//         border: OutlineInputBorder(),
//       ),
//       value: selectPreference,
//       items:
//           preferenceOptions
//               .map(
//                 (pref) =>
//                     DropdownMenuItem<String>(value: pref, child: Text(pref)),
//               )
//               .toList(),
//       onChanged: _onPreferenceChanged,
//       validator: (val) => val == null ? "Select Preference is required" : null,
//     );
//   }

//   Widget _buildDateField() {
//     return TextFormField(
//       controller: dateController,
//       decoration: const InputDecoration(
//         labelText: "Date",
//         suffixIcon: Icon(Icons.calendar_today),
//         border: OutlineInputBorder(),
//       ),
//       readOnly: true,
//       onTap: () async {
//         final picked = await showDatePicker(
//           context: context,
//           initialDate: selectedDate ?? DateTime.now(),
//           firstDate: startDate,
//           lastDate: DateTime.now(),
//         );
//         if (picked != null) {
//           setState(() {
//             selectedDate = picked;
//             dateController.text = FormatUtils.formatDateForUser(picked);
//           });
//         }
//       },
//       validator:
//           (val) => val == null || val.isEmpty ? "Date is required" : null,
//     );
//   }

//   Widget _buildCustomerField() {
//     return TypeAheadField<Customer>(
//       debounceDuration: const Duration(milliseconds: 400),
//       controller: customerController,
//       builder: (context, controller, focusNode) {
//         return TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           decoration: const InputDecoration(
//             labelText: "Customer Name",
//             border: OutlineInputBorder(),
//           ),
//           validator:
//               (val) =>
//                   val == null || val.isEmpty
//                       ? "Customer Name is required"
//                       : null,
//         );
//       },
//       suggestionsCallback: (pattern) async {
//         if (pattern.length < 4) return [];
//         try {
//           return await _service.fetchCustomerSuggestions(pattern);
//         } catch (e) {
//           return [];
//         }
//       },
//       itemBuilder: (context, suggestion) {
//         return ListTile(
//           title: Text(suggestion.customerName),
//           subtitle: Text(suggestion.customerCode),
//         );
//       },
//       onSelected: _onCustomerSelected,
//     );
//   }

//   Widget _buildQuotationDropdown() {
//     return DropdownButtonFormField<String>(
//       decoration: const InputDecoration(
//         labelText: "Quotation Number",
//         border: OutlineInputBorder(),
//       ),
//       value: selectedQuotationNumber,
//       items:
//           quotationNumbers
//               .map(
//                 (qn) => DropdownMenuItem<String>(
//                   value: qn.number,
//                   child: Text(qn.number),
//                 ),
//               )
//               .toList(),
//       onChanged: (val) {
//         setState(() {
//           selectedQuotationNumber = val;
//         });
//       },
//       validator: (val) => val == null ? "Quotation Number is required" : null,
//     );
//   }

//   Widget _buildSalesOrderDropdown() {
//     return DropdownButtonFormField<String>(
//       decoration: const InputDecoration(
//         labelText: "Sales Order Number",
//         border: OutlineInputBorder(),
//       ),
//       value: selectedSalesOrderNumber,
//       items:
//           salesOrderNumbers
//               .map(
//                 (so) => DropdownMenuItem<String>(
//                   value: so.number,
//                   child: Text(so.number),
//                 ),
//               )
//               .toList(),
//       onChanged: (val) {
//         setState(() {
//           selectedSalesOrderNumber = val;
//         });
//       },
//       validator: (val) => val == null ? "Sales Order Number is required" : null,
//     );
//   }

//   Widget _buildItemsList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Items:",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//             return Card(
//               child: ListTile(
//                 title: Text(item.itemName),
//                 subtitle: Text(
//                   "Qty: ${item.qty} ${item.uom}\nRate: ₹${item.basicRate.toStringAsFixed(2)}\nTotal: ₹${item.totalAmount.toStringAsFixed(2)}",
//                 ),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.delete, color: Colors.red),
//                   onPressed: () => _removeItem(index),
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildAddItemButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: _showAddItemPage,
//         icon: const Icon(Icons.add),
//         label: const Text("Add New Item"),
//       ),
//     );
//   }

//   Widget _buildTotalCard() {
//     final totalBasic = _calculateTotalBasic();
//     final totalDiscount = _calculateTotalDiscount();
//     final totalTax = _calculateTotalTax();
//     final netAmount = totalBasic - totalDiscount;
//     final finalAmount = netAmount + totalTax;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Total Summary",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Basic Amount:"),
//                 Text("₹${totalBasic.toStringAsFixed(2)}"),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Discount Value:"),
//                 Text("₹${totalDiscount.toStringAsFixed(2)}"),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Net Amount:"),
//                 Text("₹${netAmount.toStringAsFixed(2)}"),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Tax Amount:"),
//                 Text("₹${totalTax.toStringAsFixed(2)}"),
//               ],
//             ),
//             const Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Total Amount:",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "₹${finalAmount.toStringAsFixed(2)}",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSubmitButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _updateProformaInvoice,
//         child: const Text("Update Proforma Invoice"),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     dateController.dispose();
//     customerController.dispose();
//     super.dispose();
//   }
// }
