// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:nhapp/pages/sales_order/models/add_sales_order.dart';
// import 'package:nhapp/pages/sales_order/pages/add_item.dart';
// import 'package:nhapp/pages/sales_order/service/add_service.dart';
// import 'package:nhapp/utils/format_utils.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import 'package:file_picker/file_picker.dart';

// class EditSalesOrderPage extends StatefulWidget {
//   final String ioYear;
//   final String ioGroup;
//   final String ioSiteCode;
//   final String ioNumber;
//   final int locationId;

//   const EditSalesOrderPage({
//     super.key,
//     required this.ioYear,
//     required this.ioGroup,
//     required this.ioSiteCode,
//     required this.ioNumber,
//     required this.locationId,
//   });

//   @override
//   State<EditSalesOrderPage> createState() => _EditSalesOrderPageState();
// }

// class _EditSalesOrderPageState extends State<EditSalesOrderPage> {
//   late SalesOrderService _service;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController orderFromController = TextEditingController();
//   final TextEditingController billToController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController customerPONumberController =
//       TextEditingController();
//   final TextEditingController customerPODateController =
//       TextEditingController();
//   final TextEditingController quotationNumberController =
//       TextEditingController();

//   String salesOrderReference = "Without Quotation Reference";
//   Customer? selectedOrderFrom;
//   Customer? selectedBillTo;
//   DateTime? selectedDate;
//   DateTime? selectedCustomerPODate;
//   List<RateStructure> rateStructures = [];
//   List<SalesOrderItem> items = [];
//   List<PlatformFile> attachments = [];
//   DocumentDetail? documentDetail;
//   bool _isLoading = true;
//   bool _submitting = false;
//   DateTime? startDate;
//   DateTime? endDate;
//   late Map<String, dynamic>? _financeDetails;

//   // Quotation related fields
//   List<QuotationNumber> quotationNumbers = [];
//   QuotationNumber? selectedQuotationNumber;
//   bool _loadingQuotationDetails = false;

//   // Sales Order details
//   Map<String, dynamic>? salesOrderDetails;
//   String originalOrderId = "";

//   @override
//   void initState() {
//     super.initState();
//     _initializeForm();
//   }

//   Future<void> _initializeForm() async {
//     _service = await SalesOrderService.create();
//     await _loadFinancePeriod();
//     await _loadRateStructures();
//     await _loadSalesOrderDetails();
//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadFinancePeriod() async {
//     _financeDetails = await StorageUtils.readJson('finance_period');
//     if (_financeDetails != null) {
//       startDate = DateTime.parse(_financeDetails!['periodSDt']);
//       endDate = DateTime.parse(_financeDetails!['periodEDt']);
//     }
//   }

//   Future<void> _loadRateStructures() async {
//     rateStructures = await _service.fetchRateStructures();
//   }

//   Future<void> _loadSalesOrderDetails() async {
//     try {
//       final companyId = _service.companyDetails['id'];
//       final response = await _service.fetchSalesOrderDetails(
//         widget.ioYear,
//         widget.ioGroup,
//         widget.ioSiteCode,
//         widget.ioNumber,
//         widget.locationId,
//         companyId,
//       );

//       if (response['success'] == true && response['data'] != null) {
//         salesOrderDetails = response['data'];
//         _populateFormFromResponse(salesOrderDetails!);
//       }
//     } catch (e) {
//       _showError("Error loading sales order details: ${e.toString()}");
//     }
//   }

//   void _populateFormFromResponse(Map<String, dynamic> data) {
//     final soDetails = data['salesOrderDetails'][0];
//     final modelDetails = data['modelDetails'] as List;
//     final rateStructureDetails = data['rateStructureDetails'] as List;
//     final discountDetails = data['discountDetails'] as List;

//     // Set basic sales order details
//     originalOrderId = soDetails['orderId'].toString();

//     // Set customer details
//     selectedOrderFrom = Customer(
//       customerCode: soDetails['customerCode'] ?? '',
//       customerName: soDetails['customerName'] ?? '',
//       gstNumber: soDetails['gstNo'] ?? '',
//       telephoneNo: '',
//       customerFullName: soDetails['customerFullName'] ?? '',
//     );
//     orderFromController.text = selectedOrderFrom!.customerName;

//     selectedBillTo = Customer(
//       customerCode: soDetails['billToCode'] ?? '',
//       customerName: soDetails['billToName'] ?? '',
//       gstNumber: soDetails['gstNo'] ?? '',
//       telephoneNo: '',
//       customerFullName:
//           "${soDetails['billToCode']} - ${soDetails['billToName']}",
//     );
//     billToController.text = selectedBillTo!.customerName;

//     // Set dates
//     selectedDate = DateTime.parse(soDetails['ioDate']);
//     dateController.text = FormatUtils.formatDateForUser(selectedDate!);

//     selectedCustomerPODate = DateTime.parse(soDetails['customerPODate']);
//     customerPODateController.text = FormatUtils.formatDateForUser(
//       selectedCustomerPODate!,
//     );

//     // Set customer PO number
//     customerPONumberController.text = soDetails['customerPONumber'] ?? '';

//     // Set quotation reference
//     if (soDetails['quotationNumber'] != null &&
//         soDetails['quotationNumber'].toString().isNotEmpty &&
//         soDetails['quotationNumber'] != '0') {
//       salesOrderReference = "With Quotation Reference";
//       quotationNumberController.text = soDetails['quotationNumber'];

//       selectedQuotationNumber = QuotationNumber(
//         quotationID: soDetails['quotationId'] ?? 0,
//         quotationNumber: soDetails['quotationNumber'] ?? '',
//         quotationYear: soDetails['quotationYear'] ?? '',
//         quotationGroup: soDetails['quotationGroup'] ?? '',
//         quotationDate:
//             soDetails['quotationDate'] != null &&
//                     soDetails['quotationDate'] != '0001-01-01T00:00:00'
//                 ? DateTime.parse(soDetails['quotationDate'])
//                 : DateTime.now(),
//       );
//     }

//     // Populate items
//     items.clear();
//     for (int i = 0; i < modelDetails.length; i++) {
//       final model = modelDetails[i];

//       // Find discount details for this item
//       String discountType = "None";
//       double? discountPercentage;
//       double? discountAmount;

//       final discount = discountDetails.firstWhere(
//         (d) => d['itemCode'] == model['salesItemCode'],
//         orElse: () => {},
//       );

//       if (discount.isNotEmpty) {
//         final discType = discount['discountType'] ?? 'None';
//         if (discType != 'None' && discType != 'N') {
//           if (discType == 'Percentage' || discType == 'P') {
//             discountType = 'Percentage';
//             discountPercentage = (discount['discountValue'] ?? 0).toDouble();
//             discountAmount =
//                 (model['basicPriceSUOM'] * model['qtySUOM']) *
//                 (discountPercentage! / 100);
//           } else {
//             discountType = 'Value';
//             discountAmount = (discount['discountValue'] ?? 0).toDouble();
//             final basicAmount =
//                 (model['basicPriceSUOM'] ?? 0).toDouble() *
//                 (model['qtySUOM'] ?? 0).toDouble();
//             discountPercentage =
//                 basicAmount > 0 ? (discountAmount! / basicAmount) * 100 : 0;
//           }
//         }
//       }

//       // Calculate tax amount for this item
//       double taxAmount = 0.0;
//       final itemRateStructures = rateStructureDetails.where(
//         (rs) => rs['customerItemCode'] == model['salesItemCode'],
//       );
//       for (final rs in itemRateStructures) {
//         taxAmount += (rs['rateAmount'] ?? 0).toDouble();
//       }

