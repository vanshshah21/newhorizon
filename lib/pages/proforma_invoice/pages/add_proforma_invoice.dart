// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
// import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
// import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';
// import '../../../utils/storage_utils.dart';

// class AddProformaInvoiceForm extends StatefulWidget {
//   const AddProformaInvoiceForm({super.key});

//   @override
//   _AddProformaInvoiceFormState createState() => _AddProformaInvoiceFormState();
// }

// class _AddProformaInvoiceFormState extends State<AddProformaInvoiceForm> {
//   final ProformaInvoiceService _service = ProformaInvoiceService();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // Form Controllers
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController customerController = TextEditingController();

//   // Form State Variables
//   String? selectPreference;
//   DateTime? selectedDate;
//   Customer? selectedCustomer;
//   String? selectedQuotationNumber;
//   String? selectedSalesOrderNumber;
//   List<QuotationNumber> quotationNumbers = [];
//   List<SalesOrderNumber> salesOrderNumbers = [];
//   List<ProformaItem> items = [];
//   List<RateStructure> rateStructures = [];

//   // Constants
//   final List<String> preferenceOptions = [
//     "On Quotation",
//     "On Sales Order",
//     "On Other",
//   ];

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeForm();
//   }

//   Future<void> _initializeForm() async {
//     await _loadFinancePeriod();
//     await _loadRateStructures();
//   }

//   Future<void> _loadFinancePeriod() async {
//     try {
//       final financePeriod = await StorageUtils.readJson('finance_period');
//       if (financePeriod != null) {
//         final startDate = DateTime.parse(financePeriod['periodSDt']);
//         final endDate = DateTime.parse(financePeriod['periodEDt']);
//         final now = DateTime.now();

//         selectedDate = now.isAfter(endDate) ? endDate : now;
//         dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
//         setState(() {});
//       }
//     } catch (e) {
//       _setDefaultDate();
//     }
//   }

//   void _setDefaultDate() {
//     selectedDate = DateTime.now();
//     dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
//     setState(() {});
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
//       setState(() {});
//     } catch (e) {
//       _showError("Failed to load rate structures: ${e.toString()}");
//     }
//   }

//   Future<void> _onPreferenceChanged(String? value) async {
//     if (value == null) return;

//     setState(() {
//       selectPreference = value;
//       selectedQuotationNumber = null;
//       selectedSalesOrderNumber = null;
//       quotationNumbers.clear();
//       salesOrderNumbers.clear();
//       items.clear();
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

//   Future<void> _onQuotationSelected(String? quotationNumber) async {
//     if (quotationNumber == null) return;

//     setState(() {
//       selectedQuotationNumber = quotationNumber;
//       items.clear();
//       _isLoading = true;
//     });

//     try {
//       final details = await _service.fetchQuotationDetails(quotationNumber);
//       items =
//           details.itemDetail
//               .map((item) => ProformaItem.fromQuotationItem(item))
//               .toList();
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError("Failed to load quotation details: ${e.toString()}");
//     }
//   }

//   Future<void> _onSalesOrderSelected(String? salesOrderNumber) async {
//     if (salesOrderNumber == null) return;

//     setState(() {
//       selectedSalesOrderNumber = salesOrderNumber;
//       items.clear();
//       _isLoading = true;
//     });

//     try {
//       final details = await _service.fetchSalesOrderDetails(salesOrderNumber);
//       items =
//           details.itemDetail
//               .map((item) => ProformaItem.fromSalesOrderItem(item))
//               .toList();
//       setState(() => _isLoading = false);
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError("Failed to load sales order details: ${e.toString()}");
//     }
//   }

//   Future<void> _showAddItemDialog() async {
//     final result = await showDialog<ProformaItem>(
//       context: context,
//       builder:
//           (context) =>
//               AddItemDialog(service: _service, rateStructures: rateStructures),
//     );

//     if (result != null) {
//       setState(() {
//         items.add(result);
//       });
//     }
//   }

//   void _removeItem(int index) {
//     setState(() {
//       items.removeAt(index);
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

//   Future<void> _submitProformaInvoice() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (!_validateForm()) return;

