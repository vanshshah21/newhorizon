// // lib/pages/add_quotation_page.dart

// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:nhapp/pages/Quotation2/models/add_quotation.dart';
// import 'package:nhapp/pages/Quotation2/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/Quotation2/services/quotation_service.dart';
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

//   // All flows use same Quote To and Bill To (regular API)
//   QuotationCustomer? _selectedQuoteTo;
//   QuotationCustomer? _selectedBillTo;
//   final TextEditingController _quoteToController = TextEditingController();
//   final TextEditingController _billToController = TextEditingController();

//   Salesman? _selectedSalesman;
//   final TextEditingController _subjectToController = TextEditingController();

//   // Lead Number: Shown only if the selected quotation base requires inquiry.
//   String? _selectedLeadNumber;
//   List<String> _leadNumbers = [];

//   DateTime _date = DateTime.now();
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   String? _year;
//   int? _siteId;
//   int? _userId;
//   String? _documentNo;

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;

//   // Determine if the selected quotation base requires a Lead Number.
//   bool get _isInquiryReference =>
//       _selectedQuotationBase != null &&
//       _selectedQuotationBase!.name.toLowerCase().contains('inquiry');

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() => _loading = true);
//     try {
//       // 1. Fetch current year date range.
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
//       _siteId = dateRange["siteId"] ?? 0;

//       // 2. Fetch default document details.
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       await StorageUtils.writeJson("docDetail", docDetail);

//       // 3. Load dropdown data.
//       final bases = await _service.fetchQuotationBases();
//       setState(() {
//         _quotationBases = bases;
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

//   /// Load Lead Numbers based on selected Bill To.
//   Future<void> _loadLeadNumbers() async {
//     try {
//       if (_selectedBillTo != null) {
//         final leads = await _service.fetchLeadNumbers(
//           customerCode: _selectedBillTo!.customerCode,
//         );
//         setState(() {
//           _leadNumbers = leads;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching lead numbers: $e')),
//       );
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
//     if (result != null) {
//       _editItem(index, result);
//     }
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
//       final docDetail =
//           await StorageUtils.readJson("docDetail") as Map<String, dynamic>?;

//       if (docDetail == null || docDetail.isEmpty) {
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
//         userId: _userId ?? 0,
//         items: _items,
//       );

//       final submissionResponse = await _service.submitQuotation(submissionData);

//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

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
//             userId: _userId ?? 0,
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
//                 onChanged: (v) {
//                   setState(() {
//                     _selectedQuotationBase = v;
//                     // Clear lead number when quotation base changes.
//                     if (!_isInquiryReference) {
//                       _selectedLeadNumber = null;
//                       _leadNumbers = [];
//                     }
//                   });
//                 },
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
//                     // Auto-fill Bill To with the same value.
//                     _selectedBillTo = suggestion;
//                     _billToController.text = suggestion.customerFullName;
//                     // If lead number is applicable, load lead numbers.
//                     if (_isInquiryReference) {
//                       _loadLeadNumbers();
//                     }
//                   });
//                 },
//                 emptyBuilder: (context) => const SizedBox(),
//               ),
//               const SizedBox(height: 16),

//               // Bill To (TypeAheadField)
//               TypeAheadField<QuotationCustomer>(
//                 controller: _billToController,
//                 suggestionsCallback: (pattern) async {
//                   return await _service.searchCustomers(pattern);
//                 },
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
//                     // Load lead numbers for the selected Bill To if applicable.
//                     if (_isInquiryReference) {
//                       _loadLeadNumbers();
//                     }
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Salesman Dropdown
//               FutureBuilder<List<Salesman>>(
//                 future: _service.fetchSalesmen(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const CircularProgressIndicator();
//                   }
//                   final salesmen = snapshot.data!;
//                   return DropdownButtonFormField<Salesman>(
//                     decoration: const InputDecoration(labelText: 'Salesman'),
//                     value: _selectedSalesman,
//                     items:
//                         salesmen
//                             .map(
//                               (e) => DropdownMenuItem(
//                                 value: e,
//                                 child: Text(e.salesManFullName),
//                               ),
//                             )
//                             .toList(),
//                     onChanged:
//                         (v) => setState(() {
//                           _selectedSalesman = v;
//                         }),
//                     validator: (v) => v == null ? 'Select Salesman' : null,
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Lead Number Dropdown (only if the quotation base requires inquiry)
//               if (_isInquiryReference)
//                 DropdownButtonFormField<String>(
//                   decoration: const InputDecoration(labelText: 'Lead Number'),
//                   value: _selectedLeadNumber,
//                   items:
//                       _leadNumbers
//                           .map(
//                             (e) => DropdownMenuItem(value: e, child: Text(e)),
//                           )
//                           .toList(),
//                   onChanged: (v) {
//                     setState(() {
//                       _selectedLeadNumber = v;
//                     });
//                   },
//                   validator:
//                       (val) =>
//                           val == null || val.isEmpty
//                               ? 'Select Lead Number'
//                               : null,
//                 ),
//               if (_isInquiryReference) const SizedBox(height: 16),