//       // Get rate structure rows for this item
//       List<Map<String, dynamic>> rateStructureRows =
//           itemRateStructures.toList() as List<Map<String, dynamic>>;

//       final basicRate = (model['basicPriceSUOM'] ?? 0).toDouble();
//       final qty = (model['qtySUOM'] ?? 0).toDouble();
//       final basicAmount = basicRate * qty;
//       final discountedAmount = basicAmount - (discountAmount ?? 0);
//       final totalAmount = discountedAmount + taxAmount;

//       items.add(
//         SalesOrderItem(
//           itemName: model['salesItemDesc'] ?? '',
//           itemCode: model['salesItemCode'] ?? '',
//           qty: qty,
//           basicRate: basicRate,
//           uom: model['uom'] ?? 'NOS',
//           discountType: discountType,
//           discountPercentage: discountPercentage,
//           discountAmount: discountAmount,
//           rateStructure: model['rateStructureCode'] ?? '',
//           taxAmount: taxAmount,
//           totalAmount: totalAmount,
//           rateStructureRows: rateStructureRows,
//           lineNo: model['itemLineNo'] ?? (i + 1),
//           hsnCode: model['hsnCode'] ?? '',
//         ),
//       );
//     }

//     setState(() {});
//   }

//   Future<void> _onOrderFromSelected(Customer customer) async {
//     setState(() {
//       selectedOrderFrom = customer;
//       orderFromController.text = customer.customerName;
//       billToController.text = customer.customerName;
//       selectedBillTo = customer;
//     });

//     // Load quotation numbers if quotation reference is selected
//     if (salesOrderReference == "With Quotation Reference") {
//       await _loadQuotationNumbers(customer.customerCode);
//     }
//   }

//   Future<void> _onBillToSelected(Customer customer) async {
//     setState(() {
//       selectedBillTo = customer;
//       billToController.text = customer.customerName;
//     });
//   }

//   Future<void> _loadQuotationNumbers(String customerCode) async {
//     try {
//       quotationNumbers = await _service.fetchQuotationNumberList(customerCode);
//       setState(() {});
//     } catch (e) {
//       _showError("Error loading quotation numbers: ${e.toString()}");
//     }
//   }

//   Future<void> _onQuotationNumberSelected(
//     QuotationNumber quotationNumber,
//   ) async {
//     setState(() {
//       selectedQuotationNumber = quotationNumber;
//       quotationNumberController.text = quotationNumber.quotationNumber;
//       _loadingQuotationDetails = true;
//       items.clear();
//     });

//     try {
//       final quotationDetails = await _service.fetchQuotationDetails(
//         quotationNumber.quotationNumber,
//       );

//       // Convert quotation items to sales order items
//       int lineNo = 1;
//       for (final detail in quotationDetails.itemDetail) {
//         // Calculate discount details
//         String discountType = "None";
//         double? discountPercentage;
//         double? discountAmount;

//         if (quotationDetails.discountDetail != null &&
//             quotationDetails.discountDetail!.isNotEmpty) {
//           final discountDetail = quotationDetails.discountDetail!.firstWhere(
//             (d) => d['salesItemCode'] == detail['salesItemCode'],
//             orElse: () => {},
//           );

//           if (discountDetail.isNotEmpty &&
//               (discountDetail['discountValue'] ?? 0) > 0) {
//             final discValue = (discountDetail['discountValue'] ?? 0).toDouble();
//             final discType = discountDetail['discountType'] ?? '';

//             if (discType == 'Percentage') {
//               discountType = 'Percentage';
//               discountPercentage = discValue;
//               discountAmount =
//                   ((detail['basicPriceSUOM'] ?? 0).toDouble() *
//                       (detail['qtySUOM'] ?? 0).toDouble()) *
//                   (discValue / 100);
//             } else {
//               discountType = 'Value';
//               discountAmount = discValue;
//               final basicAmount =
//                   (detail['basicPriceSUOM'] ?? 0).toDouble() *
//                   (detail['qtySUOM'] ?? 0).toDouble();
//               discountPercentage =
//                   basicAmount > 0 ? (discValue / basicAmount) * 100 : 0;
//             }
//           }
//         }

//         // Calculate tax amount
//         double taxAmount = 0.0;
//         if (quotationDetails.rateStructDetail != null) {
//           final rateStructDetails = quotationDetails.rateStructDetail!.where(
//             (rs) => rs['customerItemCode'] == detail['salesItemCode'],
//           );
//           for (final rsDetail in rateStructDetails) {
//             taxAmount += (rsDetail['rateAmount'] ?? 0).toDouble();
//           }
//         }

//         // Calculate total amount
//         final basicRate = (detail['basicPriceSUOM'] ?? 0).toDouble();
//         final qty = (detail['qtySUOM'] ?? 0).toDouble();
//         final basicAmount = basicRate * qty;
//         final discountedAmount = basicAmount - (discountAmount ?? 0);
//         final totalAmount = discountedAmount + taxAmount;

//         // Get rate structure rows for this item
//         List<Map<String, dynamic>> rateStructureRows = [];
//         if (quotationDetails.rateStructDetail != null) {
//           rateStructureRows =
//               quotationDetails.rateStructDetail!
//                   .where(
//                     (rs) => rs['customerItemCode'] == detail['salesItemCode'],
//                   )
//                   .toList();
//         }

//         items.add(
//           SalesOrderItem(
//             itemName: detail['salesItemDesc'] ?? '',
//             itemCode: detail['salesItemCode'] ?? '',
//             qty: qty,
//             basicRate: basicRate,
//             uom: detail['uom'] ?? 'NOS',
//             discountType: discountType,
//             discountPercentage: discountPercentage,
//             discountAmount: discountAmount,
//             rateStructure: detail['rateStructureCode'] ?? '',
//             taxAmount: taxAmount,
//             totalAmount: totalAmount,
//             rateStructureRows: rateStructureRows,
//             lineNo: lineNo,
//             hsnCode: detail['hsnCode'] ?? '',
//           ),
//         );
//         lineNo++;
//       }

//       setState(() {});
//     } catch (e) {
//       _showError("Error loading quotation details: ${e.toString()}");
//     } finally {
//       setState(() => _loadingQuotationDetails = false);
//     }
//   }

//   Future<void> _showAddItemPage() async {
//     final result = await Navigator.push<SalesOrderItem>(
//       context,
//       MaterialPageRoute(
//         builder:
//             (context) => AddSalesOrderItemPage(
//               service: _service,
//               rateStructures: rateStructures,
//             ),
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
//       // Re-assign line numbers
//       for (int i = 0; i < items.length; i++) {
//         items[i].lineNo = i + 1;
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

//   Future<void> _pickFiles() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: true);
//     if (result != null) {
//       setState(() {
//         attachments.addAll(result.files);
//       });
//     }
//   }

//   void _removeAttachment(int index) {
//     setState(() {
//       attachments.removeAt(index);
//     });
//   }

//   Future<void> _selectDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate:
//           startDate ?? DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: endDate ?? DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//         dateController.text = FormatUtils.formatDateForUser(picked);
//       });
//     }
//   }

//   Future<void> _selectCustomerPODate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: selectedCustomerPODate ?? DateTime.now(),
//       firstDate:
//           startDate ?? DateTime.now().subtract(const Duration(days: 365)),
//       lastDate: endDate ?? DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedCustomerPODate = picked;
//         customerPODateController.text = FormatUtils.formatDateForUser(picked);
//       });
//     }
//   }