//     final confirmed = await _showConfirmationDialog();
//     if (!confirmed) return;

//     try {
//       setState(() => _isLoading = true);

//       final payload = _buildSubmissionPayload();
//       final success = await _service.submitProformaInvoice(payload);

//       setState(() => _isLoading = false);

//       if (success) {
//         _showSuccess("Proforma Invoice submitted successfully");
//         Navigator.pop(context, true);
//       } else {
//         _showError("Failed to submit Proforma Invoice");
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError("Error during submission: ${e.toString()}");
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

//   Map<String, dynamic> _buildSubmissionPayload() {
//     return {
//       "Action": "add",
//       "CustomerPoNumber": "",
//       "ExchangeRate": 0,
//       "StandardTerms": [],
//       "autoNoRequired": "Y",
//       "chargesDetail": [],
//       "discountDetail":
//           items
//               .where(
//                 (item) =>
//                     item.discountAmount != null && item.discountAmount! > 0,
//               )
//               .map(
//                 (item) => {
//                   "currCode": "INR",
//                   "discCode": "01",
//                   "discType": item.discountType,
//                   "discVal":
//                       item.discountType == "Percentage"
//                           ? item.discountPercentage ?? 0
//                           : item.discountAmount ?? 0,
//                   "fromLocationId": 0,
//                   "invId": 0,
//                   "itemCode": item.itemCode,
//                 },
//               )
//               .toList(),
//       "itemDetail": items.map((item) => item.toSubmissionJson()).toList(),
//       "itemHeaderDetial": {
//         "ExchangeRate": 0,
//         "autoId": 0,
//         "invAmount": _calculateTotalAmount(),
//         "invBacAmount": _calculateTotalBasic(),
//         "invCreatedUserId": 2,
//         "invCurrCode": "INR",
//         "invCustCode": selectedCustomer?.customerCode ?? "",
//         "invDiscountType": "",
//         "invDiscountValue": 0,
//         "invFromLocationId": 8,
//         "invGroup": "PI",
//         "invIssueDate": selectedDate!.toIso8601String(),
//         "invNumber": "",
//         "invOn": "T",
//         "invSite": 8,
//         "invSiteCode": "CT2",
//         "invSiteReq": "Y",
//         "invStatus": "T",
//         "invTax": _calculateTotalTax(),
//         "invType": "M",
//         "invValue": _calculateTotalAmount(),
//         "invYear": "24-25",
//       },
//       "remark": [],
//       "rsGrid": [],
//       "termsDetail": [],
//       "transportDetail": {},
//     };
//   }

//   Future<bool> _showConfirmationDialog() async {
//     return await showDialog<bool>(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: const Text("Confirm Submission"),
//                 content: const Text(
//                   "Are you sure you want to submit this Proforma Invoice?",
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text("Cancel"),
//                   ),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     child: const Text("Submit"),
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
//       appBar: AppBar(title: const Text("Add Proforma Invoice"), elevation: 1),
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
//                       if (selectPreference == "On Other") ...[
//                         _buildAddItemButton(),
//                         const SizedBox(height: 16),
//                       ],
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
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//         );
//         if (picked != null) {
//           setState(() {
//             selectedDate = picked;
//             dateController.text = "${picked.toLocal()}".split(' ')[0];
//           });
//         }
//       },
//       validator:
//           (val) => val == null || val.isEmpty ? "Date is required" : null,
//     );
//   }

//   Widget _buildCustomerField() {
//     return TypeAheadField<Customer>(
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
//      : selectedQuotationNumber,
//       items:
//           quotationNumbers
//               .map(
//                 (qn) => DropdownMenuItem<String>(
//                   value: qn.number,
//                   child: Text(qn.number),
//                 ),
//               )
//               .toList(),
//       onChanged: _onQuotationSelected,
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
//       onChanged: _onSalesOrderSelected,
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
//         onPressed: _showAddItemDialog,
//         icon: const Icon(Icons.add),
//         label: const Text("Add New Item"),
//       ),
//     );
//   }