//               // Subject To Field
//               TextFormField(
//                 controller: _subjectToController,
//                 decoration: const InputDecoration(labelText: 'Subject To'),
//                 validator:
//                     (val) =>
//                         (val == null || val.isEmpty) ? 'Enter Subject' : null,
//               ),
//               const SizedBox(height: 16),

//               // Date Picker using API-specified limits.
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
//               // Total Summary Card
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
// import 'package:nhapp/pages/Quotation2/models/add_quotation.dart';
// import 'package:nhapp/pages/Quotation2/pages/add_quotation_item_page.dart';
// import 'package:nhapp/pages/Quotation2/services/quotation_service.dart';
// import 'package:nhapp/pages/Quotation2/widgets/confirmation_dialog.dart';
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

//   Salesman? _selectedSalesman;
//   List<Salesman> _salesmen = [];
//   final TextEditingController _subjectController = TextEditingController();

//   String? _selectedLeadNumber;
//   List<String> _leadNumbers = [];

//   DateTime _date = DateTime.now();
//   DateTime? _minDate;
//   DateTime? _maxDate;
//   String? _year;
//   int? _siteId;
//   int? _userId;

//   final List<Map<String, dynamic>> _items = [];
//   final List<PlatformFile> _attachments = [];

//   bool _loading = true;
//   bool _submitting = false;
//   String? _errorMessage;

//   bool get _isInquiryReference =>
//       _selectedQuotationBase != null &&
//       _selectedQuotationBase!.name.toLowerCase().contains('inquiry');

//   @override
//   void initState() {
//     super.initState();
//     _service = QuotationFormService();
//     _loadInitialData();
//   }

//   Future<void> _loadInitialData() async {
//     setState(() {
//       _loading = true;
//       _errorMessage = null;
//     });

//     try {
//       // Show loading message
//       _showLoadingSnackBar("Loading initial data...");

//       // 1. Fetch date range
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
//       _siteId = dateRange["siteId"] ?? 0;

//       // 2. Fetch document details
//       final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
//       await StorageUtils.writeJson("docDetail", docDetail);

//       // 3. Load dropdown data
//       final futures = await Future.wait([
//         _service.fetchQuotationBases(),
//         _service.fetchSalesmen(),
//       ]);

//       final bases = futures[0] as List<QuotationBase>;
//       final salesmen = futures[1] as List<Salesman>;

//       setState(() {
//         _quotationBases = bases;
//         _salesmen = salesmen;
//         _date = DateTime.now();
//         if (_date.isBefore(_minDate!)) _date = _minDate!;
//         if (_date.isAfter(_maxDate!)) _date = _maxDate!;
//         _loading = false;
//       });

//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       _showSuccessSnackBar("Data loaded successfully");
//     } catch (e) {
//       setState(() {
//         _loading = false;
//         _errorMessage = e.toString();
//       });
//       _showErrorSnackBar("Error loading data: ${e.toString()}");
//     }
//   }

//   void _showLoadingSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//             const SizedBox(width: 16),
//             Text(message),
//           ],
//         ),
//         duration: const Duration(seconds: 30),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.white),
//             const SizedBox(width: 8),
//             Text(message),
//           ],
//         ),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error, color: Colors.white),
//             const SizedBox(width: 8),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 5),
//         action: SnackBarAction(
//           label: 'Dismiss',
//           textColor: Colors.white,
//           onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
//         ),
//       ),
//     );
//   }

