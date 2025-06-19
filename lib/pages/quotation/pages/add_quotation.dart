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

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/quotation/models/add_quotation.dart';
import 'package:nhapp/pages/quotation/pages/add_quotation_item_page.dart';
import 'package:nhapp/pages/quotation/service/add_quotation.dart';

class AddQuotationPage extends StatefulWidget {
  const AddQuotationPage({super.key});

  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  final _formKey = GlobalKey<FormState>();
  late final QuotationFormService _service;

  // Form fields
  List<QuotationBase> _quotationBases = [];
  QuotationBase? _selectedQuotationBase;

  QuotationCustomer? _selectedQuoteTo;
  QuotationCustomer? _selectedBillTo;
  final TextEditingController _quoteToController = TextEditingController();
  final TextEditingController _billToController = TextEditingController();

  List<Salesman> _salesmen = [];
  Salesman? _selectedSalesman;

  final TextEditingController _subjectToController = TextEditingController();
  DateTime _date = DateTime.now();

  final List<Map<String, dynamic>> _items = [];
  final List<PlatformFile> _attachments = [];

  bool _loading = true;
  bool _submitting = false;

  // Additional fields from APIs
  String? _year;
  DateTime? _minDate;
  DateTime? _maxDate;
  int? _siteId;
  int? _userId;
  String? _leadNumber; // For manual numbering if needed.
  String? _documentNo;

  @override
  void initState() {
    super.initState();
    _service = QuotationFormService();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      // For simplicity, assume these values come from storage.
      // _siteId = 8;
      // _userId = 2;

      // 1. Fetch current year date range for datepicker limits.
      final dateRange = await _service.fetchDateRange();
      _minDate =
          dateRange["periodSDt"] != null
              ? DateTime.parse(dateRange["periodSDt"])
              : DateTime.now();
      _maxDate =
          dateRange["periodEDt"] != null
              ? DateTime.parse(dateRange["periodEDt"])
              : DateTime.now();
      _year = dateRange["financialYear"] ?? "";

      // 2. Fetch default document details (Quotation type).
      // final docDetail = await _service.fetchDefaultDocDetail(year: _year!);

      // 3. Load dropdowns.
      final bases = await _service.fetchQuotationBases();
      final salesmen = await _service.fetchSalesmen();
      setState(() {
        _quotationBases = bases;
        _salesmen = salesmen;
        _date = DateTime.now();
        if (_date.isBefore(_minDate!)) _date = _minDate!;
        if (_date.isAfter(_maxDate!)) _date = _maxDate!;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _items.add(item);
    });
  }