//   Widget _buildTotalCard() {
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
//                 Text("₹${_calculateTotalBasic().toStringAsFixed(2)}"),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Discount Value:"),
//                 Text("₹${_calculateTotalDiscount().toStringAsFixed(2)}"),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Tax Amount:"),
//                 Text("₹${_calculateTotalTax().toStringAsFixed(2)}"),
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
//                   "₹${_calculateTotalAmount().toStringAsFixed(2)}",
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
//         onPressed: _submitProformaInvoice,
//         child: const Text("Submit Proforma Invoice"),
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

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/pages/add_item_page.dart';
import 'package:nhapp/pages/proforma_invoice/service/add_proforma_invoice.dart';
import 'package:nhapp/utils/format_utils.dart';
import '../../../utils/storage_utils.dart';

class AddProformaInvoiceForm extends StatefulWidget {
  const AddProformaInvoiceForm({super.key});

  @override
  State<AddProformaInvoiceForm> createState() => _AddProformaInvoiceFormState();
}

class _AddProformaInvoiceFormState extends State<AddProformaInvoiceForm> {
  late ProformaInvoiceService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();

  String? selectPreference;
  DateTime? selectedDate;
  Customer? selectedCustomer;
  String? selectedQuotationNumber;
  String? selectedSalesOrderNumber;
  List<QuotationNumber> quotationNumbers = [];
  List<SalesOrderNumber> salesOrderNumbers = [];
  List<ProformaItem> items = [];
  List<RateStructure> rateStructures = [];
  late Map<String, dynamic>? companyDetails;
  late Map<String, dynamic>? locationDetails;
  late Map<String, dynamic>? userDetails;

