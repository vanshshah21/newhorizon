// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:nhapp/pages/quotation/models/add_quotation.dart';
// import 'package:nhapp/pages/quotation/service/add_quotation.dart';

// import 'add_quotation_item_page.dart';

// class AddQuotationPage extends StatefulWidget {
//   const AddQuotationPage({super.key});

//   @override
//   State<AddQuotationPage> createState() => _AddQuotationPageState();
// }

// class _AddQuotationPageState extends State<AddQuotationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final QuotationFormService _service;

//   // Form fields
//   List<QuotationBase> _quotationBases = [];
//   QuotationBase? _selectedQuotationBase;

//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   List<Salesman> _salesmen = [];
//   Salesman? _selectedSalesman;

//   final TextEditingController _subjectToController = TextEditingController();
//   DateTime _date = DateTime.now();

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadDropdowns();
//   }

//   Future<void> _loadDropdowns() async {
//     setState(() => _loading = true);
//     final bases = await _service.fetchQuotationBases();
//     final salesmen = await _service.fetchSalesmen();
//     setState(() {
//       _quotationBases = bases;
//       _salesmen = salesmen;
//       _loading = false;
//     });
//   }

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       _attachments.removeAt(index);
//     });
//   }

//   void _addItem(Map<String, dynamic> item) {
//     setState(() {
//       _items.add(item);
//     });
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }

//   void _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   void _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) _editItem(index, result);
//   }

//   Map<String, double> getTotals() {
//     double basic = 0, discount = 0, tax = 0, total = 0;
//     for (final item in _items) {
//       basic += (item['basicAmount'] ?? 0) as double;
//       tax += (item['taxAmount'] ?? 0) as double;
//       total += (item['totalAmount'] ?? 0) as double;
//       discount += (item['discountValue'] ?? 0) as double;
//     }
//     return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
//   }

//   void _submit() {
//     // TODO: Implement submission logic using your create quotation API
//     // and then upload attachments as in AddLeadPage
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final totals = getTotals();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Quotation')),
//       body: AbsorbPointer(
//         absorbing: _submitting,
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Quotation Base
//               DropdownButtonFormField<QuotationBase>(
//                 decoration: const InputDecoration(labelText: 'Quotation Base'),
//                 value: _selectedQuotationBase,
//                 items:
//                     _quotationBases
//                         .map(
//                           (e) =>
//                               DropdownMenuItem(value: e, child: Text(e.name)),
//                         )
//                         .toList(),
//                 onChanged: (v) => setState(() => _selectedQuotationBase = v),
//                 validator: (v) => v == null ? 'Select Quotation Base' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quote To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _quoteToController,
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.length < 4) {
//                     return [];
//                   }
//                   return await _service.searchCustomers(pattern);
//                 },
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Quote To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Quote To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedQuoteTo = suggestion;
//                     _quoteToController.text = suggestion.customerFullName;
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback:
//                     (pattern) => _service.searchCustomers(pattern),
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Bill To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Bill To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman
//               DropdownButtonFormField<Salesman>(
//                 decoration: const InputDecoration(labelText: 'Salesman'),
//                 value: _selectedSalesman,
//                 items:
//                     _salesmen
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e.salesManFullName),
//                           ),
//                         )
//                         .toList(),
//                 onChanged: (v) => setState(() => _selectedSalesman = v),
//                 validator: (v) => v == null ? 'Select Salesman' : null,
//               ),
//               const SizedBox(height: 16),

//               // Subject To
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date
//               InputDecorator(
//                 decoration: const InputDecoration(labelText: 'Date'),
//                 child: InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _date,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (picked != null) {
//                       setState(() => _date = picked);
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text('${_date.toLocal()}'.split(' ')[0]),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Items Section
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _openAddItem,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New Item'),
//                   ),
//                 ],
//               ),
//               ..._items.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final item = entry.value;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: ListTile(
//                     title: Text(item['itemName'] ?? 'Item'),
//                     subtitle: Text(
//                       'Qty: ${item['qty']} | UOM: ${item['uom']} | Rate: ${item['rate']}',
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () => _openEditItem(idx),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () => _removeItem(idx),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),

//               // --- Total Card ---
//               Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Attachments
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _submitting ? null : _pickFiles,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Add Attachment'),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${_attachments.length} file(s) selected'),
//                 ],
//               ),
//               ..._attachments.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final file = entry.value;
//                 return ListTile(
//                   title: Text(file.name),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(idx),
//                   ),
//                 );
//               }),

//               const SizedBox(height: 24),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 child:
//                     _submitting
//                         ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/quotation/models/add_quotation.dart';
// import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/quotation/service/add_quotation.dart';

// class AddQuotationPage extends StatefulWidget {
//   const AddQuotationPage({super.key});

//   @override
//   State<AddQuotationPage> createState() => _AddQuotationPageState();
// }

// class _AddQuotationPageState extends State<AddQuotationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final QuotationFormService _service;

//   // Form fields
//   List<QuotationBase> _quotationBases = [];
//   QuotationBase? _selectedQuotationBase;

//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   List<Salesman> _salesmen = [];
//   Salesman? _selectedSalesman;

//   final TextEditingController _subjectToController = TextEditingController();
//   DateTime _date = DateTime.now();

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   // Additional fields (simulate storage values)
//   String? _year;
//   int? _siteId;
//   int? _userId;
//   bool? _isAutoNumberGenerated;
//   String?
//   _leadNumber; // For manual numbering; may not be used for auto-numbered documents.
//   String? _documentNo;

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _loading = true);
//     // Assume these values are loaded from storage. For example:
//     _year = "24-25";
//     _siteId = 8;
//     _userId = 2;
//     // Load dropdowns
//     final bases = await _service.fetchQuotationBases();
//     final salesmen = await _service.fetchSalesmen();
//     setState(() {
//       _quotationBases = bases;
//       _salesmen = salesmen;
//       _loading = false;
//     });
//   }

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       _attachments.removeAt(index);
//     });
//   }

//   void _addItem(Map<String, dynamic> item) {
//     setState(() {
//       _items.add(item);
//     });
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }

//   void _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   void _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) _editItem(index, result);
//   }

//   Map<String, double> getTotals() {
//     double basic = 0, discount = 0, tax = 0, total = 0;
//     for (final item in _items) {
//       basic += (item['basicAmount'] ?? 0) as double;
//       tax += (item['taxAmount'] ?? 0) as double;
//       total += (item['totalAmount'] ?? 0) as double;
//       discount += (item['discountValue'] ?? 0) as double;
//     }
//     return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate() || _items.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill all required fields and add at least one item',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _submitting = true;
//     });