//   Map<String, dynamic> _buildUpdatePayload() {
//     final userId = _service.tokenDetails['user']['id'] ?? 0;
//     final locationId = _service.locationDetails['id'] ?? 0;
//     final locationCode = _service.locationDetails['code'] ?? "";
//     final companyCode = _service.companyDetails['code'] ?? "";
//     final companyId = _service.companyId;
//     final docYear = _financeDetails?['financialYear'] ?? "";

//     // Build model details
//     List<Map<String, dynamic>> modelDetails = [];
//     List<Map<String, dynamic>> discountDetails = [];
//     List<Map<String, dynamic>> rateStructureDetails = [];

//     for (int i = 0; i < items.length; i++) {
//       final item = items[i];
//       item.lineNo = i + 1;

//       final modelDetail = item.toModelDetail();
//       modelDetail['custPONumber'] = customerPONumberController.text;
//       modelDetail['orderId'] = int.parse(originalOrderId);

//       // Add quotation reference if applicable
//       if (salesOrderReference == "With Quotation Reference" &&
//           selectedQuotationNumber != null) {
//         modelDetail['quotationId'] = selectedQuotationNumber!.quotationId;
//         modelDetail['quotationLineNo'] = item.lineNo;
//         modelDetail['quotationAmendNo'] = 0;
//       }
//       modelDetails.add(modelDetail);

//       final discountDetail = item.toDiscountDetail();
//       if (discountDetail.isNotEmpty) {
//         discountDetail['orderId'] = int.parse(originalOrderId);
//         discountDetails.add(discountDetail);
//       }

//       rateStructureDetails.addAll(item.toRateStructureDetails());
//     }

//     final totalBasic = _calculateTotalBasic();
//     final totalDiscount = _calculateTotalDiscount();
//     final totalTax = _calculateTotalTax();
//     final totalAfterDiscount = totalBasic - totalDiscount;
//     final finalAmount = totalAfterDiscount + totalTax;

//     return {
//       "authorizationRequired": "Y",
//       "autoNumberRequired": "N", // N for update
//       "siteRequired": "Y",
//       "authorizationDate": FormatUtils.formatDateForApi(
//         selectedDate ?? DateTime.now(),
//       ),
//       "fromLocationId": locationId,
//       "userId": userId,
//       "companyId": companyId,
//       "companyCode": companyCode,
//       "fromLocationCode": locationCode,
//       "fromLocationName": _service.locationDetails['name'] ?? "",
//       "ip": "",
//       "mac": "",
//       "docType": "OB",
//       "docSubType": "OB",
//       "domesticCurrencyCode": "INR",
//       "salesOrderDetails": {
//         "orderId": int.parse(originalOrderId),
//         "customerPONumber": customerPONumberController.text,
//         "customerPODate": FormatUtils.formatDateForApi(selectedCustomerPODate!),
//         "quotationId":
//             salesOrderReference == "With Quotation Reference" &&
//                     selectedQuotationNumber != null
//                 ? selectedQuotationNumber!.quotationId
//                 : 0,
//         "quotationYear":
//             salesOrderReference == "With Quotation Reference" &&
//                     selectedQuotationNumber != null
//                 ? selectedQuotationNumber!.quotationYear
//                 : "",
//         "quotationGroup":
//             salesOrderReference == "With Quotation Reference" &&
//                     selectedQuotationNumber != null
//                 ? selectedQuotationNumber!.quotationGroup
//                 : "",
//         "quotationNumber":
//             salesOrderReference == "With Quotation Reference" &&
//                     selectedQuotationNumber != null
//                 ? selectedQuotationNumber!.quotationNumber
//                 : "",
//         "quotationDate":
//             salesOrderReference == "With Quotation Reference" &&
//                     selectedQuotationNumber != null
//                 ? FormatUtils.formatDateForApi(
//                   selectedQuotationNumber!.quotationDate,
//                 )
//                 : null,
//         "customerCode": selectedOrderFrom?.customerCode ?? "",
//         "customerName": selectedOrderFrom?.customerName ?? "",
//         "salesManCode": "",
//         "attachFlag": "",
//         "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
//             .toStringAsFixed(2),
//         "totalAmountAfterDiscountDomesticCurrency": totalAfterDiscount
//             .toStringAsFixed(2),
//         "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
//         "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
//         "discountType": "V",
//         "discountAmount": "0.00",
//         "exchangeRate": "1.0000",
//         "orderStatus": "O",
//         "ioYear": widget.ioYear,
//         "ioGroup": widget.ioGroup,
//         "ioSiteId": locationId.toString(),
//         "ioSiteCode": widget.ioSiteCode,
//         "ioNumber": widget.ioNumber,
//         "ioDate": FormatUtils.formatDateForApi(selectedDate!),
//         "billToCode": selectedBillTo?.customerCode ?? "",
//         "currencyCode": "INR",
//         "salesOrderType": "REG",
//         "custType": "CU",
//         "lcDetail": "F",
//         "bgDetail": "F",
//         "isAgentAssociated": false,
//         "custContactPersonId": "",
//         "salesOrderRefNo": "",
//         "buyerCode": 0,
//         "soDeliveryDate": null,
//         "bookCode": "",
//         "agentCode": "",
//         "modOfDispatchCode": "",
//         "isFreeSupply": false,
//         "isReturnable": false,
//         "isRoadPermitReceived": false,
//         "customerLOINumber": "",
//         "customerLOIDate": "",
//         "isInterBranchTransfer": false,
//         "customerPOId": 0,
//         "consultantCode": "",
//         "billToCreditLimit": 0,
//         "billToAccBalance": 0,
//         "config": "N",
//         "projectName": "",
//       },
//       "modelDetails": modelDetails,
//       "discountDetails": discountDetails,
//       "rateStructureDetails": rateStructureDetails,
//       "deliveryDetails": [],
//       "paymentDetails": [],
//       "termDetails": [],
//       "specificationDetails": [],
//       "optionalItemDetails": [],
//       "textDetails": [],
//       "standardTerms": [],
//       "historyDetails": [],
//       "addOnDetails": [],
//       "subItemDetails": [],
//       "noteDetails": [],
//       "projectLotDetails": [],
//       "equipmentAttributeDetails": [],
//       "technicalspec": [],
//       "msctechspecifications": true,
//     };
//   }

//   Future<void> _updateSalesOrder() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (selectedOrderFrom == null) {
//       _showError("Please select Order From customer");
//       return;
//     }
//     if (selectedBillTo == null) {
//       _showError("Please select Bill To customer");
//       return;
//     }
//     if (customerPONumberController.text.isEmpty) {
//       _showError("Please enter Customer PO Number");
//       return;
//     }
//     if (selectedCustomerPODate == null) {
//       _showError("Please select Customer PO Date");
//       return;
//     }
//     if (items.isEmpty) {
//       _showError("Please add at least one item");
//       return;
//     }

//     setState(() => _submitting = true);

//     try {
//       final payload = _buildUpdatePayload();
//       final response = await _service.updateSalesOrder(payload);