//   Future<void> _loadLeadNumbers() async {
//     if (_selectedBillTo == null) return;

//     try {
//       _showLoadingSnackBar("Loading lead numbers...");
//       final leads = await _service.fetchLeadNumbers(
//         customerCode: _selectedBillTo!.customerCode,
//       );
//       setState(() {
//         _leadNumbers = leads;
//       });
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     } catch (e) {
//       _showErrorSnackBar('Error fetching lead numbers: $e');
//     }
//   }

//   Future<void> _pickFiles() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(
//         allowMultiple: true,
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
//       );

//       if (result != null) {
//         setState(() {
//           _attachments.addAll(result.files);
//         });
//         _showSuccessSnackBar("${result.files.length} file(s) added");
//       }
//     } catch (e) {
//       _showErrorSnackBar("Error picking files: $e");
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
//     _showSuccessSnackBar("Item added successfully");
//   }

//   void _editItem(int index, Map<String, dynamic> item) {
//     setState(() {
//       _items[index] = item;
//     });
//     _showSuccessSnackBar("Item updated successfully");
//   }

//   void _removeItem(int index) {
//     setState(() {
//       _items.removeAt(index);
//     });
//     _showSuccessSnackBar("Item removed");
//   }

//   Future<void> _openAddItem() async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
//     );
//     if (result != null) _addItem(result);
//   }

//   Future<void> _openEditItem(int index) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
//       ),
//     );
//     if (result != null) {
//       _editItem(index, result);
//     }
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
//     if (!_formKey.currentState!.validate()) {
//       _showErrorSnackBar("Please fill all required fields");
//       return;
//     }

//     if (_items.isEmpty) {
//       _showErrorSnackBar("Please add at least one item");
//       return;
//     }

//     final confirmed = await showConfirmationDialog(
//       context,
//       "Are you sure you want to submit this quotation?",
//     );

//     if (!confirmed) return;

//     setState(() => _submitting = true);
//     _showLoadingSnackBar("Submitting quotation...");

//     try {
//       final docDetail =
//           await StorageUtils.readJson("docDetail") as Map<String, dynamic>?;

//       if (docDetail == null || docDetail.isEmpty) {
//         throw Exception(
//           'Document details not found. Please refresh and try again.',
//         );
//       }

//       final submissionData = QuotationSubmissionData(
//         docDetail: docDetail,
//         quoteTo: _selectedQuoteTo!,
//         billTo: _selectedBillTo!,
//         salesman: _selectedSalesman!,
//         subject: _subjectController.text,
//         quotationDate: _date,
//         quotationYear: _year!,
//         siteId: _siteId!,
//         userId: _userId ?? 0,
//         items: _items,
//       );

//       final submissionResponse = await _service.submitQuotation(submissionData);

//       if (submissionResponse['success'] == true) {
//         final quotationId =
//             submissionResponse['data']?['quotationId'] ??
//             submissionResponse['data']?['QuotationId'];

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
//             userId: _userId ?? 0,
//           );
//         }

//         ScaffoldMessenger.of(context).hideCurrentSnackBar();

//         if (attachSuccess) {
//           _showSuccessSnackBar('Quotation created successfully!');
//         } else {
//           _showErrorSnackBar('Quotation created, but attachment upload failed');
//         }

//         // Navigate back after a delay
//         Future.delayed(const Duration(seconds: 2), () {
//           if (mounted) Navigator.of(context).pop(true);
//         });
//       } else {
//         throw Exception(
//           submissionResponse['message'] ?? 'Failed to create quotation',
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).hideCurrentSnackBar();
//       _showErrorSnackBar('Error: ${e.toString()}');
//     } finally {
//       setState(() => _submitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Quotation'),
//         actions: [
//           if (_loading)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body:
//           _loading
//               ? const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(),
//                     SizedBox(height: 16),
//                     Text('Loading quotation form...'),
//                   ],
//                 ),
//               )
//               : _errorMessage != null
//               ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Error loading form',
//                       style: Theme.of(context).textTheme.headlineSmall,
//                     ),
//                     const SizedBox(height: 8),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 32),
//                       child: Text(
//                         _errorMessage!,
//                         textAlign: TextAlign.center,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     ElevatedButton.icon(
//                       onPressed: _loadInitialData,
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               )
//               : _buildForm(),
//     );
//   }