//     try {
//       // Step 1: Fetch default document details.
//       // The API GET is: {{baseUrl}}/api/Lead/GetDefaultDocumentDetail?year={year}&type=SQ&subType=SQ&locationId={siteId}
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       if (docDetail.isEmpty) {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch document details')),
//         );
//         return;
//       }

//       // Step 2: Build the payload for quotation submission.
//       final payload = {
//         "entity": {
//           "DocSubType": "SQ",
//           "DocType": "SQ",
//           "DomesticCurrencyCode": "INR",
//           "CompanyId": docDetail["CompanyId"] ?? 1,
//           "FromLocationCode": docDetail["locationCode"],
//           "FromLocationId": docDetail["locationId"],
//           "FromLocationName": docDetail["locationName"],
//           "QuotationDetails": {
//             "BillToCustomerCode": _selectedBillTo!.customerCode,
//             "CustomerCode": _selectedQuoteTo!.customerCode,
//             "CustomerName": _selectedQuoteTo!.customerName,
//             "QuotationDate": DateFormat('yyyy-MM-dd').format(_date),
//             "QuotationGroup": docDetail["groupCode"],
//             // If auto-numbered, use the default document string; otherwise use manual value.
//             "QuotationNumber":
//                 (_isAutoNumberGenerated == false)
//                     ? _leadNumber
//                     : docDetail["documentString"],
//             "QuotationSiteCode": docDetail["locationCode"],
//             "QuotationSiteId": _siteId,
//             "QuotationYear": _year,
//             "SalesPersonCode":
//                 _selectedSalesman!.salesManFullName, // adjust if needed
//             "Subject": _subjectToController.text,
//             "DiscountAmount": 0,
//             "TotalAmountAfterTaxDomesticCurrency": getTotals()['total'],
//           },
//           "ModelDetails":
//               _items.map((item) {
//                 return {
//                   "SalesItemCode": item['item'].itemCode,
//                   "SalesItemDesc": item['item'].itemName,
//                   "BasicPriceIUOM": item['rate'],
//                   "QtyIUOM": item['qty'],
//                   "DiscountType": item['discountType'] ?? "",
//                   "DiscountValue": item['discountValue'] ?? 0,
//                   "RateStructureCode": item['rateStructure'] ?? "",
//                 };
//               }).toList(),
//           "RateStructureDetails": [], // Optionally, include tax breakdown.
//           "UserId": _userId,
//         },
//       };

//       // Step 3: Submit the quotation payload.
//       final submissionResponse = await _service.submitQuotation(payload);
//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

//         // Step 4: Upload attachments if any.
//         bool attachSuccess = true;
//         if (_attachments.isNotEmpty) {
//           attachSuccess = await _service.uploadAttachments(
//             filePaths: _attachments.map((f) => f.path!).toList(),
//             documentNo: submissionResponse['data']?['QuotationNumber'] ?? "",
//             documentId: quotationId.toString(),
//             docYear: _year!,
//             formId: docDetail["formId"] ?? "06100",
//             locationCode: docDetail["locationCode"],
//             companyCode: docDetail["companyCode"] ?? "",
//             locationId: _siteId!,
//             companyId: docDetail["CompanyId"] ?? 1,
//             userId: _userId!,
//           );
//         }
//         setState(() {
//           _submitting = false;
//         });
//         if (attachSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Quotation created successfully!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Quotation created, but attachment upload failed'),
//             ),
//           );
//         }
//         Navigator.of(context).pop(true);
//       } else {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to create quotation')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _submitting = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final totals = getTotals();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Quotation')),
//       body: AbsorbPointer(
//         absorbing: _submitting,
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Quotation Base
//               DropdownButtonFormField<QuotationBase>(
//                 decoration: const InputDecoration(labelText: 'Quotation Base'),
//                 value: _selectedQuotationBase,
//                 items:
//                     _quotationBases
//                         .map(
//                           (e) =>
//                               DropdownMenuItem(value: e, child: Text(e.name)),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedQuotationBase = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Quotation Base' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quote To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _quoteToController,
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.length < 4) return [];
//                   return await _service.searchCustomers(pattern);
//                 },
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Quote To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Quote To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedQuoteTo = suggestion;
//                     _quoteToController.text = suggestion.customerFullName;
//                     // Default Bill To to Quote To if not changed
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback:
//                     (pattern) => _service.searchCustomers(pattern),
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Bill To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Bill To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman Dropdown
//               DropdownButtonFormField<Salesman>(
//                 decoration: const InputDecoration(labelText: 'Salesman'),
//                 value: _selectedSalesman,
//                 items:
//                     _salesmen
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e.salesManFullName),
//                           ),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedSalesman = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Salesman' : null,
//               ),
//               const SizedBox(height: 16),

//               // Subject To Field
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date Picker
//               InputDecorator(
//                 decoration: const InputDecoration(labelText: 'Date'),
//                 child: InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _date,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         _date = picked;
//                       });
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text('${_date.toLocal()}'.split(' ')[0]),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Items Section Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _openAddItem,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New Item'),
//                   ),
//                 ],
//               ),
//               ..._items.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final item = entry.value;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['item'].itemName,
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Qty: ${item['qty']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Rate: ${item['rate']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Total: ${item['totalAmount']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _openEditItem(idx),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => _removeItem(idx),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),

//               // Total Card
//               Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Attachments Section
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _submitting ? null : _pickFiles,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Add Attachment'),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${_attachments.length} file(s) selected'),
//                 ],
//               ),
//               ..._attachments.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final file = entry.value;
//                 return ListTile(
//                   title: Text(file.name),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(idx),
//                   ),
//                 );
//               }),

//               const SizedBox(height: 24),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 child:
//                     _submitting
//                         ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/quotation/models/add_quotation.dart';
// import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/quotation/service/add_quotation.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class AddQuotationPage extends StatefulWidget {
//   const AddQuotationPage({super.key});

//   @override
//   State<AddQuotationPage> createState() => _AddQuotationPageState();
// }

// class _AddQuotationPageState extends State<AddQuotationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final QuotationFormService _service;

//   // Form fields
//   List<QuotationBase> _quotationBases = [];
//   QuotationBase? _selectedQuotationBase;

//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   List<Salesman> _salesmen = [];
//   Salesman? _selectedSalesman;

//   final TextEditingController _subjectToController = TextEditingController();
//   DateTime _date = DateTime.now();

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   // Additional fields from API
//   String? _year;
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   int? _siteId;
//   int? _userId;
//   bool? _isAutoNumberGenerated;
//   String? _leadNumber; // For manual numbering if needed.
//   String? _documentNo;

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _loading = true);
//     try {
//       // 1. Fetch current year date range (disabled dates for datepicker)
//       final dateRange = await _service.fetchDateRange();
//       _minDate =
//           dateRange["periodSDt"] != null
//               ? DateTime.parse(dateRange["periodSDt"])
//               : DateTime.now();
//       _maxDate =
//           dateRange["periodEDt"] != null
//               ? DateTime.parse(dateRange["periodEDt"])
//               : DateTime.now();
//       _year = dateRange["financialYear"] ?? "";

//       // 2. Call fetchDefaultDocDetail to retrieve default doc info. (For submission payload)
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       // You can store more fields from docDetail as needed. For example:
//       _isAutoNumberGenerated = docDetail["isAutoNumberGenerated"] ?? true;

//       // 3. Load dropdowns for quotation bases and salesmen.
//       final bases = await _service.fetchQuotationBases();
//       final salesmen = await _service.fetchSalesmen();
//       setState(() {
//         _quotationBases = bases;
//         _salesmen = salesmen;
//         // Set the default date to today, but ensure it's within allowed range.
//         _date = DateTime.now().isBefore(_minDate!) ? _minDate! : DateTime.now();
//         if (_date.isAfter(_maxDate!)) _date = _maxDate!;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       _attachments.removeAt(index);
//     });
//   }

//   void _addItem(Map<String, dynamic> item) {
//     setState(() {
//       _items.add(item);
//     });
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }

//   void _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   void _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) _editItem(index, result);
//   }

//   Map<String, double> getTotals() {
//     double basic = 0, discount = 0, tax = 0, total = 0;
//     for (final item in _items) {
//       basic += (item['basicAmount'] ?? 0) as double;
//       tax += (item['taxAmount'] ?? 0) as double;
//       total += (item['totalAmount'] ?? 0) as double;
//       discount += (item['discountValue'] ?? 0) as double;
//     }
//     return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate() || _items.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill all required fields and add at least one item',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _submitting = true;
//     });

//     try {
//       // Step 1: Fetch default document details.
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       if (docDetail.isEmpty) {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch document details')),
//         );
//         return;
//       }

//       // Build the payload for quotation submission using API data and user inputs.
//       final payload = {
//         "entity": {
//           "DocSubType": "SQ",
//           "DocType": "SQ",
//           "DomesticCurrencyCode": "INR",
//           "CompanyId": docDetail["CompanyId"] ?? 1,
//           "FromLocationCode": docDetail["locationCode"],
//           "FromLocationId": docDetail["locationId"],
//           "FromLocationName": docDetail["locationName"],
//           "QuotationDetails": {
//             "BillToCustomerCode": _selectedBillTo!.customerCode,
//             "CustomerCode": _selectedQuoteTo!.customerCode,
//             "CustomerName": _selectedQuoteTo!.customerName,
//             "QuotationDate": DateFormat('yyyy-MM-dd').format(_date),
//             "QuotationGroup": docDetail["groupCode"],
//             "QuotationNumber":
//                 (_isAutoNumberGenerated == false)
//                     ? _leadNumber
//                     : docDetail["documentString"],
//             "QuotationSiteCode": docDetail["locationCode"],
//             "QuotationSiteId": _siteId,
//             "QuotationYear": _year,
//             "SalesPersonCode":
//                 _selectedSalesman!.salesManFullName, // adjust as needed
//             "Subject": _subjectToController.text,
//             "DiscountAmount": 0,
//             "TotalAmountAfterTaxDomesticCurrency": getTotals()['total'],
//           },
//           "ModelDetails":
//               _items.map((item) {
//                 return {
//                   "SalesItemCode": item['item'].itemCode,
//                   "SalesItemDesc": item['item'].itemName,
//                   "BasicPriceIUOM": item['rate'],
//                   "QtyIUOM": item['qty'],
//                   "DiscountType": item['discountType'] ?? "",
//                   "DiscountValue": item['discountValue'] ?? 0,
//                   "RateStructureCode": item['rateStructure'] ?? "",
//                 };
//               }).toList(),
//           "RateStructureDetails":
//               [], // Optionally include tax breakdown from calc API.
//           "UserId": _userId,
//         },
//       };

//       // Step 2: Submit the quotation payload.
//       final submissionResponse = await _service.submitQuotation(payload);
//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

//         // Step 3: If attachments exist, upload them using the returned quotation numbers/IDs.
//         bool attachSuccess = true;
//         if (_attachments.isNotEmpty) {
//           attachSuccess = await _service.uploadAttachments(
//             filePaths: _attachments.map((f) => f.path!).toList(),
//             documentNo: submissionResponse['data']?['QuotationNumber'] ?? "",
//             documentId: quotationId.toString(),
//             docYear: _year!,
//             formId: docDetail["formId"] ?? "06100",
//             locationCode: docDetail["locationCode"],
//             companyCode: docDetail["companyCode"] ?? "",
//             locationId: _siteId!,
//             companyId: docDetail["CompanyId"] ?? 1,
//             userId: _userId!,
//           );
//         }
//         setState(() {
//           _submitting = false;
//         });
//         if (attachSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Quotation created successfully!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Quotation created, but attachment upload failed'),
//             ),
//           );
//         }
//         Navigator.of(context).pop(true);
//       } else {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to create quotation')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _submitting = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final totals = getTotals();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Quotation')),
//       body: AbsorbPointer(
//         absorbing: _submitting,
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Quotation Base Dropdown
//               DropdownButtonFormField<QuotationBase>(
//                 decoration: const InputDecoration(labelText: 'Quotation Base'),
//                 value: _selectedQuotationBase,
//                 items:
//                     _quotationBases
//                         .map(
//                           (e) =>
//                               DropdownMenuItem(value: e, child: Text(e.name)),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedQuotationBase = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Quotation Base' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quote To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _quoteToController,
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.length < 4) return [];
//                   return await _service.searchCustomers(pattern);
//                 },
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Quote To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Quote To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedQuoteTo = suggestion;
//                     _quoteToController.text = suggestion.customerFullName;
//                     // Default Bill To to Quote To if not changed
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback:
//                     (pattern) => _service.searchCustomers(pattern),
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Bill To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Bill To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman Dropdown
//               DropdownButtonFormField<Salesman>(
//                 decoration: const InputDecoration(labelText: 'Salesman'),
//                 value: _selectedSalesman,
//                 items:
//                     _salesmen
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e.salesManFullName),
//                           ),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedSalesman = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Salesman' : null,
//               ),
//               const SizedBox(height: 16),

