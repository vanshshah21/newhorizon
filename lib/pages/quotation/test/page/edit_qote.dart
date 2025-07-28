import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/pages/quotation/test/page/ad_itm.dart';
import 'package:nhapp/pages/quotation/test/page/edit_item.dart';
import 'package:nhapp/pages/quotation/test/service/qote_service.dart';
import 'package:nhapp/pages/quotation/test/service/quote_attachment.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class EditQuotationPage extends StatefulWidget {
  final String quotationNumber;
  final String quotationYear;
  final String? quotationGrp;
  final int? quotationSiteId;

  const EditQuotationPage({
    super.key,
    required this.quotationNumber,
    required this.quotationYear,
    required this.quotationGrp,
    required this.quotationSiteId,
  });

  @override
  State<EditQuotationPage> createState() => _EditQuotationPageState();
}

class _EditQuotationPageState extends State<EditQuotationPage> {
  late QuotationService _service;
  late final QuotationAttachmentService _attachmentService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController customerController = TextEditingController();
  final TextEditingController billToController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  QuotationBase? selectedQuotationBase;
  List<QuotationBase> quotationBases = [];
  DateTime? selectedDate;
  Customer? selectedCustomer;
  Customer? selectedBillToCustomer;
  Salesman? selectedSalesman;
  List<Salesman> salesmanList = [];
  List<RateStructure> rateStructures = [];
  List<QuotationItem> items = [];
  List<PlatformFile> attachments = [];
  DocumentDetail? documentDetail;
  List<Inquiry> inquiryList = [];
  Inquiry? selectedInquiry;
  QuotationEditData? originalData;
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;
  bool _isDuplicateAllowed = false;
  late double _exchangeRate;
  final List<PlatformFile> _newAttachments = [];
  final List<Map<String, dynamic>> _editableAttachments = [];
  String? _documentNo;
  late final String currency;
  int _amendmentSrNo = -1;
  late final bool msctechspecifications;
  late final bool istechnicalspecreq;
  bool _shouldBlockForm = false;
  DateTime? inquiryDate;

  @override
  void initState() {
    super.initState();
    _attachmentService = QuotationAttachmentService(Dio());
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    await initializeCurrencyCode();
    _service = await QuotationService.create();
    await _loadFinancePeriod();
    await _loadQuotationBases();
    await _loadRateStructures();
    await _loadSalesmanList();
    await _loadDocumentDetail();
    await _loadSalesPolicy();
    await _getExchangeRate();
    await _loadQuotationData();
    await _loadAttachments();
    setState(() => _isLoading = false);
  }

  Future<void> _getExchangeRate() async {
    try {
      final domCurrency = await StorageUtils.readJson('domestic_currency');
      if (domCurrency == null) throw Exception("Domestic currency not set");

      currency = domCurrency['domCurCode'] ?? 'INR';
      _exchangeRate = await _service.getExchangeRate() ?? 1.0;
    } catch (e) {
      debugPrint("Error loading exchange rate: $e");
      _exchangeRate = 1.0;
    }
  }