  final List<String> preferenceOptions = [
    "On Quotation",
    "On Sales Order",
    "On Other",
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await ProformaInvoiceService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) {
      _showError("Company details not found.");
      return;
    }
    locationDetails = await StorageUtils.readJson('selected_location');
    debugPrint("Location Details: $locationDetails");
    if (locationDetails == null) {
      _showError("Location details not found.");
      return;
    }
    final tokenDetails = await StorageUtils.readJson('session_token');
    userDetails = tokenDetails?['user'];
    if (userDetails == null) {
      _showError("User details not found.");
      return;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadFinancePeriod() async {
    try {
      final financePeriod = await StorageUtils.readJson('finance_period');
      if (financePeriod != null) {
        final startDate = DateTime.parse(financePeriod['periodSDt']);
        final endDate = DateTime.parse(financePeriod['periodEDt']);
        final now = DateTime.now();

        selectedDate = now.isAfter(endDate) ? endDate : now;
        dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
      }
    } catch (e) {
      _setDefaultDate();
    }
  }

  void _setDefaultDate() {
    selectedDate = DateTime.now();
    dateController.text = "${selectedDate!.toLocal()}".split(' ')[0];
  }

  Future<void> _loadRateStructures() async {
    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) {
        _showError("Company details not found.");
        return;
      }
      final companyId = companyDetails['id'];
      rateStructures = await _service.fetchRateStructures(companyId);
    } catch (e) {
      _showError("Failed to load rate structures: ${e.toString()}");
    }
  }

  Future<void> _onPreferenceChanged(String? value) async {
    if (value == null) return;

    setState(() {
      selectPreference = value;
      selectedQuotationNumber = null;
      selectedSalesOrderNumber = null;
      quotationNumbers.clear();
      salesOrderNumbers.clear();
      items.clear();
    });

    try {
      if (value == "On Quotation") {
        await _service.fetchDefaultDocumentDetail("SQ");
      } else if (value == "On Sales Order") {
        await _service.fetchDefaultDocumentDetail("OB");
      }
    } catch (e) {
      _showError("Failed to load document details: ${e.toString()}");
    }
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
      customerController.text = customer.customerName;
      quotationNumbers.clear();
      salesOrderNumbers.clear();
      selectedQuotationNumber = null;
      selectedSalesOrderNumber = null;
      items.clear();
    });

    if (selectPreference == "On Quotation") {
      await _loadQuotationNumbers(customer.customerCode);
    } else if (selectPreference == "On Sales Order") {
      await _loadSalesOrderNumbers(customer.customerCode);
    }
  }

  Future<void> _loadQuotationNumbers(String customerCode) async {
    try {
      setState(() => _isLoading = true);
      quotationNumbers = await _service.fetchQuotationNumberList(customerCode);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load quotation numbers: ${e.toString()}");
    }
  }

  Future<void> _loadSalesOrderNumbers(String customerCode) async {
    try {
      setState(() => _isLoading = true);
      salesOrderNumbers = await _service.fetchSalesOrderNumberList(
        customerCode,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load sales order numbers: ${e.toString()}");
    }
  }

  Future<void> _onQuotationSelected(String? quotationNumber) async {
    if (quotationNumber == null) return;

    setState(() {
      selectedQuotationNumber = quotationNumber;
      items.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchQuotationDetails(quotationNumber);
      items = [];
      int lineNo = 1;
      for (final item in details.itemDetail) {
        items.add(
          ProformaItem(
            itemName: item['itemName'] ?? '',
            itemCode: item['itemCode'] ?? '',
            qty: (item['qty'] ?? 0).toDouble(),
            basicRate: (item['itemRate'] ?? 0).toDouble(),
            uom: item['suom'] ?? 'NOS',
            discountType: item['discountAmount'] > 0 ? 'Value' : 'None',
            discountAmount: item['discountAmount']?.toDouble(),
            discountPercentage: null,
            rateStructure: item['rateStructureCode'] ?? '',
            taxAmount: (item['totalTax'] ?? 0).toDouble(),
            totalAmount: (item['totalValue'] ?? 0).toDouble(),
            rateStructureRows: null, // You may want to fetch and fill this
            lineNo: lineNo++,
            hsnAccCode: item['hsnAccCode'] ?? '',
          ),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load quotation details: ${e.toString()}");
    }
  }

  Future<void> _onSalesOrderSelected(String? salesOrderNumber) async {
    if (salesOrderNumber == null) return;

    setState(() {
      selectedSalesOrderNumber = salesOrderNumber;
      items.clear();
      _isLoading = true;
    });

    try {
      final details = await _service.fetchSalesOrderDetails(salesOrderNumber);
      items = [];
      int lineNo = 1;
      for (final item in details.itemDetail) {
        items.add(
          ProformaItem(
            itemName: item['itemName'] ?? '',
            itemCode: item['itemCode'] ?? '',
            qty: (item['qty'] ?? 0).toDouble(),
            basicRate: (item['itemRate'] ?? 0).toDouble(),
            uom: item['suom'] ?? 'NOS',
            discountType: item['discountAmount'] > 0 ? 'Value' : 'None',
            discountAmount: item['discountAmount']?.toDouble(),
            discountPercentage: null,
            rateStructure: item['rateStructureCode'] ?? '',
            taxAmount: (item['totalTax'] ?? 0).toDouble(),
            totalAmount: (item['totalValue'] ?? 0).toDouble(),
            rateStructureRows: null, // You may want to fetch and fill this
            lineNo: lineNo++,
            hsnAccCode: item['hsnAccCode'] ?? '',
          ),
        );
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("Failed to load sales order details: ${e.toString()}");
    }
  }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<ProformaItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                AddItemPage(service: _service, rateStructures: rateStructures),
      ),
    );

    if (result != null) {
      setState(() {
        result.lineNo = items.length + 1;
        items.add(result);
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
      // Reassign line numbers
      for (int i = 0; i < items.length; i++) {
        items[i] = ProformaItem(
          itemName: items[i].itemName,
          itemCode: items[i].itemCode,
          qty: items[i].qty,
          basicRate: items[i].basicRate,
          uom: items[i].uom,
          discountType: items[i].discountType,
          discountPercentage: items[i].discountPercentage,
          discountAmount: items[i].discountAmount,
          rateStructure: items[i].rateStructure,
          taxAmount: items[i].taxAmount,
          totalAmount: items[i].totalAmount,
          rateStructureRows: items[i].rateStructureRows,
          lineNo: i + 1,
          hsnAccCode: items[i].hsnAccCode,
        );
      }
    });
  }

  double _calculateTotalBasic() {
    return items.fold(0.0, (sum, item) => sum + (item.basicRate * item.qty));
  }

  double _calculateTotalDiscount() {
    return items.fold(0.0, (sum, item) => sum + (item.discountAmount ?? 0.0));
  }

  double _calculateTotalTax() {
    return items.fold(0.0, (sum, item) => sum + (item.taxAmount ?? 0.0));
  }

  double _calculateTotalAmount() {
    return items.fold(0.0, (sum, item) => sum + item.totalAmount);
  }

  // Map<String, dynamic> _buildSubmissionPayload() {
  //   List<Map<String, dynamic>> itemDetails = [];
  //   List<Map<String, dynamic>> rsGrid = [];
  //   List<Map<String, dynamic>> discountDetails = [];

  //   for (int i = 0; i < items.length; i++) {
  //     final item = items[i];
  //     final lineNo = i + 1;
  //     final userId = userDetails?['id'] ?? 0;
  //     final locationId = locationDetails?['id'] ?? 0;

  //     // Item detail
  //     final itemJson = item.toSubmissionJson(userId, locationId);
  //     itemJson['lineNo'] = lineNo;
  //     itemJson['seqNo'] = lineNo;
  //     itemDetails.add(itemJson);

  //     // rsGrid: add all rate structure rows for this item, set refLine = lineNo
  //     if (item.rateStructureRows != null) {
  //       for (final row in item.rateStructureRows!) {
  //         rsGrid.add({
  //           "docType": "PI",
  //           "docSubType": "PI",
  //           "xdtdtmcd": item.itemCode,
  //           "rateCode": row['msprtcd'],
  //           "rateStructCode": item.rateStructure,
  //           "rateAmount": row['rateAmount'] ?? 0,
  //           "amdSrNo": 0,
  //           "perCValue": row['msprtval']?.toString() ?? "0.00",
  //           "incExc": row['mspincexc'],
  //           "perVal": row['mspperval'],
  //           "appliedOn": row['mtrslvlno'] ?? "",
  //           "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
  //           "seqNo": row['mspseqno']?.toString() ?? "1",
  //           "curCode": row['mprcurcode'] ?? "INR",
  //           "fromLocationId": 8,
  //           "TaxTyp": row['mprtaxtyp'],
  //           "refLine": lineNo,
  //         });
  //       }
  //     }

  //     // Discount detail
  //     if (item.discountAmount != null && item.discountAmount! > 0) {
  //       discountDetails.add({
  //         "itemCode": item.itemCode,
  //         "currCode": "INR",
  //         "discCode": "01",
  //         "discType": item.discountType,
  //         "discVal":
  //             item.discountType == "Percentage"
  //                 ? item.discountPercentage ?? 0
  //                 : item.discountAmount ?? 0,
  //         "fromLocationId": 8,
  //         "oditmlineno": lineNo,
  //       });
  //     }
  //   }

  //   return {
  //     "action": "add",
  //     "autoNoRequired": "Y",
  //     "customerPoNumber": null,
  //     "customerPoDate": null,
  //     "itemDetail": itemDetails,
  //     "rsGrid": rsGrid,
  //     "discountDetail": discountDetails,
  //     "remark": [],
  //   };
  // }

  Map<String, dynamic> _buildSubmissionPayload() {
    if (userDetails?['id'] == null) throw Exception("User ID is null");
    debugPrint("locationDetails: $locationDetails");
    if (locationDetails?['id'] == null) throw Exception("Location ID is null");
    if (locationDetails?['code'] == null)
      throw Exception("Location code is null");
    if (selectedCustomer == null) throw Exception("Customer is null");

    List<Map<String, dynamic>> itemDetails = [];
    List<Map<String, dynamic>> rsGrid = [];
    List<Map<String, dynamic>> discountDetails = [];

    double totalBasic = 0.0;
    double totalTax = 0.0;
    double totalAmount = 0.0;
    double totalDiscount = 0.0;
    String discountType = items.isNotEmpty ? items.first.discountType : "None";
    bool allSameDiscountType = items.every(
      (item) => item.discountType == discountType,
    );
    final userId = userDetails?['id'] ?? 0;
    final locationId = locationDetails?['id'] ?? 0;
    final locationCode = locationDetails?['code'] ?? "";

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final lineNo = i + 1;

      final itemJson = item.toSubmissionJson(userId, locationId);
      itemJson['lineNo'] = lineNo;
      itemJson['seqNo'] = lineNo;
      itemDetails.add(itemJson);

      totalBasic += (item.basicRate * item.qty);
      totalTax += (item.taxAmount ?? 0.0);
      totalAmount += (item.totalAmount - (item.discountAmount ?? 0.0));
      totalDiscount += (item.discountAmount ?? 0.0);

      // rsGrid: add all rate structure rows for this item, set refLine = lineNo
      if (item.rateStructureRows != null) {
        for (final row in item.rateStructureRows!) {
          rsGrid.add({
            "docType": "PI",
            "docSubType": "PI",
            "xdtdtmcd": item.itemCode,
            "rateCode": row['msprtcd'],
            "rateStructCode": item.rateStructure,
            "rateAmount": row['rateAmount'] ?? 0,
            "amdSrNo": 0,
            "perCValue": row['msprtval']?.toString() ?? "0.00",
            "incExc": row['mspincexc'],
            "perVal": row['mspperval'],
            "appliedOn": row['mtrslvlno'] ?? "",
            "pnyn": row['msppnyn'] == "True" || row['msppnyn'] == true,
            "seqNo": row['mspseqno']?.toString() ?? "1",
            "curCode": row['mprcurcode'] ?? "INR",
            "fromLocationId": locationId,
            "TaxTyp": row['mprtaxtyp'],
            "refLine": lineNo,
          });
        }
      }

      // Discount detail
      if (item.discountAmount != null && item.discountAmount! > 0) {
        discountDetails.add({
          "itemCode": item.itemCode,
          "currCode": "INR",
          "discCode": "01",
          "discType": item.discountType,
          "discVal":
              item.discountType == "Percentage"
                  ? item.discountPercentage ?? 0
                  : item.discountAmount ?? 0,
          "fromLocationId": locationId,
          "oditmlineno": lineNo,
        });
      }
    }

    // Format numbers as strings with 2 decimals where needed
    String format2(double val) => val.toStringAsFixed(2);

    final itemHeaderDetial = {
      "autoId": 0,
      "invYear": "25-26", // You may want to get this dynamically
      "invGroup": "PI",
      "invSite": locationId,
      "invSiteCode": locationCode,
      "invIssueDate":
          selectedDate != null
              ? FormatUtils.formatDateForApi(selectedDate!)
              : "",
      "invValue": totalAmount,
      "invAmount": totalAmount + totalTax,
      "invRoValue": (totalAmount + totalTax).round(),
      "invTax": totalTax,
      "invType": "M",
      "invCustCode": selectedCustomer!.customerCode,
      "invStatus": "O",
      "invOn":
          selectPreference == "On Quotation"
              ? "Q"
              : selectPreference == "On Sales Order"
              ? "O"
              : "T",
      "invDiscountType": allSameDiscountType ? discountType : "None",
      "invDiscountValue": totalDiscount,
      "invFromLocationId": locationId,
      "invCreatedUserId": userId,
      "invCurrCode": "INR",
      "invRate": 0,
      "invNumber": "",
      "invBacAmount": totalAmount,
      "invSiteReq": "Y",
    };

    return {
      "action": "add",
      "autoNoRequired": "Y",
      "customerPoNumber": null,
      "customerPoDate": null,
      "itemHeaderDetial": itemHeaderDetial,
      "itemDetail": itemDetails,
      "rsGrid": rsGrid,
      "discountDetail": discountDetails,
      "termsDetail": [], // Fill as needed
      "standardTerms": [],
      "chargesDetail": [],
      "remark": [],
    };
  }

  Future<void> _submitProformaInvoice() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateForm()) return;

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    try {
      setState(() => _isLoading = true);

      final payload = _buildSubmissionPayload();
      final success = await _service.submitProformaInvoice(payload);

      setState(() => _isLoading = false);

      if (success) {
        _showSuccess("Proforma Invoice submitted successfully");
        Navigator.pop(context, true);
      } else {
        _showError("Failed to submit Proforma Invoice");
      }
    } catch (e, st) {
      setState(() => _isLoading = false);
      debugPrint("Error stacktrace during submission: ${st}");
      _showError("Error during submission: ${e.toString()}");
    }
  }

  bool _validateForm() {
    if (selectPreference == null) {
      _showError("Please select a preference");
      return false;
    }

    if (selectedDate == null) {
      _showError("Please select a date");
      return false;
    }

    if (selectedCustomer == null) {
      _showError("Please select a customer");
      return false;
    }

    if (selectPreference == "On Quotation" && selectedQuotationNumber == null) {
      _showError("Please select a quotation number");
      return false;
    }

    if (selectPreference == "On Sales Order" &&
        selectedSalesOrderNumber == null) {
      _showError("Please select a sales order number");
      return false;
    }

    if (items.isEmpty) {
      _showError("Please add at least one item");
      return false;
    }

    return true;
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Confirm Submission"),
                content: const Text(
                  "Are you sure you want to submit this Proforma Invoice?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Submit"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Proforma Invoice"), elevation: 1),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreferenceDropdown(),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerField(),
                      const SizedBox(height: 16),
                      if (selectPreference == "On Quotation") ...[
                        _buildQuotationDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (selectPreference == "On Sales Order") ...[
                        _buildSalesOrderDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
                      if (selectPreference == "On Other") ...[
                        _buildAddItemButton(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildTotalCard(),
                        const SizedBox(height: 24),
                      ],
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPreferenceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Select Preference",
        border: OutlineInputBorder(),
      ),
      value: selectPreference,
      items:
          preferenceOptions
              .map(
                (pref) =>
                    DropdownMenuItem<String>(value: pref, child: Text(pref)),
              )
              .toList(),
      onChanged: _onPreferenceChanged,
      validator: (val) => val == null ? "Select Preference is required" : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      decoration: const InputDecoration(
        labelText: "Date",
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
            dateController.text = "${picked.toLocal()}".split(' ')[0];
          });
        }
      },
      validator:
          (val) => val == null || val.isEmpty ? "Date is required" : null,
    );
  }

  Widget _buildCustomerField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: customerController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: "Customer Name",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty
                      ? "Customer Name is required"
                      : null,
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length < 4) return [];
        try {
          return await _service.fetchCustomerSuggestions(pattern);
        } catch (e) {
          return [];
        }
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.customerName),
          subtitle: Text(suggestion.customerCode),
        );
      },
      onSelected: _onCustomerSelected,
    );
  }

  Widget _buildQuotationDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
      ),
      value: selectedQuotationNumber,
      items:
          quotationNumbers
              .map(
                (qn) => DropdownMenuItem<String>(
                  value: qn.number,
                  child: Text(qn.number),
                ),
              )
              .toList(),
      onChanged: _onQuotationSelected,
      validator: (val) => val == null ? "Quotation Number is required" : null,
    );
  }

  Widget _buildSalesOrderDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Sales Order Number",
        border: OutlineInputBorder(),
      ),
      value: selectedSalesOrderNumber,
      items:
          salesOrderNumbers
              .map(
                (so) => DropdownMenuItem<String>(
                  value: so.number,
                  child: Text(so.number),
                ),
              )
              .toList(),
      onChanged: _onSalesOrderSelected,
      validator: (val) => val == null ? "Sales Order Number is required" : null,
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Items:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.itemName),
                subtitle: Text(
                  "Qty: ${item.qty} ${item.uom}\nRate: ₹${item.basicRate.toStringAsFixed(2)}\nTotal: ₹${item.totalAmount.toStringAsFixed(2)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add New Item"),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Total Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Basic Amount:"),
                Text("₹${_calculateTotalBasic().toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Discount Value:"),
                Text("₹${_calculateTotalDiscount().toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax Amount:"),
                Text("₹${_calculateTotalTax().toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${_calculateTotalAmount().toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitProformaInvoice,
        child: const Text("Submit Proforma Invoice"),
      ),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    customerController.dispose();
    super.dispose();
  }
}