//               // Subject To Field
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date Picker with disabled dates
//               InputDecorator(
//                 decoration: const InputDecoration(labelText: 'Date'),
//                 child: InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _date,
//                       firstDate: _minDate ?? DateTime(2000),
//                       lastDate: _maxDate ?? DateTime(2100),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         _date = picked;
//                       });
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text(DateFormat('yyyy-MM-dd').format(_date)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Items Section Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _openAddItem,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New Item'),
//                   ),
//                 ],
//               ),
//               ..._items.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final item = entry.value;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['item'].itemName,
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Qty: ${item['qty']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Rate: ${item['rate']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Total: ${item['totalAmount']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _openEditItem(idx),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => _removeItem(idx),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),

//               // Total Card
//               Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Attachments Section
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _submitting ? null : _pickFiles,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Add Attachment'),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${_attachments.length} file(s) selected'),
//                 ],
//               ),
//               ..._attachments.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final file = entry.value;
//                 return ListTile(
//                   title: Text(file.name),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(idx),
//                   ),
//                 );
//               }),
//               const SizedBox(height: 24),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 child:
//                     _submitting
//                         ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/quotation/models/add_quotation.dart';
// import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/quotation/service/add_quotation.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class AddQuotationPage extends StatefulWidget {
//   const AddQuotationPage({super.key});

//   @override
//   State<AddQuotationPage> createState() => _AddQuotationPageState();
// }

// class _AddQuotationPageState extends State<AddQuotationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final QuotationFormService _service;

//   // Form fields
//   List<QuotationBase> _quotationBases = [];
//   QuotationBase? _selectedQuotationBase;

//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   List<Salesman> _salesmen = [];
//   Salesman? _selectedSalesman;

//   final TextEditingController _subjectToController = TextEditingController();
//   DateTime _date = DateTime.now();

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   // Additional fields from API
//   String? _year;
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   int? _siteId;
//   int? _userId;
//   bool? _isAutoNumberGenerated;
//   String? _leadNumber; // For manual numbering if needed.
//   String? _documentNo;

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _loading = true);
//     try {
//       // For simplicity, assume these values come from storage.
//       _siteId = 8;
//       _userId = 2;

//       // 1. Fetch current year date range to disable dates outside _minDate and _maxDate.
//       final dateRange = await _service.fetchDateRange();
//       _minDate =
//           dateRange["periodSDt"] != null
//               ? DateTime.parse(dateRange["periodSDt"])
//               : DateTime.now();
//       _maxDate =
//           dateRange["periodEDt"] != null
//               ? DateTime.parse(dateRange["periodEDt"])
//               : DateTime.now();
//       _year = dateRange["financialYear"] ?? "";

//       // 2. Call fetchDefaultDocDetail for default document details.
//       // For quotation, set type and subType as "SQ".
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       _isAutoNumberGenerated = docDetail["isAutoNumberGenerated"] ?? true;

//       // 3. Load dropdown values.
//       final bases = await _service.fetchQuotationBases();
//       final salesmen = await _service.fetchSalesmen();
//       setState(() {
//         _quotationBases = bases;
//         _salesmen = salesmen;
//         // Set the default date to today, ensuring it's within the allowed range.
//         _date = DateTime.now();
//         if (_date.isBefore(_minDate!)) _date = _minDate!;
//         if (_date.isAfter(_maxDate!)) _date = _maxDate!;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       _attachments.removeAt(index);
//     });
//   }

//   void _addItem(Map<String, dynamic> item) {
//     setState(() {
//       _items.add(item);
//     });
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }

//   void _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   void _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) _editItem(index, result);
//   }

//   Map<String, double> getTotals() {
//     double basic = 0, discount = 0, tax = 0, total = 0;
//     for (final item in _items) {
//       basic += (item['basicAmount'] ?? 0) as double;
//       tax += (item['taxAmount'] ?? 0) as double;
//       total += (item['totalAmount'] ?? 0) as double;
//       discount += (item['discountValue'] ?? 0) as double;
//     }
//     return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate() || _items.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill all required fields and add at least one item',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _submitting = true;
//     });

//     try {
//       // Step 1: Fetch default document details for submission.
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       if (docDetail.isEmpty) {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch document details')),
//         );
//         return;
//       }

//       // Build the payload for quotation submission.
//       final payload = {
//           "DocSubType": "SQ",
//           "DocType": "SQ",
//           "DomesticCurrencyCode": "INR",
//           "CompanyId": docDetail["CompanyId"] ?? 1,
//           "FromLocationCode": docDetail["locationCode"],
//           "FromLocationId": docDetail["locationId"],
//           "FromLocationName": docDetail["locationName"],
//           "QuotationDetails": {
//             "BillToCustomerCode": _selectedBillTo!.customerCode,
//             "CustomerCode": _selectedQuoteTo!.customerCode,
//             "CustomerName": _selectedQuoteTo!.customerName,
//             "QuotationDate": DateFormat('yyyy-MM-dd').format(_date),
//             "QuotationGroup": docDetail["groupCode"],
//             "QuotationNumber":
//                 (_isAutoNumberGenerated == false)
//                     ? _leadNumber
//                     : docDetail["documentString"],
//             "QuotationSiteCode": docDetail["locationCode"],
//             "QuotationSiteId": _siteId,
//             "QuotationYear": _year,
//             "SalesPersonCode":
//                 _selectedSalesman!.salesManFullName, // adjust as needed
//             "Subject": _subjectToController.text,
//             "DiscountAmount": 0,
//             "TotalAmountAfterTaxDomesticCurrency": getTotals()['total'],
//           },
//           "ModelDetails":
//               _items.map((item) {
//                 return {
//                   "SalesItemCode": item['itemCode'],
//                   "SalesItemDesc": item['itemName'],
//                   "BasicPriceIUOM": item['rate'],
//                   "QtyIUOM": item['qty'],
//                   "DiscountType": item['discountType'] ?? "",
//                   "DiscountValue": item['discountValue'] ?? 0,
//                   "RateStructureCode": item['rateStructure'] ?? "",
//                 };
//               }).toList(),
//           "RateStructureDetails":
//               [], // Optionally include tax breakdown details.
//           "UserId": _userId,
//       };

//       // Step 2: Submit the quotation payload.
//       final submissionResponse = await _service.submitQuotation(payload);
//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

//         // Step 3: Upload attachments if any.
//         bool attachSuccess = true;
//         if (_attachments.isNotEmpty) {
//           attachSuccess = await _service.uploadAttachments(
//             filePaths: _attachments.map((f) => f.path!).toList(),
//             documentNo: submissionResponse['data']?['QuotationNumber'] ?? "",
//             documentId: quotationId.toString(),
//             docYear: _year!,
//             formId: docDetail["formId"] ?? "06100",
//             locationCode: docDetail["locationCode"],
//             companyCode: docDetail["companyCode"] ?? "",
//             locationId: _siteId!,
//             companyId: docDetail["CompanyId"] ?? 1,
//             userId: _userId!,
//           );
//         }
//         setState(() {
//           _submitting = false;
//         });
//         if (attachSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Quotation created successfully!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Quotation created, but attachment upload failed'),
//             ),
//           );
//         }
//         Navigator.of(context).pop(true);
//       } else {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to create quotation')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _submitting = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final totals = getTotals();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Quotation')),
//       body: AbsorbPointer(
//         absorbing: _submitting,
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Quotation Base Dropdown
//               DropdownButtonFormField<QuotationBase>(
//                 decoration: const InputDecoration(labelText: 'Quotation Base'),
//                 value: _selectedQuotationBase,
//                 items:
//                     _quotationBases
//                         .map(
//                           (e) =>
//                               DropdownMenuItem(value: e, child: Text(e.name)),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedQuotationBase = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Quotation Base' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quote To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _quoteToController,
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.length < 4) return [];
//                   return await _service.searchCustomers(pattern);
//                 },
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Quote To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Quote To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedQuoteTo = suggestion;
//                     _quoteToController.text = suggestion.customerFullName;
//                     // Default Bill To set to Quote To by default.
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback:
//                     (pattern) => _service.searchCustomers(pattern),
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Bill To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Bill To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman Dropdown
//               DropdownButtonFormField<Salesman>(
//                 decoration: const InputDecoration(labelText: 'Salesman'),
//                 value: _selectedSalesman,
//                 items:
//                     _salesmen
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e.salesManFullName),
//                           ),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedSalesman = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Salesman' : null,
//               ),
//               const SizedBox(height: 16),