//   Widget _buildForm() {
//     final totals = getTotals();

//     return AbsorbPointer(
//       absorbing: _submitting,
//       child: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: [
//             // Quotation Base Dropdown
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Basic Information',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     DropdownButtonFormField<QuotationBase>(
//                       decoration: const InputDecoration(
//                         labelText: 'Quotation Base *',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedQuotationBase,
//                       items:
//                           _quotationBases
//                               .map(
//                                 (e) => DropdownMenuItem(
//                                   value: e,
//                                   child: Text(e.name),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (v) {
//                         setState(() {
//                           _selectedQuotationBase = v;
//                           if (!_isInquiryReference) {
//                             _selectedLeadNumber = null;
//                             _leadNumbers = [];
//                           }
//                         });
//                       },
//                       validator:
//                           (v) =>
//                               v == null ? 'Please select Quotation Base' : null,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Customer Information
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Customer Information',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Quote To
//                     TypeAheadField<QuotationCustomer>(
//                       controller: _quoteToController,
//                       suggestionsCallback: (pattern) async {
//                         if (pattern.length < 3) return [];
//                         try {
//                           return await _service.searchCustomers(pattern);
//                         } catch (e) {
//                           _showErrorSnackBar("Error searching customers: $e");
//                           return [];
//                         }
//                       },
//                       builder:
//                           (context, controller, focusNode) => TextFormField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: const InputDecoration(
//                               labelText: 'Quote To *',
//                               border: OutlineInputBorder(),
//                               hintText:
//                                   'Type at least 3 characters to search...',
//                             ),
//                             validator:
//                                 (val) =>
//                                     (val == null ||
//                                             val.isEmpty ||
//                                             _selectedQuoteTo == null)
//                                         ? 'Please select Quote To customer'
//                                         : null,
//                           ),
//                       itemBuilder:
//                           (context, suggestion) => ListTile(
//                             title: Text(suggestion.customerFullName),
//                             subtitle: Text(suggestion.customerCode),
//                           ),
//                       onSelected: (suggestion) {
//                         setState(() {
//                           _selectedQuoteTo = suggestion;
//                           _quoteToController.text = suggestion.customerFullName;
//                           _selectedBillTo = suggestion;
//                           _billToController.text = suggestion.customerFullName;
//                           if (_isInquiryReference) {
//                             _loadLeadNumbers();
//                           }
//                         });
//                       },
//                       emptyBuilder:
//                           (context) => const Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Text('No customers found'),
//                           ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Bill To
//                     TypeAheadField<QuotationCustomer>(
//                       controller: _billToController,
//                       suggestionsCallback: (pattern) async {
//                         if (pattern.length < 3) return [];
//                         try {
//                           return await _service.searchCustomers(pattern);
//                         } catch (e) {
//                           return [];
//                         }
//                       },
//                       builder:
//                           (context, controller, focusNode) => TextFormField(
//                             controller: controller,
//                             focusNode: focusNode,
//                             decoration: const InputDecoration(
//                               labelText: 'Bill To *',
//                               border: OutlineInputBorder(),
//                               hintText:
//                                   'Type at least 3 characters to search...',
//                             ),
//                             validator:
//                                 (val) =>
//                                     (val == null ||
//                                             val.isEmpty ||
//                                             _selectedBillTo == null)
//                                         ? 'Please select Bill To customer'
//                                         : null,
//                           ),
//                       itemBuilder:
//                           (context, suggestion) => ListTile(
//                             title: Text(suggestion.customerFullName),
//                             subtitle: Text(suggestion.customerCode),
//                           ),
//                       onSelected: (suggestion) {
//                         setState(() {
//                           _selectedBillTo = suggestion;
//                           _billToController.text = suggestion.customerFullName;
//                           if (_isInquiryReference) {
//                             _loadLeadNumbers();
//                           }
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Other Details
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Other Details',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // Salesman
//                     DropdownButtonFormField<Salesman>(
//                       decoration: const InputDecoration(
//                         labelText: 'Salesman *',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: _selectedSalesman,
//                       items:
//                           _salesmen
//                               .map(
//                                 (e) => DropdownMenuItem(
//                                   value: e,
//                                   child: Text(e.salesManFullName),
//                                 ),
//                               )
//                               .toList(),
//                       onChanged: (v) => setState(() => _selectedSalesman = v),
//                       validator:
//                           (v) => v == null ? 'Please select Salesman' : null,
//                     ),
//                     const SizedBox(height: 16),