  void _editItem(int index, Map<String, dynamic> item) {
    setState(() {
      _items[index] = item;
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
    );
    if (result != null) _addItem(result);
  }

  void _openEditItem(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
      ),
    );
    if (result != null) _editItem(index, result);
  }

  Map<String, double> getTotals() {
    double basic = 0, discount = 0, tax = 0, total = 0;
    for (final item in _items) {
      basic += (item['basicAmount'] ?? 0) as double;
      tax += (item['taxAmount'] ?? 0) as double;
      total += (item['totalAmount'] ?? 0) as double;
      discount += (item['discountValue'] ?? 0) as double;
    }
    return {'basic': basic, 'discount': discount, 'tax': tax, 'total': total};
  }

  /// Build ModelDetails list based on items.
  List<Map<String, dynamic>> _buildModelDetails() {
    List<Map<String, dynamic>> models = [];
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      models.add({
        "AgentCode": "",
        "AgentCommisionTypeText": "NONE",
        "AgentCommisionValue": 0,
        "AllQty": 0,
        "AlreadyInvoiceBasicValue": 0,
        "AmendmentCBOMChange": "A",
        "AmendmentCBOMChangeText": "NOTAPPLICABLE",
        "AmendmentChargable": "A",
        "AmendmentChargableText": "NOTAPPLICABLE",
        "AmendmentGroup": "",
        "AmendmentNo": "",
        "AmendmentSiteId": 0,
        "AmendmentSrNo": 0,
        "AmendmentYear": "",
        "ApplicationCode": "",
        "BasicPriceIUOM": item['rate'],
        "BasicPriceSUOM": item['rate'],
        "CancelQty": 0,
        "ConversionFactor": 1,
        "CurrencyCode": "INR",
        "CustomerPOItemSrNo": "1",
        "DeliveryDay": 0,
        "DiscountAmt": item['discountValue'] ?? 0,
        "DiscountType": item['discountType'] ?? "",
        "DiscountTypeText":
            (item['discountType'] ?? "").toLowerCase() == "percentage"
                ? "PERCENTAGE"
                : "",
        "DiscountValue": item['discountValue'] ?? 0.0,
        "DrawingNo": "",
        "GroupId": 0,
        "InvoiceMethod": "Q",
        "InvoiceType": "Regular",
        "InvoiceTypeShortText": "R",
        "IsSubItem": false,
        "ItemAmountAfterDisc": item['basicAmount'] ?? 0,
        "ItemLineNo": i + 1,
        "ItemOrderQty": 0,
        "OriginalBasicPrice": 0,
        "QtyIUOM": item['qty'],
        "QtySUOM": item['qty'],
        "QuotationAmendNo": 0,
        "QuotationId": 0,
        "QuotationLineNo": i + 1,
        "RateStructureCode": item['rateStructure'] ?? "",
        "SalesItemCode": item['itemCode'] ?? "",
        "SalesItemDesc": item['itemName'] ?? "",
        "SalesItemType": "S",
        "SectionId": 0,
        "SubGroupId": 0,
        "SubProjectId": 0,
        "TagNo": "",
        "Tolerance": 0,
      });
    }
    return models;
  }

  /// Build DiscountDetails list.
  List<Map<String, dynamic>> _buildDiscountDetails() {
    List<Map<String, dynamic>> discountDetails = [];
    for (final item in _items) {
      if ((item['discountValue'] ?? 0) > 0 &&
          (item['discountType'] ?? "").toString().toLowerCase() != "none") {
        discountDetails.add({
          "AmendSrNo": 0,
          "CurrencyCode": "INR",
          "DiscountCode": item['discountCode'],
          "DiscountType": item['discountType'],
          "DiscountValue": item['discountValue'],
          "SalesItemCode": item['itemCode'],
        });
      }
    }
    return discountDetails;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all required fields and add at least one item',
          ),
        ),
      );
      return;
    }
    setState(() {
      _submitting = true;
    });

    try {
      // Step 1: Fetch default document details.
      final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
      if (docDetail.isEmpty) {
        setState(() {
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch document details')),
        );
        return;
      }

      final submissionData = QuotationSubmissionData(
        docDetail: docDetail,
        quoteTo: _selectedQuoteTo!,
        billTo: _selectedBillTo!,
        salesman: _selectedSalesman!,
        subject: _subjectToController.text,
        quotationDate: _date,
        quotationYear: _year!,
        siteId: _siteId!,
        userId: _userId!,
        items: _items,
      );

      final submissionResponse = await _service.submitQuotation(submissionData);

      // Step 3: Submit the quotation payload.
      // final submissionResponse = await _service.submitQuotation(payload);
      if (submissionResponse['success'] == true) {
        final quotationId =
            submissionResponse['data']?['quotationId'] ??
            submissionResponse['data']?['QuotationId'];

        // Step 4: Upload attachments if any.
        bool attachSuccess = true;
        if (_attachments.isNotEmpty) {
          attachSuccess = await _service.uploadAttachments(
            filePaths: _attachments.map((f) => f.path!).toList(),
            documentNo: submissionResponse['data']?['QuotationNumber'] ?? "",
            documentId: quotationId.toString(),
            docYear: _year!,
            formId: docDetail["formId"] ?? "06100",
            locationCode: docDetail["locationCode"],
            companyCode: docDetail["companyCode"] ?? "",
            locationId: _siteId!,
            companyId: docDetail["CompanyId"] ?? 1,
            userId: _userId!,
          );
        }
        setState(() {
          _submitting = false;
        });
        if (attachSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quotation created successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quotation created, but attachment upload failed'),
            ),
          );
        }
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _submitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create quotation')),
        );
      }
    } catch (e) {
      setState(() {
        _submitting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totals = getTotals();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Quotation')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quotation Base Dropdown
              DropdownButtonFormField<QuotationBase>(
                decoration: const InputDecoration(labelText: 'Quotation Base'),
                value: _selectedQuotationBase,
                items:
                    _quotationBases
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)),
                        )
                        .toList(),
                onChanged:
                    (v) => setState(() {
                      _selectedQuotationBase = v;
                    }),
                validator: (v) => v == null ? 'Select Quotation Base' : null,
              ),
              const SizedBox(height: 16),

              // Quote To (TypeAheadField)
              TypeAheadField<QuotationCustomer>(
                controller: _quoteToController,
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) return [];
                  return await _service.searchCustomers(pattern);
                },
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Quote To'),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select Quote To'
                                  : null,
                    ),
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedQuoteTo = suggestion;
                    _quoteToController.text = suggestion.customerFullName;
                    // Default Bill To set to Quote To by default.
                    _selectedBillTo = suggestion;
                    _billToController.text = suggestion.customerFullName;
                  });
                },
                emptyBuilder: (context) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // Bill To (TypeAheadField)
              TypeAheadField<QuotationCustomer>(
                controller: _billToController,
                suggestionsCallback:
                    (pattern) => _service.searchCustomers(pattern),
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Bill To'),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Select Bill To'
                                  : null,
                    ),
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedBillTo = suggestion;
                    _billToController.text = suggestion.customerFullName;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Salesman Dropdown
              DropdownButtonFormField<Salesman>(
                decoration: const InputDecoration(labelText: 'Salesman'),
                value: _selectedSalesman,
                items:
                    _salesmen
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.salesManFullName),
                          ),
                        )
                        .toList(),
                onChanged:
                    (v) => setState(() {
                      _selectedSalesman = v;
                    }),
                validator: (v) => v == null ? 'Select Salesman' : null,
              ),
              const SizedBox(height: 16),

              // Subject To Field
              TextFormField(
                controller: _subjectToController,
                decoration: const InputDecoration(labelText: 'Subject To'),
                validator:
                    (val) =>
                        (val == null || val.isEmpty) ? 'Enter Subject' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker using disabled dates from API
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: _minDate ?? DateTime(2000),
                      lastDate: _maxDate ?? DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _date = picked;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(DateFormat('yyyy-MM-dd').format(_date)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Items Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Item'),
                  ),
                ],
              ),
              ..._items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['itemName'] ?? '',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Qty: ${item['qty']}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Rate: ${item['rate']}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Total: ${item['totalAmount']}',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEditItem(idx),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(idx),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Total Card
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Amount: ₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      Text(
                        'Discount Value: ₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      Text(
                        'Tax Amount: ₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                      Text(
                        'Total Amount: ₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Attachments Section
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add Attachment'),
                  ),
                  const SizedBox(width: 8),
                  Text('${_attachments.length} file(s) selected'),
                ],
              ),
              ..._attachments.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                return ListTile(
                  title: Text(file.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        _submitting ? null : () => _removeAttachment(idx),
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Submit Button
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child:
                    _submitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