//               // Subject To Field
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date Picker using disabled dates from API
//               InputDecorator(
//                 decoration: const InputDecoration(labelText: 'Date'),
//                 child: InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _date,
//                       firstDate: _minDate ?? DateTime(2000),
//                       lastDate: _maxDate ?? DateTime(2100),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         _date = picked;
//                       });
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text(DateFormat('yyyy-MM-dd').format(_date)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Items Section Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _openAddItem,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New Item'),
//                   ),
//                 ],
//               ),
//               ..._items.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final item = entry.value;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Fixed item display code: reference keys directly.
//                             Text(
//                               item['itemName'] ?? '',
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Qty: ${item['qty']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Rate: ${item['rate']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Total: ${item['totalAmount']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _openEditItem(idx),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => _removeItem(idx),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),

//               // Total Card
//               Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Attachments Section
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _submitting ? null : _pickFiles,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Add Attachment'),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${_attachments.length} file(s) selected'),
//                 ],
//               ),
//               ..._attachments.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final file = entry.value;
//                 return ListTile(
//                   title: Text(file.name),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(idx),
//                   ),
//                 );
//               }),
//               const SizedBox(height: 24),

//               // Submit Button
//               ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 child:
//                     _submitting
//                         ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/quotation/models/add_quotation.dart';
// import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/quotation/service/add_quotation.dart';

// class AddQuotationPage extends StatefulWidget {
//   const AddQuotationPage({super.key});

//   @override
//   State<AddQuotationPage> createState() => _AddQuotationPageState();
// }

// class _AddQuotationPageState extends State<AddQuotationPage> {
//   final _formKey = GlobalKey<FormState>();
//   late final QuotationFormService _service;

//   // Form fields
//   List<QuotationBase> _quotationBases = [];
//   QuotationBase? _selectedQuotationBase;

//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   List<Salesman> _salesmen = [];
//   Salesman? _selectedSalesman;

//   final TextEditingController _subjectToController = TextEditingController();
//   DateTime _date = DateTime.now();

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   // Additional fields from APIs
//   String? _year;
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   int? _siteId;
//   int? _userId;
//   String? _leadNumber; // For manual numbering if needed.
//   String? _documentNo;

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _loading = true);
//     try {
//       // For simplicity, assume these values come from storage.
//       // _siteId = 8;
//       // _userId = 2;

//       // 1. Fetch current year date range for datepicker limits.
//       final dateRange = await _service.fetchDateRange();
//       _minDate =
//           dateRange["periodSDt"] != null
//               ? DateTime.parse(dateRange["periodSDt"])
//               : DateTime.now();
//       _maxDate =
//           dateRange["periodEDt"] != null
//               ? DateTime.parse(dateRange["periodEDt"])
//               : DateTime.now();
//       _year = dateRange["financialYear"] ?? "";

//       // 2. Fetch default document details (Quotation type).
//       // final docDetail = await _service.fetchDefaultDocDetail(year: _year!);

//       // 3. Load dropdowns.
//       final bases = await _service.fetchQuotationBases();
//       final salesmen = await _service.fetchSalesmen();
//       setState(() {
//         _quotationBases = bases;
//         _salesmen = salesmen;
//         _date = DateTime.now();
//         if (_date.isBefore(_minDate!)) _date = _minDate!;
//         if (_date.isAfter(_maxDate!)) _date = _maxDate!;
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() => _loading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         _attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       _attachments.removeAt(index);
//     });
//   }

//   void _addItem(Map<String, dynamic> item) {
//     setState(() {
//       _items.add(item);
//     });
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//   }

//   void _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   void _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) _editItem(index, result);
//   }

//   Map<String, double> getTotals() {
//     double basic = 0, discount = 0, tax = 0, total = 0;
//     for (final item in _items) {
//       basic += (item['basicAmount'] ?? 0) as double;
//       tax += (item['taxAmount'] ?? 0) as double;
//       total += (item['totalAmount'] ?? 0) as double;
//       discount += (item['discountValue'] ?? 0) as double;
//     }
//     return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
//   }

//   /// Build ModelDetails list based on items.
//   List<Map<String, dynamic>> _buildModelDetails() {
//     List<Map<String, dynamic>> models = [];
//     for (int i = 0; i < _items.length; i++) {
//       final item = _items[i];
//       models.add({
//         "AgentCode": "",
//         "AgentCommisionTypeText": "NONE",
//         "AgentCommisionValue": 0,
//         "AllQty": 0,
//         "AlreadyInvoiceBasicValue": 0,
//         "AmendmentCBOMChange": "A",
//         "AmendmentCBOMChangeText": "NOTAPPLICABLE",
//         "AmendmentChargable": "A",
//         "AmendmentChargableText": "NOTAPPLICABLE",
//         "AmendmentGroup": "",
//         "AmendmentNo": "",
//         "AmendmentSiteId": 0,
//         "AmendmentSrNo": 0,
//         "AmendmentYear": "",
//         "ApplicationCode": "",
//         "BasicPriceIUOM": item['rate'],
//         "BasicPriceSUOM": item['rate'],
//         "CancelQty": 0,
//         "ConversionFactor": 1,
//         "CurrencyCode": "INR",
//         "CustomerPOItemSrNo": "1",
//         "DeliveryDay": 0,
//         "DiscountAmt": item['discountValue'] ?? 0,
//         "DiscountType": item['discountType'] ?? "",
//         "DiscountTypeText":
//             (item['discountType'] ?? "").toLowerCase() == "percentage"
//                 ? "PERCENTAGE"
//                 : "",
//         "DiscountValue": item['discountValue'] ?? 0.0,
//         "DrawingNo": "",
//         "GroupId": 0,
//         "InvoiceMethod": "Q",
//         "InvoiceType": "Regular",
//         "InvoiceTypeShortText": "R",
//         "IsSubItem": false,
//         "ItemAmountAfterDisc": item['basicAmount'] ?? 0,
//         "ItemLineNo": i + 1,
//         "ItemOrderQty": 0,
//         "OriginalBasicPrice": 0,
//         "QtyIUOM": item['qty'],
//         "QtySUOM": item['qty'],
//         "QuotationAmendNo": 0,
//         "QuotationId": 0,
//         "QuotationLineNo": i + 1,
//         "RateStructureCode": item['rateStructure'] ?? "",
//         "SalesItemCode": item['itemCode'] ?? "",
//         "SalesItemDesc": item['itemName'] ?? "",
//         "SalesItemType": "S",
//         "SectionId": 0,
//         "SubGroupId": 0,
//         "SubProjectId": 0,
//         "TagNo": "",
//         "Tolerance": 0,
//       });
//     }
//     return models;
//   }

//   /// Build DiscountDetails list.
//   List<Map<String, dynamic>> _buildDiscountDetails() {
//     List<Map<String, dynamic>> discountDetails = [];
//     for (final item in _items) {
//       if ((item['discountValue'] ?? 0) > 0 &&
//           (item['discountType'] ?? "").toString().toLowerCase() != "none") {
//         discountDetails.add({
//           "AmendSrNo": 0,
//           "CurrencyCode": "INR",
//           "DiscountCode": item['discountCode'],
//           "DiscountType": item['discountType'],
//           "DiscountValue": item['discountValue'],
//           "SalesItemCode": item['itemCode'],
//         });
//       }
//     }
//     return discountDetails;
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate() || _items.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Please fill all required fields and add at least one item',
//           ),
//         ),
//       );
//       return;
//     }
//     setState(() {
//       _submitting = true;
//     });

//     try {
//       // Step 1: Fetch default document details.
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       if (docDetail.isEmpty) {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch document details')),
//         );
//         return;
//       }

//       final submissionData = QuotationSubmissionData(
//         docDetail: docDetail,
//         quoteTo: _selectedQuoteTo!,
//         billTo: _selectedBillTo!,
//         salesman: _selectedSalesman!,
//         subject: _subjectToController.text,
//         quotationDate: _date,
//         quotationYear: _year!,
//         siteId: _siteId!,
//         userId: _userId!,
//         items: _items,
//       );

//       final submissionResponse = await _service.submitQuotation(submissionData);

//       // Step 3: Submit the quotation payload.
//       // final submissionResponse = await _service.submitQuotation(payload);
//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

//         // Step 4: Upload attachments if any.
//         bool attachSuccess = true;
//         if (_attachments.isNotEmpty) {
//           attachSuccess = await _service.uploadAttachments(
//             filePaths: _attachments.map((f) => f.path!).toList(),
//             documentNo: submissionResponse['data']?['QuotationNumber'] ?? "",
//             documentId: quotationId.toString(),
//             docYear: _year!,
//             formId: docDetail["formId"] ?? "06100",
//             locationCode: docDetail["locationCode"],
//             companyCode: docDetail["companyCode"] ?? "",
//             locationId: _siteId!,
//             companyId: docDetail["CompanyId"] ?? 1,
//             userId: _userId!,
//           );
//         }
//         setState(() {
//           _submitting = false;
//         });
//         if (attachSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Quotation created successfully!')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Quotation created, but attachment upload failed'),
//             ),
//           );
//         }
//         Navigator.of(context).pop(true);
//       } else {
//         setState(() {
//           _submitting = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to create quotation')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _submitting = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     final totals = getTotals();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Quotation')),
//       body: AbsorbPointer(
//         absorbing: _submitting,
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Quotation Base Dropdown
//               DropdownButtonFormField<QuotationBase>(
//                 decoration: const InputDecoration(labelText: 'Quotation Base'),
//                 value: _selectedQuotationBase,
//                 items:
//                     _quotationBases
//                         .map(
//                           (e) =>
//                               DropdownMenuItem(value: e, child: Text(e.name)),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedQuotationBase = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Quotation Base' : null,
//               ),
//               const SizedBox(height: 16),

//               // Quote To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _quoteToController,
//                 suggestionsCallback: (pattern) async {
//                   if (pattern.length < 4) return [];
//                   return await _service.searchCustomers(pattern);
//                 },
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Quote To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Quote To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedQuoteTo = suggestion;
//                     _quoteToController.text = suggestion.customerFullName;
//                     // Default Bill To set to Quote To by default.
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback:
//                     (pattern) => _service.searchCustomers(pattern),
//                 builder:
//                     (context, controller, focusNode) => TextFormField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       decoration: const InputDecoration(labelText: 'Bill To'),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Select Bill To'
//                                   : null,
//                     ),
//                 itemBuilder:
//                     (context, suggestion) =>
//                         ListTile(title: Text(suggestion.customerFullName)),
//                 onSelected: (suggestion) {
//                   setState(() {
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman Dropdown
//               DropdownButtonFormField<Salesman>(
//                 decoration: const InputDecoration(labelText: 'Salesman'),
//                 value: _selectedSalesman,
//                 items:
//                     _salesmen
//                         .map(
//                           (e) => DropdownMenuItem(
//                             value: e,
//                             child: Text(e.salesManFullName),
//                           ),
//                         )
//                         .toList(),
//                 onChanged:
//                     (v) => setState(() {
//                       _selectedSalesman = v;
//                     }),
//                 validator: (v) => v == null ? 'Select Salesman' : null,
//               ),
//               const SizedBox(height: 16),

//               // Subject To Field
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date Picker using disabled dates from API
//               InputDecorator(
//                 decoration: const InputDecoration(labelText: 'Date'),
//                 child: InkWell(
//                   onTap: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: _date,
//                       firstDate: _minDate ?? DateTime(2000),
//                       lastDate: _maxDate ?? DateTime(2100),
//                     );
//                     if (picked != null) {
//                       setState(() {
//                         _date = picked;
//                       });
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     child: Text(DateFormat('yyyy-MM-dd').format(_date)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Items Section Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Items',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _openAddItem,
//                     icon: const Icon(Icons.add),
//                     label: const Text('Add New Item'),
//                   ),
//                 ],
//               ),
//               ..._items.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final item = entry.value;
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   child: Stack(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item['itemName'] ?? '',
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Qty: ${item['qty']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Rate: ${item['rate']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Text(
//                                     'Total: ${item['totalAmount']}',
//                                     style:
//                                         Theme.of(context).textTheme.bodyMedium,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Positioned(
//                         right: 0,
//                         top: 0,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _openEditItem(idx),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () => _removeItem(idx),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//               // Total Card
//               Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                       Text(
//                         'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Attachments Section
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _submitting ? null : _pickFiles,
//                     icon: const Icon(Icons.attach_file),
//                     label: const Text('Add Attachment'),
//                   ),
//                   const SizedBox(width: 8),
//                   Text('${_attachments.length} file(s) selected'),
//                 ],
//               ),
//               ..._attachments.asMap().entries.map((entry) {
//                 final idx = entry.key;
//                 final file = entry.value;
//                 return ListTile(
//                   title: Text(file.name),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(idx),
//                   ),
//                 );
//               }),
//               const SizedBox(height: 24),
//               // Submit Button
//               ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 child:
//                     _submitting
//                         ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                         : const Text('Submit'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:io';

import 'package:nhapp/utils/storage_utils.dart';

class AddQuotationPage extends StatefulWidget {
  const AddQuotationPage({Key? key}) : super(key: key);

  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // Form Controllers
  final TextEditingController _quoteToController = TextEditingController();
  final TextEditingController _billToController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Form Data
  String? _selectedQuotationBase;
  Map<String, dynamic>? _selectedQuoteTo;
  Map<String, dynamic>? _selectedBillTo;
  String? _selectedSalesman;
  String? _selectedLeadNumber;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _items = [];
  List<File> _attachments = [];

  // API Data
  List<Map<String, dynamic>> _quotationBases = [];
  List<Map<String, dynamic>> _salesmen = [];
  List<Map<String, dynamic>> _leadNumbers = [];
  Map<String, dynamic>? _documentDetail;

  // State Variables
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _baseUrl;

  // Totals
  double _basicAmount = 0.0;
  double _discountValue = 0.0;
  double _taxAmount = 0.0;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      _baseUrl = "http://${await StorageUtils.readValue("url")}";
      await _setupHeaders();
      await _loadInitialData();
      await _setDefaultDate();
    } catch (e) {
      _showError('Failed to initialize: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _getDocumentDetail(),
      _getQuotationBases(),
      _getSalesmen(),
    ]);
  }

  Future<void> _getDocumentDetail() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/Lead/GetDefaultDocumentDetail?year=25-26&type=SQ&subType=SQ&locationId=8',
      );

      if (response.data['success'] == true &&
          response.data['data'].isNotEmpty) {
        _documentDetail = response.data['data'][0];
      }
    } catch (e) {
      debugPrint('Error getting document detail: $e');
    }
  }

  Future<void> _getQuotationBases() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/Quotation/QuotationBaseList',
      );

      if (response.data['success'] == true) {
        setState(() {
          _quotationBases = List<Map<String, dynamic>>.from(
            response.data['data'],
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting quotation bases: $e');
    }
  }

  Future<void> _getSalesmen() async {
    try {
      final response = await _dio.get('$_baseUrl/api/Lead/LeadSalesManList');

      if (response.data['success'] == true) {
        setState(() {
          _salesmen = List<Map<String, dynamic>>.from(response.data['data']);
        });
      }
    } catch (e) {
      debugPrint('Error getting salesmen: $e');
    }
  }

  Future<void> _setDefaultDate() async {
    try {
      final financePeriod = await _storage.read(key: 'finance_period');
      if (financePeriod != null) {
        final now = DateTime.now();
        setState(() {
          _selectedDate = now;
          _dateController.text = '${now.day}/${now.month}/${now.year}';
        });
      }
    } catch (e) {
      debugPrint('Error setting default date: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _searchCustomers(String query) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/Quotation/QuotationGetCustomer',
        data: {
          "PageSize": 10,
          "PageNumber": 1,
          "SortField": "",
          "SortDirection": "",
          "SearchValue": query,
          "UserId": 2,
        },
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error searching customers: $e');
    }
    return [];
  }

  Future<void> _getLeadNumbers() async {
    if (_selectedBillTo == null) return;

    try {
      final customerCode = _selectedBillTo!['customerCode'];
      final response = await _dio.get(
        '$_baseUrl/api/Quotation/QuotationInquirygetOpenInquiryNumberList?customercode=$customerCode&userlocationcodes=\'CT2\'',
      );

      if (response.data['success'] == true) {
        setState(() {
          _leadNumbers = List<Map<String, dynamic>>.from(response.data['data']);
        });
      }
    } catch (e) {
      debugPrint('Error getting lead numbers: $e');
    }
  }

  Future<void> _getLeadDetails(String inquiryId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/API/Quotation/QuotationInquirygetInquiryDetail?InquiryId=$inquiryId',
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _prefillLeadData(data);
      }
    } catch (e) {
      debugPrint('Error getting lead details: $e');
    }
  }

  void _prefillLeadData(Map<String, dynamic> data) {
    setState(() {
      _items.clear();

      if (data['itemDetails'] != null) {
        for (var item in data['itemDetails']) {
          _items.add({
            'salesItemCode': item['salesItemCode'],
            'salesItemDesc': item['salesItemDesc'],
            'qtySUOM': item['qtySUOM'],
            'basicPriceSUOM': item['basicPriceSUOM'],
            'basicAmount': item['basicAmount'],
            'uom': item['uom'],
            'discountDetails': item['discountDetails'] ?? [],
            'rateStructureCode': item['rateStructureCode'],
            'rateStructureDetails': item['rateStructureDetails'] ?? [],
            'isFromLead': true,
          });
        }
      }

      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double basicAmount = 0;
    double discountValue = 0;
    double taxAmount = 0;
    double totalAmount = 0;

    for (var item in _items) {
      basicAmount += (item['basicAmount'] ?? 0.0);

      if (item['discountDetails'] != null) {
        for (var discount in item['discountDetails']) {
          discountValue += (discount['discountValue'] ?? 0.0);
        }
      }

      if (item['rateStructureDetails'] != null) {
        for (var rate in item['rateStructureDetails']) {
          if (rate['postNonPost'] == true) {
            taxAmount += (rate['rateAmount'] ?? 0.0);
          }
        }
      }
    }

    totalAmount = basicAmount - discountValue + taxAmount;

    setState(() {
      _basicAmount = basicAmount;
      _discountValue = discountValue;
      _taxAmount = taxAmount;
      _totalAmount = totalAmount;
    });
  }

  void _onQuotationBaseChanged(String? value) {
    setState(() {
      _selectedQuotationBase = value;

      if (value != 'I') {
        _selectedLeadNumber = null;
        _leadNumbers.clear();
        _items.removeWhere((item) => item['isFromLead'] == true);
        _calculateTotals();
      }
    });
  }

  void _onBillToChanged(Map<String, dynamic>? customer) {
    setState(() {
      _selectedBillTo = customer;
      _selectedLeadNumber = null;
      _leadNumbers.clear();
      _items.removeWhere((item) => item['isFromLead'] == true);
      _calculateTotals();
    });

    if (customer != null && _selectedQuotationBase == 'I') {
      _getLeadNumbers();
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => AddItemPage(baseUrl: _baseUrl!)),
    );

    if (result != null) {
      setState(() {
        _items.add(result);
        _calculateTotals();
      });
    }
  }

  void _editItem(int index) async {
    final item = _items[index];
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemPage(
              baseUrl: _baseUrl!,
              editItem: item,
              isFromLead: item['isFromLead'] == true,
            ),
      ),
    );

    if (result != null) {
      setState(() {
        _items[index] = result;
        _calculateTotals();
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
      _calculateTotals();
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      _showError('At least one item is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final quotationData = _buildQuotationData();

      final response = await _dio.post(
        '$_baseUrl/API/Quotation/QuotationCreate',
        data: quotationData,
      );

      if (response.data['success'] == true) {
        if (_attachments.isNotEmpty) {
          final quotationNumber =
              response.data['data']['quotationDetails']['quotationNumber'];
          await _uploadAttachments(quotationNumber);
        }

        Navigator.pop(context);
        _showSuccess('Quotation created successfully');
      } else {
        _showError(
          response.data['errorMessage'] ?? 'Failed to create quotation',
        );
      }
    } catch (e) {
      _showError('Error creating quotation: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Map<String, dynamic> _buildQuotationData() {
    return {
      "authorizationRequired":
          _documentDetail?['isAutorisationRequired'] == true ? "Y" : "N",
      "autoNumberRequired":
          _documentDetail?['isAutoNumberGenerated'] == true ? "Y" : "N",
      "siteRequired":
          _documentDetail?['isLocationRequired'] == true ? "Y" : "N",
      "authorizationDate": "06/09/2025",
      "fromLocationId": _documentDetail?['locationId'] ?? 8,
      "userId": 2,
      "companyId": 1,
      "fromLocationCode": _documentDetail?['locationCode'] ?? "CT2",
      "fromLocationName": _documentDetail?['locationName'] ?? "CTPL Unit2",
      "ip": "",
      "mac": "",
      "domesticCurrencyCode": "INR",
      "quotationDetails": {
        "customerCode": _selectedBillTo?['customerCode'],
        "quotationYear": "24-25",
        "quotationGroup": _documentDetail?['groupCode'] ?? "QA",
        "quotationNumber": 0,
        "quotationDate":
            _selectedDate != null
                ? "${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}"
                : "01/01/2025",
        "salesPersonCode": _selectedSalesman ?? "",
        "validity": "30",
        "attachFlag": _attachments.isNotEmpty ? "Y" : "N",
        "totalAmounttAfterTaxDomesticCurrency": _totalAmount.toString(),
        "totalAmountAfterTaxCustomerCurrency": _totalAmount.toString(),
        "totalAmountAfterDiscountCustomerCurrency":
            (_basicAmount - _discountValue).toString(),
        "exchangeRate": "1",
        "discountType": "None",
        "discountAmount": "0",
        "modValue": 0,
        "subject": _subjectController.text,
        "kindAttentionName": "",
        "kindAttentionDesignation": "",
        "destination": "",
        "authorizedSignatoryName": "",
        "authorizedSignatoryDesignation": "",
        "customerInqRefNo": "",
        "customerInqRefDate": "",
        "customerName": _selectedBillTo?['customerName'],
        "inquiryDate": null,
        "quotationSiteId": (_documentDetail?['locationId'] ?? 8).toString(),
        "quotationSiteCode": _documentDetail?['locationCode'] ?? "CT2",
        "quotationId": 0,
        "inquiryId":
            _selectedLeadNumber != null
                ? int.tryParse(_selectedLeadNumber!) ?? 0
                : 0,
        "quotationTypeSalesOrder": "REG",
        "ProjectItemId": 0,
        "ProjectItemCode": "",
        "isAgentAssociated": false,
        "projectName": "",
        "contactEmail": "",
        "contactNo": "",
        "submittedDate": null,
        "isBudgetaryQuotation": false,
        "quotationStatus": "NS",
        "quotationAmendDate": null,
        "currencyCode": "INR",
        "agentCode": "",
        "quotationTypeConfig": "N",
        "reasonCode": "",
        "consultantCode": "",
        "billToCustomerCode": _selectedBillTo?['customerCode'],
        "amendmentSrNo": "0",
        "xqdbookcd": "",
      },
      "modelDetails": _buildModelDetails(),
      "discountDetails": _buildDiscountDetails(),
      "rateStructureDetails": _buildRateStructureDetails(),
      "historyDetails": [],
      "noteDetails": [],
      "equipmentAttributeDetails": [],
      "addOnDetails": [],
      "subItemDetails": [],
      "standardTerms": [],
      "quotationRemarks": [],
      "msctechspecifications": false,
      "mscSameItemAllowMultitimeFlag": true,
    };
  }

  List<Map<String, dynamic>> _buildModelDetails() {
    return _items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      return {
        "itemLineNo": index + 1,
        "customerCode": _selectedBillTo?['customerCode'],
        "quotationOrderNumber": "",
        "modelNo": "",
        "salesItemCode": item['salesItemCode'],
        "qtyIUOM": item['qtySUOM'],
        "basicPriceIUOM": item['basicPriceSUOM'],
        "discountType": item['discountType'] ?? "None",
        "discountValue": item['discountValue'] ?? 0,
        "discountAmt": item['discountAmount'] ?? 0,
        "qtySUOM": item['qtySUOM'],
        "basicPriceSUOM": item['basicPriceSUOM'],
        "conversionFactor": 1,
        "itemOrderQty": 0,
        "allQty": 0,
        "amendmentSrNo": "0",
        "cancelQty": 0,
        "salesItemType": "M",
        "currencyCode": "INR",
        "rateProcess": "N",
        "rateStructureCode": item['rateStructureCode'],
        "tolerance": 0,
        "amendmentYear": "",
        "amendmentGroup": "",
        "amendmentSiteId": 0,
        "amendmentNo": "",
        "amendmentDate": null,
        "amendmentAuthBy": 0,
        "amendmentAuthDate": null,
        "invoiceMethod": "Q",
        "agentCode": "",
        "subProjectId": 0,
        "sectionId": 0,
        "groupId": 0,
        "subGroupId": 0,
        "customerPOItemSrNo": index + 1,
        "drawingNo": "",
        "quotationLineNo": 0,
        "quotationAmendNo": 0,
        "amendmentChargable": "A",
        "amendmentCBOMChange": "A",
        "oldCustomerPOReference": "",
        "reasonCode": "",
        "salesReasonCode": "",
        "deliveryDay": 0,
        "invoiceType": "Regular",
        "oldSalesItemCode": "",
        "oldInternalItemCode": "",
        "itemAmountAfterDisc":
            item['basicAmount'] - (item['discountAmount'] ?? 0),
        "isGroupSpare": "",
        "hsnCode": item['hsnCode'] ?? "",
        "detaildescription": "",
        "loadRate": 0,
        "netRate":
            (item['basicPriceSUOM'] ?? 0) -
            ((item['discountAmount'] ?? 0) / (item['qtySUOM'] ?? 1)),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _buildDiscountDetails() {
    List<Map<String, dynamic>> discountDetails = [];

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item['discountType'] != null && item['discountType'] != 'None') {
        discountDetails.add({
          "salesItemCode": item['salesItemCode'],
          "currencyCode": "INR",
          "discountCode": "001",
          "discountType": item['discountType'],
          "discountValue": item['discountValue'] ?? 0,
          "amendSrNo": "0",
          "itmLineNo": i + 1,
        });
      }
    }

    return discountDetails;
  }

  List<Map<String, dynamic>> _buildRateStructureDetails() {
    List<Map<String, dynamic>> rateStructureDetails = [];

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item['rateStructureDetails'] != null) {
        for (var rate in item['rateStructureDetails']) {
          rateStructureDetails.add({
            "customerItemCode": item['salesItemCode'],
            "rateCode": rate['rateCode'],
            "incOrExc": rate['ie'],
            "perOrVal": rate['pv'],
            "taxValue": rate['taxValue'].toString(),
            "applicationOn": rate['applicableOn'],
            "currencyCode": "INR",
            "sequenceNo": rate['sequenceNo'].toString(),
            "postNonPost": rate['postnonpost'],
            "taxType": rate['taxType'],
            "rateSturctureCode": item['rateStructureCode'],
            "rateAmount": rate['rateAmount'] ?? 0,
            "amendSrNo": "0",
            "refId": i,
            "itmModelRefNo": i + 1,
          });
        }
      }
    }

    return rateStructureDetails;
  }

  Future<void> _uploadAttachments(String quotationNumber) async {
    try {
      // Implementation would use the existing uploadAttachments method
    } catch (e) {
      debugPrint('Error uploading attachments: $e');
    }
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Quotation'), elevation: 0),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuotationBaseField(),
                    const SizedBox(height: 16),
                    _buildQuoteToField(),
                    const SizedBox(height: 16),
                    _buildBillToField(),
                    const SizedBox(height: 16),
                    _buildSalesmanField(),
                    const SizedBox(height: 16),
                    _buildSubjectField(),
                    const SizedBox(height: 16),
                    if (_selectedQuotationBase == 'I') ...[
                      _buildLeadNumberField(),
                      const SizedBox(height: 16),
                    ],
                    _buildDateField(),
                    const SizedBox(height: 24),
                    _buildItemsList(),
                    const SizedBox(height: 16),
                    _buildAddItemButton(),
                    const SizedBox(height: 24),
                    _buildTotalCard(),
                    const SizedBox(height: 24),
                    _buildAttachmentsSection(),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationBaseField() {
    return DropdownButtonFormField<String>(
      value: _selectedQuotationBase,
      decoration: const InputDecoration(
        labelText: 'Quotation Base *',
        border: OutlineInputBorder(),
      ),
      items:
          _quotationBases.map((base) {
            return DropdownMenuItem<String>(
              value: base['Code'],
              child: Text(base['Name']),
            );
          }).toList(),
      onChanged: _isSubmitting ? null : _onQuotationBaseChanged,
      validator:
          (value) => value == null ? 'Please select quotation base' : null,
    );
  }

  Widget _buildQuoteToField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _quoteToController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Quote to *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select quote to';
            }
            return null;
          },
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length >= 4) {
          return await _searchCustomers(pattern);
        }
        return [];
      },
      itemBuilder: (context, customer) {
        return ListTile(
          title: Text(customer['customerFullName'] ?? ''),
          subtitle: Text(customer['address1'] ?? ''),
        );
      },
      onSelected: (customer) {
        setState(() {
          _selectedQuoteTo = customer;
          _quoteToController.text = customer['customerFullName'] ?? '';
          // Auto-fill Bill To with same value
          _selectedBillTo = customer;
          _billToController.text = customer['customerFullName'] ?? '';
        });
      },
    );
  }

  Widget _buildBillToField() {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _billToController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Bill to *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select bill to';
            }
            return null;
          },
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length >= 4) {
          return await _searchCustomers(pattern);
        }
        return [];
      },
      itemBuilder: (context, customer) {
        return ListTile(
          title: Text(customer['customerFullName'] ?? ''),
          subtitle: Text(customer['address1'] ?? ''),
        );
      },
      onSelected: (customer) {
        _billToController.text = customer['customerFullName'] ?? '';
        _onBillToChanged(customer);
      },
    );
  }

  Widget _buildSalesmanField() {
    return DropdownButtonFormField<String>(
      value: _selectedSalesman,
      decoration: const InputDecoration(
        labelText: 'Salesman *',
        border: OutlineInputBorder(),
      ),
      items:
          _salesmen.map((salesman) {
            return DropdownMenuItem<String>(
              value: salesman['salesmanCode'],
              child: Text(salesman['salesManFullName']),
            );
          }).toList(),
      onChanged:
          _isSubmitting
              ? null
              : (value) {
                setState(() => _selectedSalesman = value);
              },
      validator: (value) => value == null ? 'Please select salesman' : null,
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      enabled: !_isSubmitting,
      decoration: const InputDecoration(
        labelText: 'Subject *',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter subject';
        }
        return null;
      },
    );
  }

  Widget _buildLeadNumberField() {
    return DropdownButtonFormField<String>(
      value: _selectedLeadNumber,
      decoration: const InputDecoration(
        labelText: 'Lead Number *',
        border: OutlineInputBorder(),
      ),
      items:
          _leadNumbers.map((lead) {
            return DropdownMenuItem<String>(
              value: lead['inquiryId'].toString(),
              child: Text('${lead['inquiryNumber']} - ${lead['customerName']}'),
            );
          }).toList(),
      onChanged:
          _isSubmitting
              ? null
              : (value) {
                setState(() => _selectedLeadNumber = value);
                if (value != null) {
                  _getLeadDetails(value);
                }
              },
      validator: (value) {
        if (_selectedQuotationBase == 'I' && value == null) {
          return 'Please select lead number';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      enabled: !_isSubmitting,
      decoration: const InputDecoration(
        labelText: 'Date *',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (date != null) {
          setState(() {
            _selectedDate = date;
            _dateController.text = '${date.day}/${date.month}/${date.year}';
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select date';
        }
        return null;
      },
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No items added yet'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final item = _items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item['salesItemDesc'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qty: ${item['qtySUOM']} ${item['uom']}'),
                      Text('Rate: ₹${item['basicPriceSUOM']}'),
                      Text('Amount: ₹${item['basicAmount']}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed:
                            _isSubmitting ? null : () => _editItem(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            _isSubmitting ? null : () => _deleteItem(index),
                      ),
                    ],
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
        onPressed: _isSubmitting ? null : _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Basic Amount:'),
                Text('₹${_basicAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount:'),
                Text('-₹${_discountValue.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tax Amount:'),
                Text('₹${_taxAmount.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '₹${_totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attachments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Files'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_attachments.isEmpty)
          const Text('No attachments added')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attachments.length,
            itemBuilder: (context, index) {
              final file = _attachments[index];
              return ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(file.path.split('/').last),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      _isSubmitting ? null : () => _removeAttachment(index),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Submit Quotation'),
      ),
    );
  }

  @override
  void dispose() {
    _quoteToController.dispose();
    _billToController.dispose();
    _subjectController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

// Add Item Page
class AddItemPage extends StatefulWidget {
  final String baseUrl;
  final Map<String, dynamic>? editItem;
  final bool isFromLead;

  const AddItemPage({
    Key? key,
    required this.baseUrl,
    this.editItem,
    this.isFromLead = false,
  }) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  // Controllers
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _discountPercentageController =
      TextEditingController();
  final TextEditingController _discountAmountController =
      TextEditingController();

  // Form Data
  Map<String, dynamic>? _selectedItem;
  String _discountType = 'None';
  String? _selectedRateStructure;

  // API Data
  List<Map<String, dynamic>> _rateStructures = [];
  List<Map<String, dynamic>> _rateStructureDetails = [];

  // State
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    try {
      await _setupHeaders();
      await _getRateStructures();

      if (widget.editItem != null) {
        _prefillData();
      }
    } catch (e) {
      _showError('Failed to initialize: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setupHeaders() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> _getRateStructures() async {
    try {
      final response = await _dio.get(
        '${widget.baseUrl}/api/Quotation/QuotationGetRateStructureForSales?companyID=1&currencyCode=INR',
      );

      if (response.data['success'] == true) {
        setState(() {
          _rateStructures = List<Map<String, dynamic>>.from(
            response.data['data'],
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting rate structures: $e');
    }
  }

  void _prefillData() {
    final item = widget.editItem!;

    setState(() {
      _selectedItem = item;
      _itemController.text = item['salesItemDesc'] ?? '';
      _qtyController.text = item['qtySUOM']?.toString() ?? '';
      _rateController.text = item['basicPriceSUOM']?.toString() ?? '';
      _selectedRateStructure = item['rateStructureCode'];

      if (item['discountType'] != null && item['discountType'] != 'None') {
        _discountType = item['discountType'];
        if (_discountType == 'Percentage') {
          _discountPercentageController.text =
              item['discountValue']?.toString() ?? '';
        } else if (_discountType == 'Value') {
          _discountAmountController.text =
              item['discountAmount']?.toString() ?? '';
        }
      }

      _rateStructureDetails = List<Map<String, dynamic>>.from(
        item['rateStructureDetails'] ?? [],
      );
    });
  }

  Future<List<Map<String, dynamic>>> _searchItems(String query) async {
    try {
      final response = await _dio.post(
        '${widget.baseUrl}/api/Lead/GetSalesItemList?flag=L',
        data: {
          "pageSize": 10,
          "pageNumber": 1,
          "sortField": "",
          "sortDirection": "",
          "searchValue": query,
        },
      );

      if (response.data['success'] == true) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    } catch (e) {
      debugPrint('Error searching items: $e');
    }
    return [];
  }

  void _onItemSelected(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _itemController.text = item['salesItemFullName'] ?? '';
      _rateController.text = '0';
    });
  }

  void _onDiscountTypeChanged(String? value) {
    setState(() {
      _discountType = value ?? 'None';
      _discountPercentageController.clear();
      _discountAmountController.clear();
    });
  }

  void _submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final qty = double.tryParse(_qtyController.text) ?? 0;
      final rate = double.tryParse(_rateController.text) ?? 0;
      final basicAmount = qty * rate;

      double discountValue = 0;
      double discountAmount = 0;

      if (_discountType == 'Percentage') {
        discountValue =
            double.tryParse(_discountPercentageController.text) ?? 0;
        discountAmount = (basicAmount * discountValue) / 100;
      } else if (_discountType == 'Value') {
        discountAmount = double.tryParse(_discountAmountController.text) ?? 0;
        discountValue = discountAmount;
      }

      final itemData = {
        'salesItemCode': _selectedItem!['itemCode'],
        'salesItemDesc': _selectedItem!['salesItemFullName'],
        'qtySUOM': qty,
        'basicPriceSUOM': rate,
        'basicAmount': basicAmount,
        'uom': _selectedItem!['salesUOM'],
        'discountType': _discountType,
        'discountValue': discountValue,
        'discountAmount': discountAmount,
        'rateStructureCode': _selectedRateStructure,
        'rateStructureDetails': _rateStructureDetails,
        'hsnCode': _selectedItem!['hsnCode'],
        'isFromLead': widget.isFromLead,
      };

      Navigator.pop(context, itemData);
    } catch (e) {
      _showError('Error submitting item: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editItem != null ? 'Edit Item' : 'Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildItemNameField(),
                    const SizedBox(height: 16),
                    _buildQtyField(),
                    const SizedBox(height: 16),
                    _buildRateField(),
                    const SizedBox(height: 16),
                    _buildDiscountTypeField(),
                    const SizedBox(height: 16),
                    if (_discountType == 'Percentage')
                      _buildDiscountPercentageField(),
                    if (_discountType == 'Value') _buildDiscountAmountField(),
                    if (_discountType != 'None') const SizedBox(height: 16),
                    _buildRateStructureField(),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemNameField() {
    if (widget.isFromLead) {
      return TextFormField(
        controller: _itemController,
        enabled: false,
        decoration: const InputDecoration(
          labelText: 'Item Name *',
          border: OutlineInputBorder(),
        ),
      );
    }

    return TypeAheadField<Map<String, dynamic>>(
      controller: _itemController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_isSubmitting,
          decoration: const InputDecoration(
            labelText: 'Item Name *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an item';
            }
            return null;
          },
        );
      },
      suggestionsCallback: (pattern) async {
        if (pattern.length >= 4) {
          return await _searchItems(pattern);
        }
        return [];
      },
      itemBuilder: (context, item) {
        return ListTile(
          title: Text(item['salesItemFullName'] ?? ''),
          subtitle: Text(item['itemCode'] ?? ''),
        );
      },
      onSelected: _onItemSelected,
    );
  }

  Widget _buildQtyField() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: _qtyController,
            enabled: !_isSubmitting,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              labelText: 'Quantity *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter quantity';
              final qty = double.tryParse(value);
              if (qty == null || qty <= 0) return 'Please enter valid quantity';
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: _selectedItem?['salesUOM'] ?? '',
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'UOM',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRateField() {
    return TextFormField(
      controller: _rateController,
      enabled: !_isSubmitting,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        labelText: 'Basic Rate *',
        border: OutlineInputBorder(),
        prefixText: '₹ ',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter basic rate';
        final rate = double.tryParse(value);
        if (rate == null || rate <= 0) return 'Please enter valid rate';
        return null;
      },
    );
  }

  Widget _buildDiscountTypeField() {
    return DropdownButtonFormField<String>(
      value: _discountType,
      decoration: const InputDecoration(
        labelText: 'Discount Type *',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'None', child: Text('None')),
        DropdownMenuItem(value: 'Percentage', child: Text('Percentage')),
        DropdownMenuItem(value: 'Value', child: Text('Value')),
      ],
      onChanged: _isSubmitting ? null : _onDiscountTypeChanged,
    );
  }

  Widget _buildDiscountPercentageField() {
    return TextFormField(
      controller: _discountPercentageController,
      enabled: !_isSubmitting,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        labelText: 'Discount Percentage *',
        border: OutlineInputBorder(),
        suffixText: '%',
      ),
      validator: (value) {
        if (_discountType == 'Percentage') {
          if (value == null || value.isEmpty)
            return 'Please enter discount percentage';
          final percentage = double.tryParse(value);
          if (percentage == null || percentage <= 0 || percentage >= 100) {
            return 'Please enter percentage between 1 and 99';
          }
        }
        return null;
      },
    );
  }

  Widget _buildDiscountAmountField() {
    return TextFormField(
      controller: _discountAmountController,
      enabled: !_isSubmitting,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        labelText: 'Discount Amount *',
        border: OutlineInputBorder(),
        prefixText: '₹ ',
      ),
      validator: (value) {
        if (_discountType == 'Value') {
          if (value == null || value.isEmpty)
            return 'Please enter discount amount';
          final discountAmount = double.tryParse(value);
          final basicRate = double.tryParse(_rateController.text) ?? 0;
          final qty = double.tryParse(_qtyController.text) ?? 0;
          final basicAmount = basicRate * qty;

          if (discountAmount == null || discountAmount <= 0) {
            return 'Please enter valid discount amount';
          }
          if (discountAmount >= basicAmount) {
            return 'Discount cannot be greater than or equal to basic amount';
          }
        }
        return null;
      },
    );
  }

  Widget _buildRateStructureField() {
    return DropdownButtonFormField<String>(
      value: _selectedRateStructure,
      decoration: const InputDecoration(
        labelText: 'Rate Structure *',
        border: OutlineInputBorder(),
      ),
      items:
          _rateStructures.map((structure) {
            return DropdownMenuItem<String>(
              value: structure['rateStructCode'],
              child: Text(structure['rateStructFullName']),
            );
          }).toList(),
      onChanged:
          _isSubmitting
              ? null
              : (value) {
                setState(() => _selectedRateStructure = value);
              },
      validator:
          (value) => value == null ? 'Please select rate structure' : null,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitItem,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(widget.editItem != null ? 'Update Item' : 'Add Item'),
      ),
    );
  }

  @override
  void dispose() {
    _itemController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _discountPercentageController.dispose();
    _discountAmountController.dispose();
    super.dispose();
  }
}