//                     // Lead Number (conditional)
//                     if (_isInquiryReference) ...[
//                       DropdownButtonFormField<String>(
//                         decoration: const InputDecoration(
//                           labelText: 'Lead Number *',
//                           border: OutlineInputBorder(),
//                         ),
//                         value: _selectedLeadNumber,
//                         items:
//                             _leadNumbers
//                                 .map(
//                                   (e) => DropdownMenuItem(
//                                     value: e,
//                                     child: Text(e),
//                                   ),
//                                 )
//                                 .toList(),
//                         onChanged:
//                             (v) => setState(() => _selectedLeadNumber = v),
//                         validator:
//                             (val) =>
//                                 _isInquiryReference &&
//                                         (val == null || val.isEmpty)
//                                     ? 'Please select Lead Number'
//                                     : null,
//                       ),
//                       const SizedBox(height: 16),
//                     ],

//                     // Subject
//                     TextFormField(
//                       controller: _subjectController,
//                       decoration: const InputDecoration(
//                         labelText: 'Subject *',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator:
//                           (val) =>
//                               (val == null || val.isEmpty)
//                                   ? 'Please enter Subject'
//                                   : null,
//                     ),
//                     const SizedBox(height: 16),

//                     // Date
//                     InkWell(
//                       onTap: () async {
//                         final picked = await showDatePicker(
//                           context: context,
//                           initialDate: _date,
//                           firstDate: _minDate ?? DateTime(2000),
//                           lastDate: _maxDate ?? DateTime(2100),
//                         );
//                         if (picked != null) {
//                           setState(() => _date = picked);
//                         }
//                       },
//                       child: InputDecorator(
//                         decoration: const InputDecoration(
//                           labelText: 'Date *',
//                           border: OutlineInputBorder(),
//                           suffixIcon: Icon(Icons.calendar_today),
//                         ),
//                         child: Text(DateFormat('yyyy-MM-dd').format(_date)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Items Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Items (${_items.length})',
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: _openAddItem,
//                           icon: const Icon(Icons.add),
//                           label: const Text('Add Item'),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     if (_items.isEmpty)
//                       Container(
//                         padding: const EdgeInsets.all(32),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.inventory_2_outlined,
//                               size: 64,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No items added yet',
//                               style: Theme.of(context).textTheme.titleMedium
//                                   ?.copyWith(color: Colors.grey[600]),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Add items to create your quotation',
//                               style: Theme.of(context).textTheme.bodyMedium
//                                   ?.copyWith(color: Colors.grey[600]),
//                             ),
//                           ],
//                         ),
//                       )
//                     else ...[
//                       ..._items.asMap().entries.map((entry) {
//                         final idx = entry.key;
//                         final item = entry.value;
//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             title: Text(item['itemName'] ?? ''),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Code: ${item['itemCode'] ?? ''}'),
//                                 Text(
//                                   'Qty: ${item['qty']} | Rate: ₹${item['rate']} | Total: ₹${item['totalAmount']}',
//                                 ),
//                               ],
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.edit),
//                                   onPressed: () => _openEditItem(idx),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.delete),
//                                   onPressed: () => _removeItem(idx),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),

