import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/pages/quotation/test/page/ad_itm.dart';
import 'package:nhapp/pages/quotation/test/page/edit_item.dart';
import 'package:nhapp/pages/quotation/test/service/qote_service.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:file_picker/file_picker.dart';

class AddQuotationPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AddQuotationPage({super.key, this.initialData});

  @override
  State<AddQuotationPage> createState() => _AddQuotationPageState();
}

class _AddQuotationPageState extends State<AddQuotationPage> {
  late QuotationService _service;
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
  bool _isLoading = true;
  bool _submitting = false;
  DateTime? startDate;
  DateTime? endDate;
  late Map<String, dynamic>? _financeDetails;
  bool _isDuplicateAllowed = false;
  late double _exchangeRate;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    _service = await QuotationService.create();
    await _loadFinancePeriod();
    await _loadQuotationBases();
    await _loadRateStructures();
    await _loadSalesmanList();
    await _loadDocumentDetail();
    await _loadSalesPolicy();
    await _getExchangeRate();

    // Prefill data if initial data is provided
    if (widget.initialData != null) {
      await _prefillData();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _prefillData() async {
    final data = widget.initialData!;

    try {
      // Set quotation base to Inquiry only if quotationBases is loaded
      if (quotationBases.isNotEmpty) {
        selectedQuotationBase = quotationBases.firstWhere(
          (base) => base.code == 'I',
          orElse: () => quotationBases.first,
        );
      }

      // Set customer data only if both customerCode and customerName are available
      if (data['customerCode'] != null &&
          data['customerCode'].toString().isNotEmpty &&
          data['customerName'] != null &&
          data['customerName'].toString().isNotEmpty) {
        selectedCustomer = Customer(
          customerCode: data['customerCode'].toString(),
          customerName: data['customerName'].toString(),
          telephoneNo: data['telephoneNo']?.toString() ?? '',
          gstNumber: data['gstNumber']?.toString() ?? '',
          customerFullName: data['customerName'].toString(),
        );
        customerController.text = data['customerName'].toString();

        // Set bill to customer as same as customer
        selectedBillToCustomer = selectedCustomer;
        billToController.text = data['customerName'].toString();
      }

      // Set salesman if available and salesmanList is loaded
      if (salesmanList.isNotEmpty &&
          data['salesmanCode'] != null &&
          data['salesmanCode'].toString().isNotEmpty) {
        final matchingSalesman = salesmanList.firstWhere(
          (s) => s.salesmanCode == data['salesmanCode'].toString(),
          orElse:
              () => Salesman(
                salesmanCode: '',
                salesmanName: '',
                salesManFullName: '',
              ),
        );

        if (matchingSalesman.salesmanCode.isNotEmpty) {
          selectedSalesman = matchingSalesman;
        }
      }

      // Load inquiry list and set the specific inquiry only if customer is set and quotation base is 'I'
      if (selectedCustomer != null && selectedQuotationBase?.code == 'I') {
        try {
          inquiryList = await _service.fetchInquiryList(
            selectedCustomer!.customerCode,
          );

          // Find and select the specific inquiry only if inquiryID is available
          if (data['inquiryID'] != null && data['inquiryID'] != 0) {
            final matchingInquiry = inquiryList.firstWhere(
              (inq) => inq.inquiryId == data['inquiryID'],
              orElse:
                  () => Inquiry(
                    inquiryId: 0,
                    inquiryNumber: '',
                    customerName: '',
                  ),
            );

            if (matchingInquiry.inquiryId != 0) {
              selectedInquiry = matchingInquiry;
              // Load inquiry details and populate items
              await _onInquirySelected(selectedInquiry);
            }
          }
        } catch (e) {
          debugPrint('Error loading inquiry list: $e');
          // Continue without inquiry data
        }
      }

      // Set a default subject with available data
      String subject = "Quotation";
      if (data['inquiryNumber'] != null &&
          data['inquiryNumber'].toString().isNotEmpty) {
        subject = "Quotation for Lead ${data['inquiryNumber']}";
      } else if (data['customerName'] != null &&
          data['customerName'].toString().isNotEmpty) {
        subject = "Quotation for ${data['customerName']}";
      }
      subjectController.text = subject;

      // Trigger UI update
      setState(() {});
    } catch (e) {
      debugPrint('Error in prefill data: $e');
      // Show error message but don't prevent form from loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Some data could not be prefilled: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _getExchangeRate() async {
    try {
      _exchangeRate = await _service.getExchangeRate() ?? 1.0;
    } catch (e) {
      debugPrint("Error loading exchange rate: $e");
      _exchangeRate = 1.0; // Default to 1.0 if there's an error
    }
  }

  Future<void> _loadSalesPolicy() async {
    try {
      final salesPolicy = await _service.getSalesPolicy();
      _isDuplicateAllowed =
          salesPolicy['allowduplictae'] ??
          salesPolicy['allowduplicate'] ??
          false;
    } catch (e) {
      debugPrint("Error loading sales policy: $e");
      _isDuplicateAllowed = false; // Default to not allowing duplicates
    }
  }

  Future<void> _loadFinancePeriod() async {
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails != null) {
      startDate = DateTime.parse(_financeDetails!['periodSDt']);
      endDate = DateTime.parse(_financeDetails!['periodEDt']);
      final now = DateTime.now();
      selectedDate = now.isAfter(endDate!) ? endDate : now;
      dateController.text = FormatUtils.formatDateForUser(selectedDate!);
    }
  }

  Future<void> _loadQuotationBases() async {
    quotationBases = await _service.fetchQuotationBaseList();
    if (quotationBases.isNotEmpty) {
      setState(() {
        selectedQuotationBase = quotationBases.first;
      });
    }
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

  Future<void> _onCustomerSelected(Customer customer) async {
    setState(() {
      selectedCustomer = customer;
      customerController.text = customer.customerName;
      billToController.text = customer.customerName;
      selectedBillToCustomer = customer;
      // Clear items and inquiry when customer changes
      items.clear();
      selectedInquiry = null;
      inquiryList.clear();
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
      // Clear inquiry and items when bill to changes
      selectedInquiry = null;
      inquiryList.clear();
      items.clear();
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
                  : Salesman(
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

  // Future<void> _showAddItemPage() async {
  //   final result = await Navigator.push<QuotationItem>(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) =>
  //               AddItemPage(rateStructures: rateStructures, service: _service),
  //     ),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       result.lineNo = items.length + 1;
  //       items.add(result);
  //     });
  //   }
  // }
  Future<void> _showAddItemPage() async {
    final result = await Navigator.push<QuotationItem>(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddItemPage(
              rateStructures: rateStructures,
              service: _service,
              existingItems: items, // Pass existing items
              isDuplicateAllowed: _isDuplicateAllowed, // Pass duplicate flag
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

  // Future<void> _showEditItemPage(QuotationItem item, int index) async {
  //   final result = await Navigator.push<QuotationItem>(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (context) => EditItemPage(
  //             rateStructures: rateStructures,
  //             item: item,
  //             service: _service,
  //           ),
  //     ),
  //   );
  //   if (result != null) {
  //     setState(() {
  //       items[index] = result;
  //       // Re-assign line numbers
  //       for (int i = 0; i < items.length; i++) {
  //         items[i].lineNo = i + 1;
  //       }
  //     });
  //   }
  // }
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
              existingItems:
                  existingItemsForEdit, // Pass filtered existing items
              isDuplicateAllowed: _isDuplicateAllowed, // Pass duplicate flag
            ),
      ),
    );
    if (result != null) {
      setState(() {
        items[index] = result;
        // Re-assign line numbers
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

  Map<String, dynamic> _buildSubmissionPayload() {
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
      // Update line number
      item.lineNo = i + 1;

      // Add model detail
      final modelDetail = item.toModelDetail();
      modelDetail['customerCode'] = selectedCustomer?.customerCode ?? "";
      modelDetails.add(modelDetail);

      // Add discount detail if applicable
      final discountDetail = item.toDiscountDetail();
      if (discountDetail.isNotEmpty) {
        discountDetails.add(discountDetail);
      }

      // Add rate structure details
      rateStructureDetails.addAll(item.toRateStructureDetails());
    }

    final totalBasic = _calculateTotalBasic();
    final totalDiscount = _calculateTotalDiscount();
    final totalTax = _calculateTotalTax();
    final totalAfterDiscount = totalBasic - totalDiscount;
    final finalAmount = totalAfterDiscount + totalTax;

    return {
      "authorizationRequired": "Y",
      "autoNumberRequired": "Y",
      "siteRequired": "Y",
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
      "domesticCurrencyCode": "INR",
      "quotationDetails": {
        "customerCode": selectedCustomer?.customerCode ?? "",
        "quotationYear": docYear,
        "quotationGroup": documentDetail?.groupCode ?? "QA",
        "quotationNumber": 0,
        "quotationDate": FormatUtils.formatDateForApi(
          selectedDate ?? DateTime.now(),
        ),
        "salesPersonCode": selectedSalesman?.salesmanCode ?? "",
        "validity": "30",
        "attachFlag": "",
        "totalAmounttAfterTaxDomesticCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterTaxCustomerCurrency": finalAmount.toStringAsFixed(2),
        "totalAmountAfterDiscountCustomerCurrency": totalAfterDiscount
            .toStringAsFixed(2),
        "exchangeRate": _exchangeRate ?? 1.0,
        "discountType": "None",
        "discountAmount": "0",
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
        "inquiryDate": null,
        "quotationSiteId": locationId.toString(),
        "quotationSiteCode": locationCode,
        "quotationId": 0,
        "inquiryId": selectedInquiry?.inquiryId ?? 0,
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
        "billToCustomerCode": selectedBillToCustomer?.customerCode ?? "",
        "amendmentSrNo": "0",
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
      "msctechspecifications": true,
      "mscSameItemAllowMultitimeFlag": true,
    };
  }

  // Future<void> _submitQuotation() async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (selectedCustomer == null) {
  //     _showError("Please select a customer");
  //     return;
  //   }
  //   if (selectedBillToCustomer == null) {
  //     _showError("Please select Bill To customer");
  //     return;
  //   }
  //   if (selectedSalesman == null) {
  //     _showError("Please select a salesman");
  //     return;
  //   }
  //   if (subjectController.text.isEmpty) {
  //     _showError("Please enter subject");
  //     return;
  //   }
  //   if (selectedQuotationBase?.code == "I" && selectedInquiry == null) {
  //     _showError("Please select Lead Number");
  //     return;
  //   }
  //   if (items.isEmpty) {
  //     _showError("Please add at least one item");
  //     return;
  //   }

  //   setState(() => _submitting = true);

  //   try {
  //     final payload = _buildSubmissionPayload();
  //     final response = await _service.submitQuotation(payload);

  //     if (response['success'] == true) {
  //       // Upload attachments if any
  //       if (attachments.isNotEmpty) {
  //         final quotationNumber =
  //             response['data']?['quotationDetails']?['quotationNumber']
  //                 ?.toString() ??
  //             "";
  //         final docYear = _financeDetails?['financialYear'] ?? "";

  //         if (quotationNumber.isNotEmpty) {
  //           final uploadSuccess = await _service.uploadAttachments(
  //             filePaths: attachments.map((f) => f.path!).toList(),
  //             documentNo: quotationNumber,
  //             documentId: "SQ",
  //             docYear: docYear,
  //             formId: "QUOTATION",
  //             locationCode: _service.locationDetails['code'] ?? "",
  //             companyCode: _service.companyDetails['code'] ?? "",
  //             locationId: _service.locationDetails['id'] ?? 0,
  //             companyId: _service.companyId,
  //             userId: _service.tokenDetails['user']['id'] ?? 0,
  //           );

  //           if (!uploadSuccess) {
  //             _showError("Quotation saved, but attachment upload failed!");
  //           }
  //         }
  //       }

  //       _showSuccess(response['message'] ?? "Quotation submitted successfully");
  //       // Ensure we return true to trigger refresh
  //       Navigator.pop(context, true);
  //     } else {
  //       _showError(response['errorMessage'] ?? "Failed to submit quotation");
  //     }
  //   } catch (e) {
  //     _showError("Error during submission: ${e.toString()}");
  //   } finally {
  //     setState(() => _submitting = false);
  //   }
  // }

  Future<void> _submitQuotation() async {
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

    setState(() => _submitting = true);

    try {
      final payload = _buildSubmissionPayload();
      final response = await _service.submitQuotation(payload);

      if (response['success'] == true) {
        // Upload attachments if any
        if (attachments.isNotEmpty) {
          final quotationNumber =
              response['data']?['quotationDetails']?['quotationNumber']
                  ?.toString() ??
              "";
          final quotationId =
              response['data']?['quotationDetails']?['quotationId'] ?? 0;
          final docYear = _financeDetails?['financialYear'] ?? "";

          if (quotationNumber.isNotEmpty) {
            final uploadSuccess = await _service.uploadAttachments(
              filePaths: attachments.map((f) => f.path!).toList(),
              documentNo: quotationNumber,
              documentId: quotationId.toString(),
              docYear: docYear,
              formId: 06103,
              groupCode: documentDetail?.groupCode ?? "QA",
              locationCode: _service.locationDetails['code'] ?? "",
              companyCode: _service.companyDetails['code'] ?? "",
              locationId: _service.locationDetails['id'] ?? 0,
              companyId: _service.companyId,
              userId: _service.tokenDetails['user']['id'] ?? 0,
            );

            if (!uploadSuccess) {
              _showError("Quotation saved, but attachment upload failed!");
            }
          }
        }

        _showSuccess(response['message'] ?? "Quotation submitted successfully");
        Navigator.pop(context, true);
      } else {
        _showError(response['errorMessage'] ?? "Failed to submit quotation");
      }
    } catch (e) {
      _showError("Error during submission: ${e.toString()}");
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
      appBar: AppBar(title: const Text("Add Quotation"), elevation: 1),
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
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  // Widget _buildQuotationBaseDropdown() {
  //   return DropdownButtonFormField<QuotationBase>(
  //     decoration: const InputDecoration(
  //       labelText: "Quotation Base",
  //       border: OutlineInputBorder(),
  //     ),
  //     value: selectedQuotationBase,
  //     items:
  //         quotationBases
  //             .map(
  //               (base) => DropdownMenuItem<QuotationBase>(
  //                 value: base,
  //                 child: Text(base.name),
  //               ),
  //             )
  //             .toList(),
  //     onChanged:
  //         _submitting
  //             ? null
  //             : (val) async {
  //               setState(() {
  //                 selectedQuotationBase = val;
  //                 // Clear fields below quotation base
  //                 items.clear();
  //                 selectedInquiry = null;
  //                 inquiryList.clear();
  //               });

  //               // Load inquiry list if "I" is selected and we have a customer
  //               if (val?.code == "I" && selectedCustomer != null) {
  //                 inquiryList = await _service.fetchInquiryList(
  //                   selectedCustomer!.customerCode,
  //                 );
  //                 setState(() {});
  //               }
  //             },
  //     validator: (val) => val == null ? "Quotation Base is required" : null,
  //   );
  // }
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
                  child: Text(base.name),
                ),
              )
              .toList(),
      onChanged:
          widget.initialData != null
              ? null // Disable when prefilled
              : _submitting
              ? null
              : (val) async {
                setState(() {
                  selectedQuotationBase = val;
                  items.clear();
                  selectedInquiry = null;
                  inquiryList.clear();
                });

                if (val?.code == "I" && selectedCustomer != null) {
                  inquiryList = await _service.fetchInquiryList(
                    selectedCustomer!.customerCode,
                  );
                  setState(() {});
                }
              },
      validator: (val) => val == null ? "Quotation Base is required" : null,
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
      enabled: !_submitting,
      onTap:
          _submitting
              ? null
              : () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: startDate ?? DateTime(2000),
                  lastDate: endDate ?? DateTime.now(),
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

  // Widget _buildCustomerField() {
  //   return TypeAheadField<Customer>(
  //     debounceDuration: const Duration(milliseconds: 400),
  //     controller: customerController,
  //     builder: (context, controller, focusNode) {
  //       return TextFormField(
  //         controller: controller,
  //         focusNode: focusNode,
  //         enabled: !_submitting,
  //         decoration: const InputDecoration(
  //           labelText: "Customer Name",
  //           border: OutlineInputBorder(),
  //         ),
  //         validator:
  //             (val) =>
  //                 val == null || val.isEmpty
  //                     ? "Customer Name is required"
  //                     : null,
  //       );
  //     },
  //     suggestionsCallback:
  //         _submitting
  //             ? (pattern) async => []
  //             : (pattern) async {
  //               if (pattern.length < 4) return [];
  //               try {
  //                 return await _service.fetchCustomerSuggestions(pattern);
  //               } catch (e) {
  //                 return [];
  //               }
  //             },
  //     itemBuilder: (context, suggestion) {
  //       return ListTile(
  //         title: Text(suggestion.customerName),
  //         subtitle: Text(suggestion.customerCode),
  //       );
  //     },
  //     onSelected: _submitting ? null : _onCustomerSelected,
  //   );
  // }
  Widget _buildCustomerField() {
    return TypeAheadField<Customer>(
      debounceDuration: const Duration(milliseconds: 400),
      controller: customerController,
      showOnFocus: widget.initialData != null ? false : true,
      builder: (context, controller, focusNode) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.initialData == null ? !_submitting : false,
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
          widget.initialData != null
              ? (pattern) async => []
              : _submitting
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
          widget.initialData != null
              ? null
              : _submitting
              ? null
              : _onCustomerSelected,
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

  Widget _buildSalesmanDropdown() {
    return DropdownButtonFormField<Salesman>(
      decoration: const InputDecoration(
        labelText: "Salesman",
        border: OutlineInputBorder(),
      ),
      value: selectedSalesman,
      items:
          salesmanList
              .map(
                (s) => DropdownMenuItem<Salesman>(
                  value: s,
                  child: Text(s.salesManFullName),
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

  // Widget _buildInquiryDropdown() {
  //   return DropdownButtonFormField<Inquiry>(
  //     decoration: const InputDecoration(
  //       labelText: "Lead Number",
  //       border: OutlineInputBorder(),
  //     ),
  //     value: selectedInquiry,
  //     items:
  //         inquiryList
  //             .map(
  //               (inq) => DropdownMenuItem<Inquiry>(
  //                 value: inq,
  //                 child: Text("${inq.inquiryNumber} - ${inq.customerName}"),
  //               ),
  //             )
  //             .toList(),
  //     onChanged: _submitting ? null : _onInquirySelected,
  //     validator: (val) => val == null ? "Lead Number is required" : null,
  //   );
  // }
  Widget _buildInquiryDropdown() {
    return DropdownButtonFormField<Inquiry>(
      decoration: const InputDecoration(
        labelText: "Lead Number",
        border: OutlineInputBorder(),
      ),
      value: selectedInquiry,
      items:
          inquiryList
              .map(
                (inq) => DropdownMenuItem<Inquiry>(
                  value: inq,
                  child: Text("${inq.inquiryNumber} - ${inq.customerName}"),
                ),
              )
              .toList(),
      onChanged:
          widget.initialData != null
              ? null // Disable when prefilled
              : _submitting
              ? null
              : _onInquirySelected,
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
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _submitting ? null : _pickFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Add Attachment'),
            ),
            const SizedBox(width: 8),
            Text('${attachments.length} file(s) selected'),
          ],
        ),
        ...attachments.asMap().entries.map((entry) {
          final idx = entry.key;
          final file = entry.value;
          return ListTile(
            title: Text(file.name),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _submitting ? null : () => _removeAttachment(idx),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitQuotation,
        child:
            _submitting
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Text("Submit Quotation"),
      ),
    );
  }
}