//       if (response['success'] == true) {
//         _showSuccess(response['message'] ?? "Sales Order updated successfully");
//         Navigator.pop(context, true);
//       } else {
//         _showError(response['errorMessage'] ?? "Failed to update sales order");
//       }
//     } catch (e) {
//       _showError("Error during update: ${e.toString()}");
//     } finally {
//       setState(() => _submitting = false);
//     }
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
//   void dispose() {
//     orderFromController.dispose();
//     billToController.dispose();
//     dateController.dispose();
//     customerPONumberController.dispose();
//     customerPODateController.dispose();
//     quotationNumberController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Edit Sales Order - ${widget.ioNumber}"),
//         elevation: 1,
//       ),
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
//                       _buildSalesOrderReferenceDropdown(),
//                       const SizedBox(height: 16),
//                       _buildOrderFromField(),
//                       const SizedBox(height: 16),
//                       _buildBillToField(),
//                       const SizedBox(height: 16),
//                       if (salesOrderReference ==
//                           "With Quotation Reference") ...[
//                         _buildQuotationNumberField(),
//                         const SizedBox(height: 16),
//                       ],
//                       _buildDateField(),
//                       const SizedBox(height: 16),
//                       _buildCustomerPONumberField(),
//                       const SizedBox(height: 16),
//                       _buildCustomerPODateField(),
//                       const SizedBox(height: 16),
//                       if (_loadingQuotationDetails)
//                         const Center(
//                           child: Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: CircularProgressIndicator(),
//                           ),
//                         ),
//                       if (items.isNotEmpty) ...[
//                         _buildItemsList(),
//                         const SizedBox(height: 16),
//                       ],
//                       if (salesOrderReference == "Without Quotation Reference")
//                         _buildAddItemButton(),
//                       if (items.isNotEmpty) ...[
//                         const SizedBox(height: 16),
//                         _buildTotalCard(),
//                       ],
//                       const SizedBox(height: 24),
//                       _buildAttachmentSection(),
//                       const SizedBox(height: 24),
//                       _buildUpdateButton(),
//                     ],
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildSalesOrderReferenceDropdown() {
//     return DropdownButtonFormField<String>(
//       decoration: const InputDecoration(
//         labelText: "Sales Order Reference",
//         border: OutlineInputBorder(),
//       ),
//       value: salesOrderReference,
//       items:
//           ["Without Quotation Reference", "With Quotation Reference"]
//               .map(
//                 (option) => DropdownMenuItem<String>(
//                   value: option,
//                   child: Text(option),
//                 ),
//               )
//               .toList(),
//       onChanged:
//           _submitting
//               ? null
//               : (val) {
//                 if (val != null) {
//                   setState(() {
//                     salesOrderReference = val;
//                     // Clear quotation data when switching
//                     if (val == "Without Quotation Reference") {
//                       quotationNumbers.clear();
//                       selectedQuotationNumber = null;
//                       quotationNumberController.clear();
//                     } else if (selectedOrderFrom != null) {
//                       _loadQuotationNumbers(selectedOrderFrom!.customerCode);
//                     }
//                   });
//                 }
//               },
//       validator:
//           (val) => val == null ? "Sales Order Reference is required" : null,
//     );
//   }

//   Widget _buildOrderFromField() {
//     return TypeAheadField<Customer>(
//       debounceDuration: const Duration(milliseconds: 400),
//       controller: orderFromController,
//       builder: (context, controller, focusNode) {
//         return TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           enabled: !_submitting,
//           decoration: const InputDecoration(
//             labelText: "Order From",
//             border: OutlineInputBorder(),
//           ),
//           validator:
//               (val) =>
//                   val == null || val.isEmpty ? "Order From is required" : null,
//         );
//       },
//       suggestionsCallback:
//           _submitting
//               ? (pattern) async => []
//               : (pattern) async {
//                 if (pattern.length < 4) return [];
//                 try {
//                   return await _service.fetchCustomerSuggestions(pattern);
//                 } catch (e) {
//                   return [];
//                 }
//               },
//       itemBuilder: (context, suggestion) {
//         return ListTile(
//           title: Text(suggestion.customerName),
//           subtitle: Text(suggestion.customerCode),
//         );
//       },
//       onSelected: _submitting ? null : _onOrderFromSelected,
//     );
//   }

//   Widget _buildBillToField() {
//     return TypeAheadField<Customer>(
//       debounceDuration: const Duration(milliseconds: 400),
//       controller: billToController,
//       builder: (context, controller, focusNode) {
//         return TextFormField(
//           controller: controller,
//           focusNode: focusNode,
//           enabled: !_submitting,
//           decoration: const InputDecoration(
//             labelText: "Bill To",
//             border: OutlineInputBorder(),
//           ),
//           validator:
//               (val) =>
//                   val == null || val.isEmpty ? "Bill To is required" : null,
//         );
//       },
//       suggestionsCallback:
//           _submitting
//               ? (pattern) async => []
//               : (pattern) async {
//                 if (pattern.length < 4) return [];
//                 try {
//                   return await _service.fetchCustomerSuggestions(pattern);
//                 } catch (e) {
//                   return [];
//                 }
//               },
//       itemBuilder: (context, suggestion) {
//         return ListTile(
//           title: Text(suggestion.customerName),
//           subtitle: Text(suggestion.customerCode),
//         );
//       },
//       onSelected: _submitting ? null : _onBillToSelected,
//     );
//   }

//   Widget _buildQuotationNumberField() {
//     return DropdownButtonFormField<QuotationNumber>(
//       decoration: const InputDecoration(
//         labelText: "Quotation Number",
//         border: OutlineInputBorder(),
//       ),
//       value: selectedQuotationNumber,
//       isExpanded: true,
//       items:
//           quotationNumbers.map((quotation) {
//             return DropdownMenuItem<QuotationNumber>(
//               value: quotation,
//               child: Text(
//                 "${quotation.quotationNumber} - ${FormatUtils.formatDateForUser(quotation.quotationDate)}",
//                 overflow: TextOverflow.ellipsis,
//               ),
//             );
//           }).toList(),
//       onChanged:
//           _submitting || _loadingQuotationDetails
//               ? null
//               : (val) {
//                 if (val != null) {
//                   _onQuotationNumberSelected(val);
//                 }
//               },
//       validator:
//           salesOrderReference == "With Quotation Reference"
//               ? (val) => val == null ? "Quotation Number is required" : null
//               : null,
//     );
//   }

//   Widget _buildDateField() {
//     return TextFormField(
//       controller: dateController,
//       readOnly: true,
//       enabled: !_submitting,
//       decoration: const InputDecoration(
//         labelText: "Date",
//         border: OutlineInputBorder(),
//         suffixIcon: Icon(Icons.calendar_today),
//       ),
//       onTap: _submitting ? null : _selectDate,
//       validator:
//           (val) => val == null || val.isEmpty ? "Date is required" : null,
//     );
//   }

//   Widget _buildCustomerPONumberField() {
//     return TextFormField(
//       controller: customerPONumberController,
//       enabled: !_submitting,
//       decoration: const InputDecoration(
//         labelText: "Customer PO Number",
//         border: OutlineInputBorder(),
//       ),
//       validator:
//           (val) =>
//               val == null || val.isEmpty
//                   ? "Customer PO Number is required"
//                   : null,
//     );
//   }

//   Widget _buildCustomerPODateField() {
//     return TextFormField(
//       controller: customerPODateController,
//       readOnly: true,
//       enabled: !_submitting,
//       decoration: const InputDecoration(
//         labelText: "Customer PO Date",
//         border: OutlineInputBorder(),
//         suffixIcon: Icon(Icons.calendar_today),
//       ),
//       onTap: _submitting ? null : _selectCustomerPODate,
//       validator:
//           (val) =>
//               val == null || val.isEmpty
//                   ? "Customer PO Date is required"
//                   : null,
//     );
//   }

//   Widget _buildItemsList() {
//     return Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               "Items",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: items.length,
//             separatorBuilder: (context, index) => const Divider(height: 1),
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return ListTile(
//                 title: Text(item.itemName),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Code: ${item.itemCode}"),
//                     Text(
//                       "Qty: ${item.qty} ${item.uom} | Rate: ₹${item.basicRate.toStringAsFixed(2)}",
//                     ),
//                     if (item.discountAmount != null && item.discountAmount! > 0)
//                       Text(
//                         "Discount: ${item.discountType} - ₹${item.discountAmount!.toStringAsFixed(2)}",
//                       ),
//                     Text(
//                       "Tax: ₹${item.taxAmount?.toStringAsFixed(2) ?? '0.00'}",
//                     ),
//                     Text(
//                       "Total: ₹${item.totalAmount.toStringAsFixed(2)}",
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ),
//                 trailing:
//                     salesOrderReference == "Without Quotation Reference"
//                         ? IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed:
//                               _submitting ? null : () => _removeItem(index),
//                         )
//                         : null,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddItemButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: _submitting ? null : _showAddItemPage,
//         icon: const Icon(Icons.add),
//         label: const Text("Add Item"),
//       ),
//     );
//   }

//   Widget _buildTotalCard() {
//     final totalBasic = _calculateTotalBasic();
//     final totalDiscount = _calculateTotalDiscount();
//     final totalTax = _calculateTotalTax();
//     final totalAmount = _calculateTotalAmount();

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Order Summary",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Basic Amount:"),
//                 Text("₹${totalBasic.toStringAsFixed(2)}"),
//               ],
//             ),
//             if (totalDiscount > 0) ...[
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Total Discount:"),
//                   Text("- ₹${totalDiscount.toStringAsFixed(2)}"),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Total Tax:"),
//                 Text("₹${totalTax.toStringAsFixed(2)}"),
//               ],
//             ),
//             const Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   "Final Amount:",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 Text(
//                   "₹${totalAmount.toStringAsFixed(2)}",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAttachmentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "Attachments",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 8),
//         if (attachments.isNotEmpty) ...[
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: attachments.length,
//             itemBuilder: (context, index) {
//               final file = attachments[index];
//               return Card(
//                 child: ListTile(
//                   leading: const Icon(Icons.attach_file),
//                   title: Text(file.name),
//                   subtitle: Text("${(file.size / 1024).toStringAsFixed(1)} KB"),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.delete),
//                     onPressed:
//                         _submitting ? null : () => _removeAttachment(index),
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: 8),
//         ],
//         ElevatedButton.icon(
//           onPressed: _submitting ? null : _pickFiles,
//           icon: const Icon(Icons.attach_file),
//           label: const Text("Add Attachments"),
//         ),
//       ],
//     );
//   }