//                       // Totals
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Basic Amount:'),
//                                 Text(
//                                   '₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Discount:'),
//                                 Text(
//                                   '₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
//                                 ),
//                               ],
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 const Text('Tax Amount:'),
//                                 Text(
//                                   '₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
//                                 ),
//                               ],
//                             ),
//                             const Divider(),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Total Amount:',
//                                   style: Theme.of(context).textTheme.titleMedium
//                                       ?.copyWith(fontWeight: FontWeight.bold),
//                                 ),
//                                 Text(
//                                   '₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
//                                   style: Theme.of(
//                                     context,
//                                   ).textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Attachments
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Attachments (${_attachments.length})',
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(fontWeight: FontWeight.bold),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: _submitting ? null : _pickFiles,
//                           icon: const Icon(Icons.attach_file),
//                           label: const Text('Add Files'),
//                         ),
//                       ],
//                     ),
//                     if (_attachments.isNotEmpty) ...[
//                       const SizedBox(height: 16),
//                       ..._attachments.asMap().entries.map((entry) {
//                         final idx = entry.key;
//                         final file = entry.value;
//                         return ListTile(
//                           leading: const Icon(Icons.description),
//                           title: Text(file.name),
//                           subtitle: Text(
//                             '${(file.size / 1024).toStringAsFixed(1)} KB',
//                           ),
//                           trailing: IconButton(
//                             icon: const Icon(Icons.remove_circle),
//                             onPressed:
//                                 _submitting
//                                     ? null
//                                     : () => _removeAttachment(idx),
//                           ),
//                         );
//                       }),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Submit Button
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _submitting ? null : _submit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                 ),
//                 child:
//                     _submitting
//                         ? const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   Colors.white,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 12),
//                             Text('Submitting...'),
//                           ],
//                         )
//                         : const Text(
//                           'Submit Quotation',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:nhapp/pages/Quotation2/models/add_quotation.dart';
import 'package:nhapp/pages/Quotation2/pages/add_quotation_item_page.dart';
import 'package:nhapp/pages/Quotation2/services/quotation_service.dart';
import 'package:nhapp/pages/Quotation2/widgets/confirmation_dialog.dart';
import 'package:nhapp/utils/storage_utils.dart';

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

  Salesman? _selectedSalesman;
  List<Salesman> _salesmen = [];
  final TextEditingController _subjectController = TextEditingController();

  String? _selectedLeadNumber;
  List<String> _leadNumbers = [];

  DateTime _date = DateTime.now();
  DateTime? _minDate;
  DateTime? _maxDate;
  String? _year;
  int? _siteId;
  int? _userId;

  final List<Map<String, dynamic>> _items = [];
  final List<PlatformFile> _attachments = [];

  bool _loading = true;
  bool _submitting = false;
  String? _errorMessage;
  bool _hasInitialized = false; // Add this flag

  // Updated logic to check if Lead Number should be shown
  bool get _isInquiryReference =>
      _selectedQuotationBase != null && (_selectedQuotationBase!.code == "I");

  @override
  void initState() {
    super.initState();
    _service = QuotationFormService();
    // _loadInitialData();
    debugPrint('Error loading form: $_errorMessage');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load initial data here instead
    if (!_hasInitialized) {
      _hasInitialized = true;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Show loading message
      _showLoadingSnackBar("Loading initial data...");

      // 1. Fetch date range
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
      _siteId = dateRange["siteId"] ?? 0;

      // 2. Fetch document details
      final docDetail = await _service.fetchDefaultDocDetail(year: _year!);
      await StorageUtils.writeJson("docDetail", docDetail);

      // 3. Load dropdown data
      final futures = await Future.wait([
        _service.fetchQuotationBases(),
        _service.fetchSalesmen(),
      ]);

      final bases = futures[0] as List<QuotationBase>;
      final salesmen = futures[1] as List<Salesman>;

      setState(() {
        _quotationBases = bases;
        _salesmen = salesmen;
        _date = DateTime.now();
        if (_date.isBefore(_minDate!)) _date = _minDate!;
        if (_date.isAfter(_maxDate!)) _date = _maxDate!;
        _loading = false;
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showSuccessSnackBar("Data loaded successfully");
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
        debugPrint('Error loading form: $_errorMessage');
      });
      _showErrorSnackBar("Error loading data: ${e.toString()}");
    }
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 30),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> _loadLeadNumbers() async {
    if (_selectedBillTo == null) {
      setState(() {
        _leadNumbers = [];
        _selectedLeadNumber = null;
      });
      return;
    }

    try {
      _showLoadingSnackBar("Loading lead numbers...");
      final leads = await _service.fetchLeadNumbers(
        customerCode: _selectedBillTo!.customerCode,
      );
      setState(() {
        _leadNumbers = leads;
        _selectedLeadNumber = null; // Reset selection when new data loads
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    } catch (e) {
      setState(() {
        _leadNumbers = [];
        _selectedLeadNumber = null;
      });
      _showErrorSnackBar('Error fetching lead numbers: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _attachments.addAll(result.files);
        });
        _showSuccessSnackBar("${result.files.length} file(s) added");
      }
    } catch (e) {
      _showErrorSnackBar("Error picking files: $e");
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
    _showSuccessSnackBar("Item added successfully");
  }

  void _editItem(int index, Map<String, dynamic> item) {
    setState(() {
      _items[index] = item;
    });
    _showSuccessSnackBar("Item updated successfully");
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _showSuccessSnackBar("Item removed");
  }

  Future<void> _openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddQuotationItemPage()),
    );
    if (result != null) _addItem(result);
  }

  Future<void> _openEditItem(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuotationItemPage(initialItem: _items[index]),
      ),
    );
    if (result != null) {
      _editItem(index, result);
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar("Please fill all required fields");
      return;
    }

    if (_items.isEmpty) {
      _showErrorSnackBar("Please add at least one item");
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      "Are you sure you want to submit this quotation?",
    );

    if (!confirmed) return;

    setState(() => _submitting = true);
    _showLoadingSnackBar("Submitting quotation...");

    try {
      final docDetail =
          await StorageUtils.readJson("docDetail") as Map<String, dynamic>?;

      if (docDetail == null || docDetail.isEmpty) {
        throw Exception(
          'Document details not found. Please refresh and try again.',
        );
      }

      final submissionData = QuotationSubmissionData(
        docDetail: docDetail,
        quoteTo: _selectedQuoteTo!,
        billTo: _selectedBillTo!,
        salesman: _selectedSalesman!,
        subject: _subjectController.text,
        quotationDate: _date,
        quotationYear: _year!,
        siteId: _siteId!,
        userId: _userId ?? 0,
        items: _items,
      );

      final submissionResponse = await _service.submitQuotation(submissionData);

      if (submissionResponse['success'] == true) {
        final quotationId =
            submissionResponse['data']?['quotationId'] ??
            submissionResponse['data']?['QuotationId'];

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
            userId: _userId ?? 0,
          );
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (attachSuccess) {
          _showSuccessSnackBar('Quotation created successfully!');
        } else {
          _showErrorSnackBar('Quotation created, but attachment upload failed');
        }

        // Navigate back after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop(true);
        });
      } else {
        throw Exception(
          submissionResponse['message'] ?? 'Failed to create quotation',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Quotation'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body:
          _loading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading quotation form...'),
                  ],
                ),
              )
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading form',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadInitialData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _buildForm(),
    );
  }

  Widget _buildForm() {
    final totals = getTotals();

    return AbsorbPointer(
      absorbing: _submitting,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quotation Base Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<QuotationBase>(
                      decoration: const InputDecoration(
                        labelText: 'Quotation Base *',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedQuotationBase,
                      items:
                          _quotationBases
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.name),
                                ),
                              )
                              .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedQuotationBase = v;

                          // Clear lead number data when quotation base changes
                          _selectedLeadNumber = null;
                          _leadNumbers = [];

                          // Load lead numbers if new selection is inquiry-based and customer is selected
                          if (_isInquiryReference && _selectedBillTo != null) {
                            _loadLeadNumbers();
                          }
                        });
                      },
                      validator:
                          (v) =>
                              v == null ? 'Please select Quotation Base' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Customer Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quote To
                    TypeAheadField<QuotationCustomer>(
                      controller: _quoteToController,
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 3) return [];
                        try {
                          return await _service.searchCustomers(pattern);
                        } catch (e) {
                          _showErrorSnackBar("Error searching customers: $e");
                          return [];
                        }
                      },
                      builder:
                          (context, controller, focusNode) => TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Quote To *',
                              border: OutlineInputBorder(),
                              hintText:
                                  'Type at least 3 characters to search...',
                            ),
                            validator:
                                (val) =>
                                    (val == null ||
                                            val.isEmpty ||
                                            _selectedQuoteTo == null)
                                        ? 'Please select Quote To customer'
                                        : null,
                          ),
                      itemBuilder:
                          (context, suggestion) => ListTile(
                            title: Text(suggestion.customerFullName),
                            subtitle: Text(suggestion.customerCode),
                          ),
                      onSelected: (suggestion) {
                        setState(() {
                          _selectedQuoteTo = suggestion;
                          _quoteToController.text = suggestion.customerFullName;
                          _selectedBillTo = suggestion;
                          _billToController.text = suggestion.customerFullName;

                          // Clear and reload lead numbers if inquiry reference
                          _selectedLeadNumber = null;
                          _leadNumbers = [];
                          if (_isInquiryReference) {
                            _loadLeadNumbers();
                          }
                        });
                      },
                      emptyBuilder:
                          (context) => const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No customers found'),
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Bill To
                    TypeAheadField<QuotationCustomer>(
                      controller: _billToController,
                      suggestionsCallback: (pattern) async {
                        if (pattern.length < 3) return [];
                        try {
                          return await _service.searchCustomers(pattern);
                        } catch (e) {
                          return [];
                        }
                      },
                      builder:
                          (context, controller, focusNode) => TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Bill To *',
                              border: OutlineInputBorder(),
                              hintText:
                                  'Type at least 3 characters to search...',
                            ),
                            validator:
                                (val) =>
                                    (val == null ||
                                            val.isEmpty ||
                                            _selectedBillTo == null)
                                        ? 'Please select Bill To customer'
                                        : null,
                          ),
                      itemBuilder:
                          (context, suggestion) => ListTile(
                            title: Text(suggestion.customerFullName),
                            subtitle: Text(suggestion.customerCode),
                          ),
                      onSelected: (suggestion) {
                        setState(() {
                          _selectedBillTo = suggestion;
                          _billToController.text = suggestion.customerFullName;

                          // Clear and reload lead numbers if inquiry reference
                          _selectedLeadNumber = null;
                          _leadNumbers = [];
                          if (_isInquiryReference) {
                            _loadLeadNumbers();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Other Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Salesman
                    DropdownButtonFormField<Salesman>(
                      decoration: const InputDecoration(
                        labelText: 'Salesman *',
                        border: OutlineInputBorder(),
                      ),
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
                      onChanged: (v) => setState(() => _selectedSalesman = v),
                      validator:
                          (v) => v == null ? 'Please select Salesman' : null,
                    ),
                    const SizedBox(height: 16),

                    // Lead Number (ONLY show if inquiry reference)
                    if (_isInquiryReference) ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Lead Number *',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedLeadNumber,
                        items:
                            _leadNumbers
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (v) => setState(() => _selectedLeadNumber = v),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Please select Lead Number'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Subject
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject *',
                        border: OutlineInputBorder(),
                      ),
                      validator:
                          (val) =>
                              (val == null || val.isEmpty)
                                  ? 'Please enter Subject'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    // Date
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: _minDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _date = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(DateFormat('yyyy-MM-dd').format(_date)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items (${_items.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _openAddItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items added yet',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add items to create your quotation',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      ..._items.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item['itemName'] ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Code: ${item['itemCode'] ?? ''}'),
                                Text(
                                  'Qty: ${item['qty']} | Rate: ₹${item['rate']} | Total: ₹${item['totalAmount']}',
                                ),
                              ],
                            ),
                            trailing: Row(
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
                        );
                      }),

                      // Totals
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Basic Amount:'),
                                Text(
                                  '₹${totals['basic']?.toStringAsFixed(2) ?? '0.00'}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount:'),
                                Text(
                                  '₹${totals['discount']?.toStringAsFixed(2) ?? '0.00'}',
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Tax Amount:'),
                                Text(
                                  '₹${totals['tax']?.toStringAsFixed(2) ?? '0.00'}',
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '₹${totals['total']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attachments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Attachments (${_attachments.length})',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _submitting ? null : _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Add Files'),
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ..._attachments.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final file = entry.value;
                        return ListTile(
                          leading: const Icon(Icons.description),
                          title: Text(file.name),
                          subtitle: Text(
                            '${(file.size / 1024).toStringAsFixed(1)} KB',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            onPressed:
                                _submitting
                                    ? null
                                    : () => _removeAttachment(idx),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child:
                    _submitting
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Submitting...'),
                          ],
                        )
                        : const Text(
                          'Submit Quotation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