  Future<void> _loadSalesPolicy() async {
    try {
      final salesPolicy = await _service.getSalesPolicy();
      _isDuplicateAllowed =
          salesPolicy['allowduplictae'] ??
          salesPolicy['allowduplicate'] ??
          false;
      msctechspecifications =
          salesPolicy['msctechspecifications'] == "True" ? true : false;

      istechnicalspecreq = salesPolicy['istechnicalspecreq'];

      // Check if form should be blocked after loading sales policy
      if (istechnicalspecreq == true) {
        setState(() {
          _shouldBlockForm = true;
          _isLoading = false;
        });
        return; // Exit early, don't load prefill data
      }
    } catch (e) {
      debugPrint("Error loading sales policy: $e");
      _isDuplicateAllowed = false;
    }
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
    }
  }

  Future<void> _loadQuotationBases() async {
    quotationBases = await _service.fetchQuotationBaseList();
  }

  Future<void> _loadRateStructures() async {
    rateStructures = await _service.fetchRateStructures();
  }

  Future<void> _loadSalesmanList() async {
    salesmanList = await _service.fetchSalesmanList();
  }

  Future<void> _loadDocumentDetail() async {
    documentDetail = await _service.fetchDefaultDocumentDetail("SQ");
  }

  Future<void> _loadAttachments() async {
    try {
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';
      final docYear = _financeDetails?['financialYear'] ?? "";
      final groupCode = documentDetail?.groupCode ?? "QA";
      final locationCode = _service.locationDetails['code'] ?? "";

      // Build document number for quotation
      _documentNo =
          "$docYear/$groupCode/$locationCode/${widget.quotationNumber}/QUOTATIONENTRY";

      final attachments = await _attachmentService.fetchAttachments(
        baseUrl: baseUrl,
        documentNo: _documentNo!,
        formId: "06103", // Form ID for quotation
      );

      setState(() {
        _editableAttachments.clear();
        _editableAttachments.addAll(
          attachments.map(
            (a) => {
              'original': a,
              'action': 'none', // none, delete, replace
              'replacementFile': null,
            },
          ),
        );
      });
    } catch (e) {
      debugPrint('Error loading attachments: $e');
    }
  }

  Future<void> _loadQuotationData() async {
    try {
      originalData = await _service.fetchQuotationForEdit(
        widget.quotationNumber,
        widget.quotationYear,
        widget.quotationGrp,
        widget.quotationSiteId,
      );

      if (originalData?.quotationDetails?.isNotEmpty == true) {
        final quotationDetail = originalData!.quotationDetails!.first;

        // Populate form with existing data
        selectedDate = DateTime.parse(quotationDetail['quotationDate']);
        dateController.text = FormatUtils.formatDateForUser(selectedDate!);
        subjectController.text = quotationDetail['subject'] ?? '';

        // Determine quotation base based on inquiryNumber
        final inquiryNumber = quotationDetail['inquiryNumber'];
        final hasInquiry = inquiryNumber != null && inquiryNumber != "";

        if (hasInquiry) {
          // Set to "With Inquiry Reference" if inquiryNumber exists
          selectedQuotationBase = quotationBases.firstWhere(
            (base) => base.code == "I",
            orElse:
                () =>
                    quotationBases.isNotEmpty
                        ? quotationBases.first
                        : QuotationBase(
                          code: 'I',
                          name: 'With Inquiry Reference',
                        ),
          );
        } else {
          // Set to "Without Inquiry Reference" if inquiryNumber is empty
          selectedQuotationBase = quotationBases.firstWhere(
            (base) => base.code == "O",
            orElse:
                () =>
                    quotationBases.isNotEmpty
                        ? quotationBases.first
                        : QuotationBase(
                          code: 'O',
                          name: 'Without Inquiry Reference',
                        ),
          );
        }

        // Create customer objects
        selectedCustomer = Customer(
          customerCode: quotationDetail['customerCode'] ?? '',
          customerName: quotationDetail['customerName'] ?? '',
          gstNumber: quotationDetail['gstNo'] ?? '',
          telephoneNo: '',
          customerFullName: quotationDetail['customerName'] ?? '',
        );
        customerController.text = selectedCustomer!.customerName;

        selectedBillToCustomer = Customer(
          customerCode: quotationDetail['billToCustomerCode'] ?? '',
          customerName: quotationDetail['billToCustomerName'] ?? '',
          gstNumber: '',
          telephoneNo: '',
          customerFullName: quotationDetail['billToCustomerName'] ?? '',
        );
        billToController.text = selectedBillToCustomer!.customerName;

        // Set salesman
        selectedSalesman = salesmanList.firstWhere(
          (s) => s.salesmanCode == quotationDetail['salesPersonCode'],
        );

        // Handle inquiry setup for "I" quotation base
        if (selectedQuotationBase?.code == "I") {
          // Load inquiry list for the selected customer
          if (selectedCustomer != null) {
            inquiryList = await _service.fetchInquiryList(
              selectedCustomer!.customerCode,
            );
          }

          // Set inquiry if applicable
          final inquiryId = quotationDetail['inquiryId'];
          final inquiryNumber = quotationDetail['inquiryNumber'];

          if (inquiryId != null &&
              inquiryId != 0 &&
              inquiryNumber != null &&
              inquiryNumber.isNotEmpty) {
            // Find the inquiry in the loaded list or create one
            selectedInquiry = inquiryList.firstWhere(
              (inq) =>
                  inq.inquiryId == inquiryId ||
                  inq.inquiryNumber == inquiryNumber,
              orElse:
                  () => Inquiry(
                    inquiryNumber: inquiryNumber,
                    inquiryId: inquiryId,
                    customerName: quotationDetail['customerName'] ?? '',
                  ),
            );

            // If not found in list, add it to the list
            if (!inquiryList.any((inq) => inq.inquiryId == inquiryId)) {
              inquiryList.add(selectedInquiry!);
            }
          }
        }

        // Process model details (items) - use the EXACT same logic as ad_qote.dart
        items.clear();
        if (originalData!.modelDetails?.isNotEmpty == true) {
          _amendmentSrNo =
              originalData!.modelDetails!.first['amendmentSrNo'] ?? -1;
          for (int i = 0; i < originalData!.modelDetails!.length; i++) {
            final modelDetail = originalData!.modelDetails![i];

            // Calculate discount details
            String discountType = "None";
            double? discountPercentage;
            double? discountAmount =
                modelDetail['discountAmt']?.toDouble() ?? 0.0;
            String? discountCode;

            // Get discount code from discount details if available
            if (originalData!.discountDetails != null &&
                originalData!.discountDetails!.isNotEmpty) {
              final itemDiscountDetail = originalData!.discountDetails!
                  .firstWhere(
                    (discount) =>
                        discount['itmLineNo'] == modelDetail['itemLineNo'],
                    orElse: () => <String, dynamic>{},
                  );
              if (itemDiscountDetail.isNotEmpty) {
                discountCode = itemDiscountDetail['discountCode'];
              }
            }

            if (originalData!.discountDetails != null &&
                originalData!.discountDetails!.isNotEmpty) {
              final itemDiscountDetail = originalData!.discountDetails!
                  .firstWhere(
                    (discount) =>
                        discount['itmLineNo'] == modelDetail['itemLineNo'],
                    orElse: () => <String, dynamic>{},
                  );
              if (itemDiscountDetail.isNotEmpty) {
                discountCode = itemDiscountDetail['discountCode'];

                // Check the original discount type from discount details
                final originalDiscountType = itemDiscountDetail['discountType'];
                if (originalDiscountType == 'Percentage') {
                  discountType = "Percentage";
                  discountPercentage =
                      itemDiscountDetail['discountValue']?.toDouble();
                } else if (originalDiscountType == 'Value' &&
                    discountAmount! > 0) {
                  discountType = "Value";
                  final basicAmount =
                      (modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0) *
                      (modelDetail['qtySUOM']?.toDouble() ?? 0.0);
                }
              }
            }

            // Get rate structure details for this item
            final itemRateStructureDetails =
                originalData!.rateStructureDetails
                    ?.where((rs) => rs['lineNo'] == modelDetail['itemLineNo'])
                    .toList() ??
                [];

            // Calculate tax amount from rate structure details
            double taxAmount = 0.0;
            for (final rsDetail in itemRateStructureDetails) {
              taxAmount += (rsDetail['rateAmount']?.toDouble() ?? 0.0);
            }

            // Calculate correct total amount using the same logic as ad_qote.dart
            final basicAmount =
                (modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0) *
                (modelDetail['qtySUOM']?.toDouble() ?? 0.0);
            final netAmount = basicAmount - discountAmount;
            final totalAmount = netAmount + taxAmount;

            final item = QuotationItem(
              itemName: modelDetail['salesItemDesc'] ?? '',
              itemCode: modelDetail['salesItemCode'] ?? '',
              qty: modelDetail['qtySUOM']?.toDouble() ?? 0.0,
              basicRate: modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0,
              uom: modelDetail['uom'] ?? 'NOS',
              discountType: discountType,
              discountPercentage: discountPercentage,
              discountAmount: discountAmount! > 0 ? discountAmount : null,
              discountCode: discountCode, // Include discount code from API data
              rateStructure: modelDetail['rateStructureCode'] ?? '',
              taxAmount: taxAmount,
              totalAmount: totalAmount,
              rateStructureRows:
                  itemRateStructureDetails.isNotEmpty
                      ? List<Map<String, dynamic>>.from(
                        itemRateStructureDetails,
                      )
                      : null,
              lineNo: modelDetail['itemLineNo'] ?? (i + 1),
              hsnCode: modelDetail['hsnCode'] ?? '',
              isFromInquiry: (quotationDetail['inquiryId'] ?? 0) > 0,
            );

            items.add(item);
          }
        }

        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading quotation: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBlockedFormUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.web, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Form Submission Required from Website',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'This quotation requires technical specifications that can only be submitted through the website. Please use the web portal to create this quotation.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
      customerController.text = customer.customerName;
      selectedSalesman = _findSalesmanForCustomer(customer);
    });

    // Load inquiry list if quotation base is "I"
    if (selectedQuotationBase?.code == "I") {
      inquiryList = await _service.fetchInquiryList(customer.customerCode);
      setState(() {});
    }
  }

  Future<void> _onBillToSelected(Customer customer) async {
    setState(() {
      selectedBillToCustomer = customer;
      billToController.text = customer.customerName;
    });

    // Reload inquiry list if quotation base is "I" and we have a customer
    if (selectedQuotationBase?.code == "I" && selectedCustomer != null) {
      inquiryList = await _service.fetchInquiryList(
        selectedCustomer!.customerCode,
      );
      setState(() {});
    }
  }

  Salesman _findSalesmanForCustomer(Customer customer) {
    return salesmanList.firstWhere(
      (s) => s.salesmanCode == customer.customerCode,
      orElse:
          () =>
              salesmanList.isNotEmpty
                  ? salesmanList.first
                  : selectedSalesman ??
                      Salesman(
                        salesmanCode: '',
                        salesmanName: '',
                        salesManFullName: 'Not Assigned',
                      ),
    );
  }

  Future<void> _onInquirySelected(Inquiry? inquiry) async {
    if (inquiry == null) return;

    setState(() {
      selectedInquiry = inquiry;
      items.clear(); // Clear existing items
    });

    // Fetch inquiry details and populate items
    final detail = await _service.fetchInquiryDetail(inquiry.inquiryId);
    if (detail != null && detail['itemDetails'] != null) {
      inquiryDate =
          DateTime.tryParse(detail['inquiryDetails'][0]['inquiryDate'] ?? '') ??
          DateTime.now();
      int lineNo = 1;
      for (final item in detail['itemDetails']) {
        // Calculate discount details
        String discountType = "None";
        double? discountPercentage;
        double? discountAmount;

        if (item['discountDetails'] != null &&
            item['discountDetails'].isNotEmpty &&
            (item['discountDetails'][0]['discountValue'] ?? 0) > 0) {
          final discValue =
              (item['discountDetails'][0]['discountValue'] ?? 0).toDouble();
          final discType = item['discountDetails'][0]['discountType'] ?? '';

          if (discType == 'P') {
            discountType = 'Percentage';
            discountPercentage = discValue;
            discountAmount =
                ((item['basicPriceSUOM'] ?? 0).toDouble() *
                    (item['qtySUOM'] ?? 0).toDouble()) *
                (discValue / 100);
          } else {
            discountType = 'Value';
            discountAmount = discValue;
            final basicAmount =
                (item['basicPriceSUOM'] ?? 0).toDouble() *
                (item['qtySUOM'] ?? 0).toDouble();
            discountPercentage =
                basicAmount > 0 ? (discValue / basicAmount) * 100 : 0;
          }
        }

        // Calculate tax amount
        double taxAmount = 0.0;
        if (item['rateStructureDetails'] != null) {
          for (final rsDetail in item['rateStructureDetails']) {
            taxAmount += (rsDetail['rateAmount'] ?? 0).toDouble();
          }
        }

        items.add(
          QuotationItem(
            itemName: item['salesItemDesc'] ?? '',
            itemCode: item['salesItemCode'] ?? '',
            qty: (item['qtySUOM'] ?? 0).toDouble(),
            basicRate: (item['basicPriceSUOM'] ?? 0).toDouble(),
            uom: item['uom'] ?? 'NOS',
            discountType: discountType,
            discountPercentage: discountPercentage,
            discountAmount: discountAmount,
            rateStructure: item['rateStructureCode'] ?? '',
            taxAmount: taxAmount,
            totalAmount: (item['basicAmount'] ?? 0).toDouble(),
            rateStructureRows:
                item['rateStructureDetails'] != null
                    ? List<Map<String, dynamic>>.from(
                      item['rateStructureDetails'],
                    )
                    : null,
            lineNo: lineNo,
            hsnCode: item['hsnCode'] ?? '',
            isFromInquiry: true,
          ),
        );
        lineNo++;
      }
    }
    setState(() {});
  }

  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<QuotationItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemPage(
              rateStructures: rateStructures,
              service: _service,
              existingItems: items,
              isDuplicateAllowed: _isDuplicateAllowed,
            ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    if (result != null) {
      setState(() {
        result.lineNo = items.length + 1;
        items.add(result);
      });
    }
  }

  Future<void> _showEditItemPage(QuotationItem item, int index) async {
    // Create a list of existing items excluding the one being edited
    final existingItemsForEdit = List<QuotationItem>.from(items);
    existingItemsForEdit.removeAt(index);

    final result = await Navigator.push<QuotationItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditItemPage(
              rateStructures: rateStructures,
              item: item,
              service: _service,
              existingItems: existingItemsForEdit,
              isDuplicateAllowed: _isDuplicateAllowed,
            ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    if (result != null) {
      setState(() {
        // Update the item at the specific index
        items[index] = result;
        // Ensure line numbers are correct
        for (int i = 0; i < items.length; i++) {
          items[i].lineNo = i + 1;
        }
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

  // Use the exact same calculation methods as ad_qote.dart
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
        _newAttachments.addAll(result.files);
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      attachments.removeAt(index);
    });
  }

  void _removeNewAttachment(int index) {
    setState(() {
      _newAttachments.removeAt(index);
    });
  }

  void _markAttachmentForDeletion(int index) {
    setState(() {
      _editableAttachments[index]['action'] = 'delete';
    });
  }

  void _undoAttachmentDeletion(int index) {
    setState(() {
      _editableAttachments[index]['action'] = 'none';
      _editableAttachments[index]['replacementFile'] = null;
    });
  }

  Future<void> _replaceAttachment(int index) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _editableAttachments[index]['action'] = 'replace';
        _editableAttachments[index]['replacementFile'] = result.files.first;
      });
    }
  }

  // Attachment API helpers using existing service
  Future<bool> _deleteAttachment(Map<String, dynamic> attachment) async {
    final baseUrl = 'http://${await StorageUtils.readValue('url')}';
    final docYear = _financeDetails?['financialYear'] ?? "";

    return await _attachmentService.deleteAttachment(
      baseUrl: baseUrl,
      docYear: docYear,
      documentNo: _documentNo ?? '',
      formId: "06103",
      deletedFileList: [
        {"sysFileName": attachment['sysFileName'], "id": attachment['id']},
      ],
    );
  }

  Future<bool> _uploadNewAttachments() async {
    if (_newAttachments.isEmpty) return true;

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final companyId = companyDetails['id'];
      final companyCode = companyDetails['code'];
      final locationCode = locationDetails['code'];
      final locationId = locationDetails['id'];
      final docYear = _financeDetails?['financialYear'] ?? "";
      final userId = _service.tokenDetails['user']['id'] ?? 0;

      // Get file paths from PlatformFile objects
      final filePaths =
          _newAttachments
              .where((file) => file.path != null)
              .map((file) => file.path!)
              .toList();

      if (filePaths.isEmpty) return true;
      final response = await _attachmentService.uploadAttachments(
        filePaths: filePaths,
        documentNo: _documentNo ?? '',
        documentId:
            originalData?.quotationDetails?.first['quotationId']?.toString() ??
            '',
        docYear: docYear,
        formId: "06103",
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: locationId,
        companyId: companyId,
        userId: userId,
      );
      if (response == true) {
        return true;
      } else {
        debugPrint('Failed to upload new attachments');
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading new attachments: $e');
      return false;
    }
  }

  Future<bool> _uploadSingleFile(PlatformFile file) async {
    if (file.path == null) return false;

    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      final locationDetails = await StorageUtils.readJson('selected_location');
      final companyId = companyDetails['id'];
      final companyCode = companyDetails['code'];
      final locationCode = locationDetails['code'];
      final locationId = locationDetails['id'];
      final docYear = _financeDetails?['financialYear'] ?? "";
      final userId = _service.tokenDetails['user']['id'] ?? 0;

      return await _attachmentService.uploadAttachments(
        filePaths: [file.path!],
        documentNo: _documentNo ?? '',
        documentId:
            originalData?.quotationDetails?.first['quotationId']?.toString() ??
            '',
        docYear: docYear,
        formId: "06103",
        locationCode: locationCode,
        companyCode: companyCode,
        locationId: locationId,
        companyId: companyId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error uploading single file: $e');
      return false;
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
      modelDetail['customerCode'] = selectedCustomer?.customerCode ?? "";
      modelDetail['quotationOrderNumber'] = widget.quotationNumber;
      modelDetail['amendmentSrNo'] = _amendmentSrNo;
      modelDetails.add(modelDetail);

      final discountDetail = item.toDiscountDetail();
      if (discountDetail.isNotEmpty) {
        discountDetail['amendSrNo'] = _amendmentSrNo;
        discountDetails.add(discountDetail);
      }

      //rateStructureDetails.addAll(item.toRateStructureDetails());
      final rateStructureDetailsList = item.toRateStructureDetails();
      for (final rsDetail in rateStructureDetailsList) {
        // Add amendment serial number to rate structure details
        rsDetail['amendSrNo'] = _amendmentSrNo;
        rateStructureDetails.add(rsDetail);
      }
    }

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAfterDiscount = totalBasic - totalDiscount;
    final finalAmount = totalAfterDiscount + totalTax;

    // Get original quotation details
    final originalQuotationDetail = originalData?.quotationDetails?.first;

    return {
      "authorizationRequired":
          documentDetail?.isAutorisationRequired == true ? "Y" : "N",
      "autoNumberRequired":
          documentDetail?.isAutoNumberGenerated == true ||
                  documentDetail?.isAutoNumberGenerated == 'true' ||
                  documentDetail?.isAutoNumberGenerated == 1
              ? "Y"
              : "N",
      "siteRequired": documentDetail?.isLocationRequired == true ? "Y" : "N",
      "authorizationDate": FormatUtils.formatDateForApi(
        selectedDate ?? DateTime.now(),
      ),
      "fromLocationId": locationId,
      "userId": userId,
      "companyId": companyId,
      "fromLocationCode": locationCode,
      "fromLocationName": _service.locationDetails['name'] ?? "",
      "ip": "",
      "mac": "",
      "domesticCurrencyCode": currency,
      "quotationDetails": {
        "customerCode": selectedCustomer?.customerCode ?? "",
        "quotationYear":
            originalQuotationDetail?['quotationYear'] ?? widget.quotationYear,
        "quotationGroup":
            originalQuotationDetail?['quotationGroup'] ?? widget.quotationGrp,
        "quotationNumber": widget.quotationNumber ?? 0,
        "quotationDate": FormatUtils.formatDateForApi(
          selectedDate ?? DateTime.now(),
        ),
        "salesPersonCode": selectedSalesman?.salesmanCode ?? "",
        "validity": originalQuotationDetail?['validity'] ?? "30",
        "attachFlag": "",
        "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "exchangeRate": _exchangeRate ?? 1.0,
        "discountType": "None",
        "discountAmount": 0,
        "modValue": 0,
        "subject": subjectController.text,
        "kindAttentionName": "",
        "kindAttentionDesignation": "",
        "destination": "",
        "authorizedSignatoryName": "",
        "authorizedSignatoryDesignation": "",
        "customerInqRefNo": "",
        "customerInqRefDate": "",
        "customerName": selectedCustomer?.customerName ?? "",
        "inquiryDate":
            inquiryDate != null
                ? FormatUtils.formatDateForApi(inquiryDate!)
                : null,
        "quotationSiteId":
            originalQuotationDetail?['quotationSiteId'] ?? locationId,
        "quotationSiteCode": locationCode,
        "quotationId": originalQuotationDetail?['quotationId'] ?? 0,
        "inquiryId":
            selectedInquiry?.inquiryId ??
            originalQuotationDetail?['inquiryId'] ??
            0,
        "quotationTypeSalesOrder": "REG",
        "ProjectItemId": 0,
        "ProjectItemCode": "",
        "isAgentAssociated": false,
        "projectName": "",
        "contactEmail": "",
        "contactNo": "",
        "submittedDate": null,
        "isBudgetaryQuotation": false,
        "quotationStatus": "",
        "QuotationAmendDate":
            originalQuotationDetail!['quotationAmendDate'] ??
            originalQuotationDetail['QuotationAmendDate'] ??
            "",
        "currencyCode": currency,
        "agentCode": "",
        "quotationTypeConfig":
            originalQuotationDetail?['quotationTypeConfig'] ?? "",
        "reasonCode": "",
        "consultantCode": "",
        "billToCustomerCode": selectedBillToCustomer?.customerCode ?? "",
        "amendmentSrNo":
            originalQuotationDetail?['amendmentSrNo'] ??
            originalQuotationDetail['amendSrNo'] ??
            _amendmentSrNo ??
            0,
        "xqdbookcd": "",
      },
      "modelDetails": modelDetails,
      "discountDetails": discountDetails,
      "rateStructureDetails": rateStructureDetails,
      "historyDetails": [],
      "noteDetails": [],
      "equipmentAttributeDetails": [],
      "addOnDetails": [],
      "subItemDetails": [],
      "standardTerms": [],
      "quotationRemarks": [],
      "msctechspecifications": msctechspecifications,
      "mscSameItemAllowMultitimeFlag": _isDuplicateAllowed,
    };
  }

  Future<void> _updateQuotation() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCustomer == null) {
      _showError("Please select a customer");
      return;
    }
    if (selectedBillToCustomer == null) {
      _showError("Please select Bill To customer");
      return;
    }
    if (selectedSalesman == null) {
      _showError("Please select a salesman");
      return;
    }
    if (subjectController.text.isEmpty) {
      _showError("Please enter subject");
      return;
    }
    if (selectedQuotationBase?.code == "I" && selectedInquiry == null) {
      _showError("Please select Lead Number");
      return;
    }
    if (items.isEmpty) {
      _showError("Please add at least one item");
      return;
    }

    // Step 1: Check location status before starting submission
    final locationStatus = await LocationUtils.instance.checkLocationStatus();

    if (locationStatus != LocationStatus.granted) {
      final shouldContinue = await LocationUtils.instance.showLocationDialog(
        context,
        locationStatus,
      );

      if (!shouldContinue) {
        return;
      }

      // Re-check location status after user interaction
      final newStatus = await LocationUtils.instance.checkLocationStatus();
      if (newStatus != LocationStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location access is required to update the quotation',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Step 2: Get current location
    setState(() => _submitting = true);

    final position = await LocationUtils.instance.getCurrentLocation();
    if (position == null) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Please try again.'),
          // backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final payload = _buildUpdatePayload();
      final response = await _service.updateQuotation(payload);

      if (response['success'] == true) {
        // Handle attachments in background
        bool attachmentSuccess = true;
        String attachmentErrors = '';
        // Step 3: Submit location and handle attachments with proper error handling
        bool locationSuccess = true;

        List<String> errorMessages = [];

        // Extract function ID for location submission
        String? functionId =
            originalData?.quotationDetails?.first['quotationId']?.toString();

        // Submit location if we have the function ID
        if (functionId != null) {
          try {
            locationSuccess = await _service.submitLocation(
              functionId: functionId,
              longitude: position.longitude,
              latitude: position.latitude,
            );

            // if (!locationSuccess) {
            //   errorMessages.add('Location update failed');
            // }
          } catch (e) {
            debugPrint('Location submission error: $e');
            locationSuccess = false;
            // errorMessages.add('Location update failed: $e');
          }
        } else {
          locationSuccess = false;
          // errorMessages.add(
          //   'Unable to get function ID for location submission',
          // );
        }

        // Handle existing attachment deletions
        for (final attEdit in _editableAttachments) {
          if (attEdit['action'] == 'delete') {
            final success = await _deleteAttachment(attEdit['original']);
            if (!success) {
              attachmentSuccess = false;
              final fileName =
                  attEdit['original']['name'] ??
                  attEdit['original']['originalName'] ??
                  attEdit['original']['fileName'] ??
                  'Unknown File';
              attachmentErrors += 'Failed to delete $fileName\n';
            }
          } else if (attEdit['action'] == 'replace') {
            // First delete the original
            final deleteSuccess = await _deleteAttachment(attEdit['original']);
            if (deleteSuccess && attEdit['replacementFile'] != null) {
              // Then upload the replacement
              final uploadSuccess = await _uploadSingleFile(
                attEdit['replacementFile'],
              );
              if (!uploadSuccess) {
                attachmentSuccess = false;
                final fileName =
                    attEdit['original']['name'] ??
                    attEdit['original']['originalName'] ??
                    attEdit['original']['fileName'] ??
                    'Unknown File';
                attachmentErrors +=
                    'Failed to upload replacement for $fileName\n';
              }
            } else {
              attachmentSuccess = false;
              final fileName =
                  attEdit['original']['name'] ??
                  attEdit['original']['originalName'] ??
                  attEdit['original']['fileName'] ??
                  'Unknown File';
              attachmentErrors += 'Failed to replace $fileName\n';
            }
          }
        }

        // Handle new attachments
        final newAttachmentSuccess = await _uploadNewAttachments();
        if (!newAttachmentSuccess) {
          attachmentSuccess = false;
          // attachmentErrors += 'Failed to upload some new attachments\n';
        }

        if (!mounted) return;
        setState(() => _submitting = false);

        if (attachmentSuccess) {
          _showSuccess("Quotation updated successfully");
        } else {
          // _showError(
          //   "Quotation updated but some attachment operations failed:\n$attachmentErrors",
          // );
          debugPrint(
            "Quotation updated but some attachment operations failed:\n$attachmentErrors",
          );
        }

        Navigator.pop(context, true);
      } else {
        setState(() => _submitting = false);
        _showError("Failed to update quotation");
      }
    } catch (e) {
      // _showError("Error during update: ${e.toString()}");
      _showError("Failed to update quotation");
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
    dateController.dispose();
    customerController.dispose();
    billToController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Quotation #${widget.quotationNumber}"),
        elevation: 1,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _shouldBlockForm
              ? _buildBlockedFormUI()
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuotationInfoCard(),
                      const SizedBox(height: 16),
                      _buildQuotationBaseDropdown(),
                      const SizedBox(height: 16),
                      _buildDateField(),
                      const SizedBox(height: 16),
                      _buildCustomerField(),
                      const SizedBox(height: 16),
                      _buildBillToField(),
                      const SizedBox(height: 16),
                      _buildSalesmanDropdown(),
                      const SizedBox(height: 16),
                      _buildSubjectField(),
                      const SizedBox(height: 16),
                      if (selectedQuotationBase?.code == "I") ...[
                        _buildInquiryDropdown(),
                        const SizedBox(height: 16),
                      ],
                      if (items.isNotEmpty) ...[
                        _buildItemsList(),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildQuotationInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quotation Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text("Number: ${widget.quotationNumber}"),
            Text("Year: ${widget.quotationYear}"),
            if (originalData?.inquiryNumber.isNotEmpty == true)
              Text("Inquiry: ${originalData!.inquiryNumber}"),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationBaseDropdown() {
    return DropdownButtonFormField<QuotationBase>(
      decoration: const InputDecoration(
        labelText: "Quotation Base",
        border: OutlineInputBorder(),
      ),
      value: selectedQuotationBase,
      items:
          quotationBases
              .map(
                (base) => DropdownMenuItem<QuotationBase>(
                  value: base,
                  child: Text(
                    base.name,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              )
              .toList(),
      onChanged: null,
      validator: (val) => val == null ? "Quotation Base is required" : null,
    );
  }

  // Widget _buildDateField() {
  //   return TextFormField(
  //     controller: dateController,
  //     decoration: const InputDecoration(
  //       labelText: "Date",
  //       suffixIcon: Icon(Icons.calendar_today),
  //       border: OutlineInputBorder(),
  //     ),
  //     readOnly: true,
  //     enabled: !_submitting,
  //     onTap:
  //         _submitting
  //             ? null
  //             : () async {
  //               final picked = await showDatePicker(
  //                 context: context,
  //                 initialDate: selectedDate ?? DateTime.now(),
  //                 firstDate: startDate ?? DateTime(2000),
  //                 lastDate: endDate ?? DateTime.now(),
  //               );
  //               if (picked != null) {
  //                 setState(() {
  //                   selectedDate = picked;
  //                   dateController.text = FormatUtils.formatDateForUser(picked);
  //                 });
  //               }
  //             },
  //     validator:
  //         (val) => val == null || val.isEmpty ? "Date is required" : null,
  //   );
  // }
  Widget _buildDateField() {
    return TextFormField(
      controller: dateController,
      decoration: const InputDecoration(
        labelText: "Date",
        suffixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: !_submitting,
      onTap:
          _submitting
              ? null
              : () async {
                // Parse the period dates
                DateTime periodStartDate = DateTime.parse(
                  _financeDetails!['periodSDt'],
                );
                DateTime periodEndDate = DateTime.parse(
                  _financeDetails!['periodEDt'],
                );
                DateTime today = DateTime.now();

                // Determine the date range
                DateTime startDate = periodStartDate;
                DateTime endDate =
                    today.isBefore(periodEndDate) ||
                            today.isAtSameMomentAs(periodEndDate)
                        ? today
                        : periodEndDate;

                // Set initial date to today if it's within range, otherwise use the end date
                DateTime initialDate =
                    today.isAfter(startDate) &&
                            (today.isBefore(endDate) ||
                                today.isAtSameMomentAs(endDate))
                        ? today
                        : endDate;

                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: startDate,
                  lastDate: endDate,
                );

                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    dateController.text = FormatUtils.formatDateForUser(picked);
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
          enabled: false,
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
      onSelected:
          _submitting
              ? null
              : (customer) {
                _onCustomerSelected(customer);
                // Remove focus after selection
                FocusScope.of(context).unfocus();
              },
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
      onSelected:
          _submitting
              ? null
              : (customer) {
                _onBillToSelected(customer);
                // Remove focus after selection
                FocusScope.of(context).unfocus();
              },
    );
  }

  Widget _buildSalesmanDropdown() {
    return DropdownButtonFormField<Salesman>(
      decoration: const InputDecoration(
        labelText: "Salesman",
        border: OutlineInputBorder(),
      ),
      value: selectedSalesman,
      isExpanded: true,
      items:
          salesmanList
              .map(
                (s) => DropdownMenuItem<Salesman>(
                  value: s,
                  child: Text(
                    s.salesManFullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged:
          _submitting
              ? null
              : (val) {
                setState(() {
                  selectedSalesman = val;
                });
              },
      validator: (val) => val == null ? "Salesman is required" : null,
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: subjectController,
      enabled: !_submitting,
      decoration: const InputDecoration(
        labelText: "Subject",
        border: OutlineInputBorder(),
      ),
      validator:
          (val) => val == null || val.isEmpty ? "Subject is required" : null,
    );
  }

  Widget _buildInquiryDropdown() {
    return DropdownButtonFormField<Inquiry>(
      decoration: const InputDecoration(
        labelText: "Lead Number",
        border: OutlineInputBorder(),
      ),
      value: selectedInquiry,
      isExpanded: true,
      items:
          inquiryList
              .map(
                (inq) => DropdownMenuItem<Inquiry>(
                  value: inq,
                  child: Text(
                    "${inq.inquiryNumber} - ${inq.customerName}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              )
              .toList(),
      onChanged: null,
      validator: (val) => val == null ? "Lead Number is required" : null,
    );
  }

  Widget _buildAddItemButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _showAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text("Add New Item"),
      ),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          _submitting
                              ? null
                              : () => _showEditItemPage(item, index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _submitting ? null : () => _removeItem(index),
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

  Widget _buildTotalCard() {
    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final netAmount = totalBasic - totalDiscount;
    final finalAmount = netAmount + totalTax;

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
                Text("₹${totalBasic.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Discount Value:"),
                Text("₹${totalDiscount.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Net Amount:"),
                Text("₹${netAmount.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tax Amount:"),
                Text("₹${totalTax.toStringAsFixed(2)}"),
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
                  "₹${finalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
          'Existing Attachments:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_editableAttachments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No existing attachments',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ..._editableAttachments.asMap().entries.map((entry) {
            final index = entry.key;
            final attEdit = entry.value;
            final original = attEdit['original'] as Map<String, dynamic>;
            final action = attEdit['action'] as String;
            final replacementFile = attEdit['replacementFile'] as PlatformFile?;

            // Get the correct file name from API response
            final fileName =
                original['name'] ??
                original['originalName'] ??
                original['fileName'] ??
                'Unknown File';

            // Get the correct file size
            final fileSize = original['size'];
            final fileSizeText =
                fileSize != null
                    ? '${(fileSize / 1024).toStringAsFixed(1)} KB'
                    : (original['fileSize'] ?? 'Unknown');

            if (action == 'delete') {
              return Card(
                color: Colors.red.shade50,
                child: ListTile(
                  title: Text(
                    fileName,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    'Marked for deletion',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.undo, color: Colors.green),
                    onPressed:
                        _submitting
                            ? null
                            : () => _undoAttachmentDeletion(index),
                    tooltip: 'Undo deletion',
                  ),
                ),
              );
            }

            return Card(
              color: action == 'replace' ? Colors.orange.shade50 : null,
              child: ListTile(
                title: Text(
                  action == 'replace' && replacementFile != null
                      ? replacementFile.name
                      : fileName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (action == 'replace' && replacementFile != null) ...[
                      Text(
                        'Replacing: $fileName',
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'New size: ${(replacementFile.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ] else ...[
                      Text(
                        'Size: $fileSizeText',
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (original['createdByName'] != null) ...[
                        Text(
                          'Uploaded by: ${original['createdByName']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (action == 'replace') ...[
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.green),
                        onPressed:
                            _submitting
                                ? null
                                : () => _undoAttachmentDeletion(index),
                        tooltip: 'Undo replacement',
                      ),
                    ] else ...[
                      IconButton(
                        icon: const Icon(
                          Icons.swap_horiz,
                          color: Colors.orange,
                        ),
                        onPressed:
                            _submitting
                                ? null
                                : () => _replaceAttachment(index),
                        tooltip: 'Replace file',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            _submitting
                                ? null
                                : () => _markAttachmentForDeletion(index),
                        tooltip: 'Delete file',
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

        const SizedBox(height: 16),
        const Text(
          'New Attachments:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_newAttachments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No new attachments added',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ..._newAttachments.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Card(
              color: Colors.green.shade50,
              child: ListTile(
                title: Text(file.name),
                subtitle: Text(
                  'Size: ${(file.size / 1024).toStringAsFixed(1)} KB',
                ),
                leading: const Icon(Icons.add_circle, color: Colors.green),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed:
                      _submitting ? null : () => _removeNewAttachment(index),
                  tooltip: 'Remove file',
                ),
              ),
            );
          }),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _pickFiles,
            icon: const Icon(Icons.attach_file),
            label: const Text('Add Attachment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _updateQuotation,
        child:
            _submitting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Update Quotation"),
      ),
    );
  }
}