//   Widget _buildUpdateButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _submitting ? null : _updateSalesOrder,
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//         ),
//         child:
//             _submitting
//                 ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                 : const Text(
//                   "Update Sales Order",
//                   style: TextStyle(fontSize: 16),
//                 ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/sales_order/models/add_sales_order.dart';
import 'package:nhapp/pages/sales_order/pages/add_item.dart';
import 'package:nhapp/pages/sales_order/service/add_service.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';

class EditSalesOrderPage extends StatefulWidget {
  final String ioYear;
  final String ioGroup;
  final String ioSiteCode;
  final String ioNumber;
  final int locationId;

  const EditSalesOrderPage({
    super.key,
    required this.ioYear,
    required this.ioGroup,
    required this.ioSiteCode,
    required this.ioNumber,
    required this.locationId,
  });

  @override
  State<EditSalesOrderPage> createState() => _EditSalesOrderPageState();
}

class _EditSalesOrderPageState extends State<EditSalesOrderPage> {
  late SalesOrderService _service;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController orderFromController = TextEditingController();
  final TextEditingController billToController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerPONumberController =
      TextEditingController();
  final TextEditingController customerPODateController =
      TextEditingController();
  final TextEditingController quotationNumberController =
      TextEditingController();

  String salesOrderReference = "Without Quotation Reference";
  Customer? selectedOrderFrom;
  Customer? selectedBillTo;
  DateTime? selectedDate;
  DateTime? selectedCustomerPODate;
  List<RateStructure> rateStructures = [];
  List<SalesOrderItem> items = [];
  List<PlatformFile> attachments = [];
  DocumentDetail? documentDetail;
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;

  // Quotation related fields - Updated to match add_so.dart
  List<QuotationNumber> quotationNumbers = [];
  List<QuotationItemDetail> quotationItemDetails = [];
  QuotationNumber? selectedQuotationNumber;
  bool _loadingQuotationDetails = false;

  // Sales Order details
  Map<String, dynamic>? salesOrderDetails;
  String originalOrderId = "";

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await SalesOrderService.create();
    await _loadFinancePeriod();
    await _loadRateStructures();
    await _loadSalesOrderDetails();
    setState(() => _isLoading = false);
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
    }
  }

  Future<void> _loadRateStructures() async {
    rateStructures = await _service.fetchRateStructures();
  }

  Future<void> _loadSalesOrderDetails() async {
    try {
      final companyId = _service.companyDetails['id'];
      final response = await _service.fetchSalesOrderDetails(
        widget.ioYear,
        widget.ioGroup,
        widget.ioSiteCode,
        widget.ioNumber,
        widget.locationId,
        companyId,
      );

      if (response['success'] == true && response['data'] != null) {
        salesOrderDetails = response['data'];
        _populateFormFromResponse(salesOrderDetails!);
      }
    } catch (e) {
      _showError("Error loading sales order details: ${e.toString()}");
    }
  }

  void _populateFormFromResponse(Map<String, dynamic> data) {
    final soDetails = data['salesOrderDetails'][0];
    final modelDetails = data['modelDetails'] as List;
    final rateStructureDetails = data['rateStructureDetails'] as List;
    final discountDetails = data['discountDetails'] as List;

    // Set basic sales order details
    originalOrderId = soDetails['orderId'].toString();

    // Set customer details
    selectedOrderFrom = Customer(
      customerCode: soDetails['customerCode'] ?? '',
      customerName: soDetails['customerName'] ?? '',
      gstNumber: soDetails['gstNo'] ?? '',
      telephoneNo: '',
      customerFullName: soDetails['customerFullName'] ?? '',
    );
    orderFromController.text = selectedOrderFrom!.customerName;

    selectedBillTo = Customer(
      customerCode: soDetails['billToCode'] ?? '',
      customerName: soDetails['billToName'] ?? '',
      gstNumber: soDetails['gstNo'] ?? '',
      telephoneNo: '',
      customerFullName:
          "${soDetails['billToCode']} - ${soDetails['billToName']}",
    );
    billToController.text = selectedBillTo!.customerName;

    // Set dates
    selectedDate = DateTime.parse(soDetails['ioDate']);
    dateController.text = FormatUtils.formatDateForUser(selectedDate!);

    selectedCustomerPODate = DateTime.parse(soDetails['customerPODate']);
    customerPODateController.text = FormatUtils.formatDateForUser(
      selectedCustomerPODate!,
    );

    // Set customer PO number
    customerPONumberController.text = soDetails['customerPONumber'] ?? '';

    // Set quotation reference - Updated to match new structure
    if (soDetails['quotationNumber'] != null &&
        soDetails['quotationNumber'].toString().isNotEmpty &&
        soDetails['quotationNumber'] != '0') {
      salesOrderReference = "With Quotation Reference";
      quotationNumberController.text = soDetails['quotationNumber'];

      selectedQuotationNumber = QuotationNumber(
        select: false,
        customerCode: soDetails['customerCode'] ?? '',
        quotationID: soDetails['quotationId'] ?? 0,
        qtnNumber: soDetails['quotationNumber'] ?? '',
        quotationDate:
            soDetails['quotationDate'] != null &&
                    soDetails['quotationDate'] != '0001-01-01T00:00:00'
                ? DateTime.parse(soDetails['quotationDate'])
                : DateTime.now(),
        revisionNo: 0,
        revisionDate: null,
        quotationCurrency: 'INR',
        agentCode: '',
        inquiryNo: '',
        inquiryDate: null,
        salesmanCode: '',
        salesmanName: '',
        consultantCode: '',
        consultantName: '',
        gstno: '',
        quotationYear: soDetails['quotationYear'] ?? '',
        quotationGroup: soDetails['quotationGroup'] ?? '',
        quotationNumber: soDetails['quotationNumber'] ?? '',
        quotationSiteCode: '',
        quotationSiteId: 0,
      );
    }

    // Populate items
    items.clear();
    for (int i = 0; i < modelDetails.length; i++) {
      final model = modelDetails[i];

      // Find discount details for this item
      String discountType = "None";
      double? discountPercentage;
      double? discountAmount;

      final discount = discountDetails.firstWhere(
        (d) => d['itemCode'] == model['salesItemCode'],
        orElse: () => {},
      );

      if (discount.isNotEmpty) {
        final discType = discount['discountType'] ?? 'None';
        if (discType != 'None' && discType != 'N') {
          if (discType == 'Percentage' || discType == 'P') {
            discountType = 'Percentage';
            discountPercentage = (discount['discountValue'] ?? 0).toDouble();
            discountAmount =
                (model['basicPriceSUOM'] * model['qtySUOM']) *
                (discountPercentage! / 100);
          } else {
            discountType = 'Value';
            discountAmount = (discount['discountValue'] ?? 0).toDouble();
            final basicAmount =
                (model['basicPriceSUOM'] ?? 0).toDouble() *
                (model['qtySUOM'] ?? 0).toDouble();
            discountPercentage =
                basicAmount > 0 ? (discountAmount! / basicAmount) * 100 : 0;
          }
        }
      }

      // Calculate tax amount for this item
      double taxAmount = 0.0;
      final itemRateStructures = rateStructureDetails.where(
        (rs) => rs['customerItemCode'] == model['salesItemCode'],
      );
      for (final rs in itemRateStructures) {
        taxAmount += (rs['rateAmount'] ?? 0).toDouble();
      }

      // Get rate structure rows for this item
      List<Map<String, dynamic>> rateStructureRows =
          itemRateStructures.toList() as List<Map<String, dynamic>>;

      final basicRate = (model['basicPriceSUOM'] ?? 0).toDouble();
      final qty = (model['qtySUOM'] ?? 0).toDouble();
      final basicAmount = basicRate * qty;
      final discountedAmount = basicAmount - (discountAmount ?? 0);
      final totalAmount = discountedAmount + taxAmount;

      items.add(
        SalesOrderItem(
          itemName: model['salesItemDesc'] ?? '',
          itemCode: model['salesItemCode'] ?? '',
          qty: qty,
          basicRate: basicRate,
          uom: model['uom'] ?? 'NOS',
          discountType: discountType,
          discountPercentage: discountPercentage,
          discountAmount: discountAmount,
          rateStructure: model['rateStructureCode'] ?? '',
          taxAmount: taxAmount,
          totalAmount: totalAmount,
          rateStructureRows: rateStructureRows,
          lineNo: model['itemLineNo'] ?? (i + 1),
          hsnCode: model['hsnCode'] ?? '',
        ),
      );
    }

    setState(() {});
  }

  Future<void> _onOrderFromSelected(Customer customer) async {
    setState(() {
      selectedOrderFrom = customer;
      orderFromController.text = customer.customerName;
      billToController.text = customer.customerName;
      selectedBillTo = customer;
    });

    // Load quotation numbers if quotation reference is selected
    if (salesOrderReference == "With Quotation Reference") {
      await _loadQuotationNumbers(customer.customerCode);
    }
  }

  Future<void> _onBillToSelected(Customer customer) async {
    setState(() {
      selectedBillTo = customer;
      billToController.text = customer.customerName;
    });
  }

  // Updated to match add_so.dart structure
  Future<void> _loadQuotationNumbers(String customerCode) async {
    try {
      final quotationListResponse = await _service.fetchQuotationNumberList(
        customerCode,
      );

      quotationNumbers = quotationListResponse.quotationDetails;
      quotationItemDetails = quotationListResponse.quotationItemDetails;

      setState(() {});
    } catch (e) {
      _showError("Error loading quotation numbers: ${e.toString()}");
    }
  }

  // Updated to match add_so.dart structure
  Future<void> _onQuotationNumberSelected(
    QuotationNumber quotationNumber,
  ) async {
    setState(() {
      selectedQuotationNumber = quotationNumber;
      quotationNumberController.text = quotationNumber.qtnNumber;
      _loadingQuotationDetails = true;
      items.clear();
    });

    try {
      // Filter items for the selected quotation
      final selectedQuotationItems =
          quotationItemDetails
              .where((item) => item.quotationId == quotationNumber.quotationID)
              .toList();

      // Build request body for fetching quotation details
      final requestBody = {
        "DisplayMaxRecords": 1000,
        "QuotationDetails": [
          {"QuotationId": quotationNumber.quotationID},
        ],
        "ItemDetails":
            selectedQuotationItems
                .map(
                  (item) => {
                    "SalesItemCode": item.salesItemCode,
                    "QuotationId": item.quotationId,
                    "itemLineNo": item.itemLineNo,
                  },
                )
                .toList(),
      };

      final quotationDetails = await _service.fetchQuotationDetails(
        requestBody,
      );

      // Convert quotation items to sales order items
      int lineNo = 1;
      // for (final detail in quotationDetails.itemDetail) {
      //   // Calculate discount details
      //   String discountType = "None";
      //   double? discountPercentage;
      //   double? discountAmount;

      //   if (quotationDetails.discountDetail != null &&
      //       quotationDetails.discountDetail!.isNotEmpty) {
      //     final discountDetail = quotationDetails.discountDetail!.firstWhere(
      //       (d) => d['salesItemCode'] == detail['salesItemCode'],
      //       orElse: () => {},
      //     );

      //     if (discountDetail.isNotEmpty &&
      //         (discountDetail['discountValue'] ?? 0) > 0) {
      //       final discValue = (discountDetail['discountValue'] ?? 0).toDouble();
      //       final discType = discountDetail['discountType'] ?? '';

      //       if (discType == 'Percentage') {
      //         discountType = 'Percentage';
      //         discountPercentage = discValue;
      //         discountAmount =
      //             ((detail['basicPriceSUOM'] ?? 0).toDouble() *
      //                 (detail['qtySUOM'] ?? 0).toDouble()) *
      //             (discValue / 100);
      //       } else {
      //         discountType = 'Value';
      //         discountAmount = discValue;
      //         final basicAmount =
      //             (detail['basicPriceSUOM'] ?? 0).toDouble() *
      //             (detail['qtySUOM'] ?? 0).toDouble();
      //         discountPercentage =
      //             basicAmount > 0 ? (discValue / basicAmount) * 100 : 0;
      //       }
      //     }
      //   }

      //   // Calculate tax amount
      //   double taxAmount = 0.0;
      //   if (quotationDetails.rateStructDetail != null) {
      //     final rateStructDetails = quotationDetails.rateStructDetail!.where(
      //       (rs) => rs['customerItemCode'] == detail['salesItemCode'],
      //     );
      //     for (final rsDetail in rateStructDetails) {
      //       taxAmount += (rsDetail['rateAmount'] ?? 0).toDouble();
      //     }
      //   }

      //   // Calculate total amount
      //   final basicRate = (detail['basicPriceSUOM'] ?? 0).toDouble();
      //   final qty = (detail['qtySUOM'] ?? 0).toDouble();
      //   final basicAmount = basicRate * qty;
      //   final discountedAmount = basicAmount - (discountAmount ?? 0);
      //   final totalAmount = discountedAmount + taxAmount;

      //   // Get rate structure rows for this item
      //   List<Map<String, dynamic>> rateStructureRows = [];
      //   if (quotationDetails.rateStructDetail != null) {
      //     rateStructureRows =
      //         quotationDetails.rateStructDetail!
      //             .where(
      //               (rs) => rs['customerItemCode'] == detail['salesItemCode'],
      //             )
      //             .toList();
      //   }

      //   items.add(
      //     SalesOrderItem(
      //       itemName: detail['salesItemDesc'] ?? '',
      //       itemCode: detail['salesItemCode'] ?? '',
      //       qty: qty,
      //       basicRate: basicRate,
      //       uom: detail['uom'] ?? 'NOS',
      //       discountType: discountType,
      //       discountPercentage: discountPercentage,
      //       discountAmount: discountAmount,
      //       rateStructure: detail['rateStructureCode'] ?? '',
      //       taxAmount: taxAmount,
      //       totalAmount: totalAmount,
      //       rateStructureRows: rateStructureRows,
      //       lineNo: lineNo,
      //       hsnCode: detail['hsnCode'] ?? '',
      //     ),
      //   );
      //   lineNo++;
      // }

      setState(() {});
    } catch (e) {
      _showError("Error loading quotation details: ${e.toString()}");
    } finally {
      setState(() => _loadingQuotationDetails = false);
    }
  }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<SalesOrderItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddSalesOrderItemPage(
              service: _service,
              rateStructures: rateStructures,
            ),
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
      // Re-assign line numbers
      for (int i = 0; i < items.length; i++) {
        items[i].lineNo = i + 1;
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        attachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate:
          startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: endDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = FormatUtils.formatDateForUser(picked);
      });
    }
  }

  Future<void> _selectCustomerPODate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedCustomerPODate ?? DateTime.now(),
      firstDate:
          startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: endDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedCustomerPODate = picked;
        customerPODateController.text = FormatUtils.formatDateForUser(picked);
      });
    }
  }

  Map<String, dynamic> _buildUpdatePayload() {
    final userId = _service.tokenDetails['user']['id'] ?? 0;
    final locationId = _service.locationDetails['id'] ?? 0;
    final locationCode = _service.locationDetails['code'] ?? "";
    final companyCode = _service.companyDetails['code'] ?? "";
    final companyId = _service.companyId;
    final docYear = _financeDetails?['financialYear'] ?? "";

    // Build model details
    List<Map<String, dynamic>> modelDetails = [];
    List<Map<String, dynamic>> discountDetails = [];
    List<Map<String, dynamic>> rateStructureDetails = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      item.lineNo = i + 1;

      final modelDetail = item.toModelDetail();
      modelDetail['custPONumber'] = customerPONumberController.text;
      modelDetail['orderId'] = int.parse(originalOrderId);

      // Add quotation reference if applicable - Updated field names
      if (salesOrderReference == "With Quotation Reference" &&
          selectedQuotationNumber != null) {
        modelDetail['quotationId'] = selectedQuotationNumber!.quotationID;
        modelDetail['quotationLineNo'] = item.lineNo;
        modelDetail['quotationAmendNo'] = 0;
      }
      modelDetails.add(modelDetail);

      final discountDetail = item.toDiscountDetail();
      if (discountDetail.isNotEmpty) {
        discountDetail['orderId'] = int.parse(originalOrderId);
        discountDetails.add(discountDetail);
      }

      rateStructureDetails.addAll(item.toRateStructureDetails());
    }

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAfterDiscount = totalBasic - totalDiscount;
    final finalAmount = totalAfterDiscount + totalTax;

    return {
      "authorizationRequired": "Y",
      "autoNumberRequired": "N", // N for update
      "siteRequired": "Y",
      "authorizationDate": FormatUtils.formatDateForApi(
        selectedDate ?? DateTime.now(),
      ),
      "fromLocationId": locationId,
      "userId": userId,
      "companyId": companyId,
      "companyCode": companyCode,
      "fromLocationCode": locationCode,
      "fromLocationName": _service.locationDetails['name'] ?? "",
      "ip": "",
      "mac": "",
      "docType": "OB",
      "docSubType": "OB",
      "domesticCurrencyCode": "INR",
      "salesOrderDetails": {
        "orderId": int.parse(originalOrderId),
        "customerPONumber": customerPONumberController.text,
        "customerPODate": FormatUtils.formatDateForApi(selectedCustomerPODate!),
        "quotationId":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationID
                : 0,
        "quotationYear":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationYear
                : "",
        "quotationGroup":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationGroup
                : "",
        "quotationNumber":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? selectedQuotationNumber!.quotationNumber
                : "",
        "quotationDate":
            salesOrderReference == "With Quotation Reference" &&
                    selectedQuotationNumber != null
                ? FormatUtils.formatDateForApi(
                  selectedQuotationNumber!.quotationDate,
                )
                : null,
        "customerCode": selectedOrderFrom?.customerCode ?? "",
        "customerName": selectedOrderFrom?.customerName ?? "",
        "salesManCode": "",
        "attachFlag": "",
        "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "totalAmountAfterDiscountDomesticCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
        "discountType": "V",
        "discountAmount": "0.00",
        "exchangeRate": "1.0000",
        "orderStatus": "O",
        "ioYear": widget.ioYear,
        "ioGroup": widget.ioGroup,
        "ioSiteId": locationId.toString(),
        "ioSiteCode": widget.ioSiteCode,
        "ioNumber": widget.ioNumber,
        "ioDate": FormatUtils.formatDateForApi(selectedDate!),
        "billToCode": selectedBillTo?.customerCode ?? "",
        "currencyCode": "INR",
        "salesOrderType": "REG",
        "custType": "CU",
        "lcDetail": "F",
        "bgDetail": "F",
        "isAgentAssociated": false,
        "custContactPersonId": "",
        "salesOrderRefNo": "",
        "buyerCode": 0,
        "soDeliveryDate": null,
        "bookCode": "",
        "agentCode": "",
        "modOfDispatchCode": "",
        "isFreeSupply": false,
        "isReturnable": false,
        "isRoadPermitReceived": false,
        "customerLOINumber": "",
        "customerLOIDate": "",
        "isInterBranchTransfer": false,
        "customerPOId": 0,
        "consultantCode": "",
        "billToCreditLimit": 0,
        "billToAccBalance": 0,
        "config": "N",
        "projectName": "",
      },
      "modelDetails": modelDetails,
      "discountDetails": discountDetails,
      "rateStructureDetails": rateStructureDetails,
      "deliveryDetails": [],
      "paymentDetails": [],
      "termDetails": [],
      "specificationDetails": [],
      "optionalItemDetails": [],
      "textDetails": [],
      "standardTerms": [],
      "historyDetails": [],
      "addOnDetails": [],
      "subItemDetails": [],
      "noteDetails": [],
      "projectLotDetails": [],
      "equipmentAttributeDetails": [],
      "technicalspec": [],
      "msctechspecifications": true,
    };
  }

  Future<void> _updateSalesOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedOrderFrom == null) {
      _showError("Please select Order From customer");
      return;
    }
    if (selectedBillTo == null) {
      _showError("Please select Bill To customer");
      return;
    }
    if (customerPONumberController.text.isEmpty) {
      _showError("Please enter Customer PO Number");
      return;
    }
    if (selectedCustomerPODate == null) {
      _showError("Please select Customer PO Date");
      return;
    }
    if (items.isEmpty) {
      _showError("Please add at least one item");
      return;
    }

    setState(() => _submitting = true);

    try {
      final payload = _buildUpdatePayload();
      final response = await _service.updateSalesOrder(payload);

      if (response['success'] == true) {
        _showSuccess(response['message'] ?? "Sales Order updated successfully");
        Navigator.pop(context, true);
      } else {
        _showError(response['errorMessage'] ?? "Failed to update sales order");
      }
    } catch (e) {
      _showError("Error during update: ${e.toString()}");
    } finally {
      setState(() => _submitting = false);
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
  void dispose() {
    orderFromController.dispose();
    billToController.dispose();
    dateController.dispose();
    customerPONumberController.dispose();
    customerPODateController.dispose();
    quotationNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Sales Order - ${widget.ioNumber}"),
        elevation: 1,
      ),
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
                      _buildSalesOrderReferenceDropdown(),
                      const SizedBox(height: 16),
                      _buildOrderFromField(),
                      const SizedBox(height: 16),
                      _buildBillToField(),
                      const SizedBox(height: 16),
                      if (salesOrderReference ==
                          "With Quotation Reference") ...[
                        _buildQuotationNumberField(),
                        const SizedBox(height: 16),
                      ],
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerPONumberField(),
                      const SizedBox(height: 16),
                      _buildCustomerPODateField(),
                      const SizedBox(height: 16),
                      if (_loadingQuotationDetails)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
                      if (salesOrderReference == "Without Quotation Reference")
                        _buildAddItemButton(),
                      if (items.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildTotalCard(),
                      ],
                      const SizedBox(height: 24),
                      _buildAttachmentSection(),
                      const SizedBox(height: 24),
                      _buildUpdateButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSalesOrderReferenceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: "Sales Order Reference",
        border: OutlineInputBorder(),
      ),
      value: salesOrderReference,
      items:
          ["Without Quotation Reference", "With Quotation Reference"]
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
      onChanged:
          _submitting
              ? null
              : (val) {
                if (val != null) {
                  setState(() {
                    salesOrderReference = val;
                    // Clear quotation data when switching
                    if (val == "Without Quotation Reference") {
                      quotationNumbers.clear();
                      quotationItemDetails.clear();
                      selectedQuotationNumber = null;
                      quotationNumberController.clear();
                    } else if (selectedOrderFrom != null) {
                      _loadQuotationNumbers(selectedOrderFrom!.customerCode);
                    }
                  });
                }
              },
      validator:
          (val) => val == null ? "Sales Order Reference is required" : null,
    );
  }

  Widget _buildOrderFromField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: orderFromController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_submitting,
          decoration: const InputDecoration(
            labelText: "Order From",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Order From is required" : null,
        );
      },
      suggestionsCallback:
          _submitting
              ? (pattern) async => []
              : (pattern) async {
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
      onSelected: _submitting ? null : _onOrderFromSelected,
    );
  }

  Widget _buildBillToField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: billToController,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: !_submitting,
          decoration: const InputDecoration(
            labelText: "Bill To",
            border: OutlineInputBorder(),
          ),
          validator:
              (val) =>
                  val == null || val.isEmpty ? "Bill To is required" : null,
        );
      },
      suggestionsCallback:
          _submitting
              ? (pattern) async => []
              : (pattern) async {
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
      onSelected: _submitting ? null : _onBillToSelected,
    );
  }

  // Updated to match add_so.dart structure
  Widget _buildQuotationNumberField() {
    return DropdownButtonFormField<QuotationNumber>(
      decoration: const InputDecoration(
        labelText: "Quotation Number",
        border: OutlineInputBorder(),
      ),
      value: selectedQuotationNumber,
      isExpanded: true,
      items:
          quotationNumbers.map((quotation) {
            return DropdownMenuItem<QuotationNumber>(
              value: quotation,
              child: Text(quotation.qtnNumber, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged:
          _submitting || _loadingQuotationDetails
              ? null
              : (val) {
                if (val != null) {
                  _onQuotationNumberSelected(val);
                }
              },
      validator:
          salesOrderReference == "With Quotation Reference"
              ? (val) => val == null ? "Quotation Number is required" : null
              : null,
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      readOnly: true,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Date",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: _submitting ? null : _selectDate,
      validator:
          (val) => val == null || val.isEmpty ? "Date is required" : null,
    );
  }

  Widget _buildCustomerPONumberField() {
    return TextFormField(
      controller: customerPONumberController,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Customer PO Number",
        border: OutlineInputBorder(),
      ),
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Customer PO Number is required"
                  : null,
    );
  }

  Widget _buildCustomerPODateField() {
    return TextFormField(
      controller: customerPODateController,
      readOnly: true,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Customer PO Date",
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: _submitting ? null : _selectCustomerPODate,
      validator:
          (val) =>
              val == null || val.isEmpty
                  ? "Customer PO Date is required"
                  : null,
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.itemName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Code: ${item.itemCode}"),
                    Text(
                      "Qty: ${item.qty} ${item.uom} | Rate: ₹${item.basicRate.toStringAsFixed(2)}",
                    ),
                    if (item.discountAmount != null && item.discountAmount! > 0)
                      Text(
                        "Discount: ${item.discountType} - ₹${item.discountAmount!.toStringAsFixed(2)}",
                      ),
                    Text(
                      "Tax: ₹${item.taxAmount?.toStringAsFixed(2) ?? '0.00'}",
                    ),
                    Text(
                      "Total: ₹${item.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing:
                    salesOrderReference == "Without Quotation Reference"
                        ? IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed:
                              _submitting ? null : () => _removeItem(index),
                        )
                        : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add Item"),
      ),
    );
  }

  Widget _buildTotalCard() {
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAmount = _calculateTotalAmount();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Basic Amount:"),
                Text("₹${totalBasic.toStringAsFixed(2)}"),
              ],
            ),
            if (totalDiscount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Discount:"),
                  Text("- ₹${totalDiscount.toStringAsFixed(2)}"),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Tax:"),
                Text("₹${totalTax.toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Final Amount:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Attachments",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (attachments.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final file = attachments[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(file.name),
                  subtitle: Text("${(file.size / 1024).toStringAsFixed(1)} KB"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed:
                        _submitting ? null : () => _removeAttachment(index),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
        ElevatedButton.icon(
          onPressed: _submitting ? null : _pickFiles,
          icon: const Icon(Icons.attach_file),
          label: const Text("Add Attachments"),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _updateSalesOrder,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child:
            _submitting
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text(
                  "Update Sales Order",
                  style: TextStyle(fontSize: 16),
                ),
      ),
    );
  }
}
