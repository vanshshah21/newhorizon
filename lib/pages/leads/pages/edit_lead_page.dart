import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:nhapp/pages/leads/pages/lead_details_page.dart';
import 'package:nhapp/utils/format_utils.dart';
import 'package:nhapp/utils/location_utils.dart';

import '../models/lead_data.dart';
import '../models/lead_form.dart';
import '../models/lead_attachment.dart';
import '../models/lead_attachment_edit.dart';
import '../services/lead_form_service.dart';
import '../services/lead_service.dart';
import '../services/lead_attachment_service.dart';
import 'package:nhapp/utils/storage_utils.dart';

class EditLeadPage extends StatefulWidget {
  final LeadData lead;
  const EditLeadPage({required this.lead, super.key});

  @override
  State<EditLeadPage> createState() => _EditLeadPageState();
}

class _EditLeadPageState extends State<EditLeadPage> {
  // Services
  final _formService = LeadFormService();
  final _leadService = LeadService();
  late final LeadAttachmentService _attachmentService;

  // Form and state
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _leadNumberController = TextEditingController();

  // Sales Item TypeAheadField controllers
  final TextEditingController _salesItemController = TextEditingController();
  final FocusNode _salesItemFocusNode = FocusNode();
  final SuggestionsController<SalesItemModel> _salesItemSuggestionsController =
      SuggestionsController<SalesItemModel>();

  // Dropdowns and data
  DateTime? _leadDate, _minDate, _maxDate;
  String? _year,
      _groupCode,
      _locationCode,
      _formId = "06100",
      _docYear,
      _documentNo;
  int? _siteId, _userId;
  bool? _isAutoNumberGenerated;
  String? _leadNumber;
  final DateTime _today = DateTime.now();

  late bool _isDuplicateItem;

  // Models
  CustomerModel? _selectedCustomer;
  SourceModel? _selectedSource;
  SalesmanModel? _selectedSalesman;
  RegionModel? _selectedRegion;
  final List<SourceModel> _sources = [];
  final List<SalesmanModel> _salesmen = [];
  final List<RegionModel> _regions = [];
  final List<LeadItemEntry> _items = [];
  final List<PlatformFile> _newAttachments = [];
  final List<LeadAttachmentEdit> _editableAttachments = [];

  // UI state
  bool _loading = true;
  bool _submitting = false;
  String? _customerError,
      _sourceError,
      _salesmanError,
      _regionError,
      _itemError,
      _leadDateError;

  @override
  void initState() {
    super.initState();
    _attachmentService = LeadAttachmentService(Dio());
    _customerController.addListener(_onCustomerTextChanged);
    _loadAllData();
  }

  void _onCustomerTextChanged() {
    if (_customerController.text != _selectedCustomer?.customerFullName) {
      setState(() {
        _selectedCustomer = null;
        _customerError = null;
      });
    }
  }

  // Date validation for Lead Date
  String? _validateLeadDate(DateTime? selectedDate) {
    if (selectedDate == null) {
      return 'Lead date is required';
    }

    if (selectedDate.isAfter(_today)) {
      return 'Lead date cannot be greater than today';
    }

    if (_minDate != null && selectedDate.isBefore(_minDate!)) {
      return 'Lead date cannot be before period start date';
    }

    if (_maxDate != null && selectedDate.isAfter(_maxDate!)) {
      return 'Lead date cannot be after period end date';
    }

    return null;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _pickLeadDate() async {
    final DateTime effectiveMaxDate =
        _maxDate != null && _maxDate!.isBefore(_today) ? _maxDate! : _today;

    DateTime initialDate = _leadDate ?? _today;
    if (initialDate.isAfter(effectiveMaxDate)) {
      initialDate = effectiveMaxDate;
    }
    if (_minDate != null && initialDate.isBefore(_minDate!)) {
      initialDate = _minDate!;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _minDate ?? DateTime(2000),
      lastDate: effectiveMaxDate,
    );

    if (picked != null) {
      final validationError = _validateLeadDate(picked);
      if (validationError != null) {
        _showSnackBar(validationError);
        return;
      }
      setState(() {
        _leadDate = picked;
        _leadDateError = null;
      });
    }
  }

  /// Loads all dropdowns, lead details, and attachments.
  Future<void> _loadAllData() async {
    try {
      setState(() => _loading = true);

      final baseUrl = 'http://${await StorageUtils.readValue('url')}';
      final locationDetail = await StorageUtils.readJson("selected_location");
      int siteId = locationDetail['id'] ?? 0;

      // Fetch dropdowns and date range
      final dateRange = await _formService.fetchDateRange(siteId);
      final year = dateRange['financialYear'] ?? '';
      final minDate =
          dateRange['periodSDt'] != null
              ? DateTime.parse(dateRange['periodSDt'])
              : DateTime.now();
      final maxDate =
          dateRange['periodEDt'] != null
              ? DateTime.parse(dateRange['periodEDt'])
              : DateTime.now();
      final docDetail = await _formService.fetchDefaultDocDetail(
        year: year,
        locationId: siteId,
      );
      final isAutoNumberGenerated = docDetail['isAutoNumberGenerated'] == true;
      final groupCode = docDetail['groupCode'] ?? '';
      final locationCode = docDetail['locationCode'] ?? '';
      final sources = await _formService.fetchSources();
      final salesmen = await _formService.fetchSalesmen();
      final regions = await _formService.fetchRegions();

      // Fetch lead details
      final detail = await _leadService.fetchLeadDetails(
        customerCode: widget.lead.customerCode,
        salesmanCode: widget.lead.salesmanCode,
        inquiryYear: widget.lead.inquiryYear,
        inquiryGroup: widget.lead.inquiryGroup,
        inquirySiteCode: widget.lead.locationCode,
        inquiryNumber: widget.lead.inquiryNumber,
        inquiryID: widget.lead.inquiryID,
      );

      // Build documentNo and docYear for attachment APIs
      final docYear = year;
      final documentNo =
          "$year/$groupCode/$locationCode/${detail.inquiryNumber}/LEADENTRY";
      final formId = _formId!;

      // Fetch attachments
      final attachments = await _attachmentService.fetchAttachments(
        baseUrl: baseUrl,
        documentNo: documentNo,
        formId: formId,
      );

      // Set all state
      setState(() {
        _leadDate = DateTime.tryParse(detail.inquiryDate) ?? DateTime.now();
        _minDate = minDate;
        _maxDate = maxDate;
        _year = year;
        _siteId = siteId;
        _userId = 2; // Replace with actual user id
        _isAutoNumberGenerated = isAutoNumberGenerated;
        _groupCode = groupCode;
        _locationCode = locationCode;
        _sources
          ..clear()
          ..addAll(sources);
        _salesmen
          ..clear()
          ..addAll(salesmen);
        _regions
          ..clear()
          ..addAll(regions);
        _selectedCustomer = CustomerModel(
          customerCode: detail.customerCode,
          customerName: detail.customerName,
          customerFullName: detail.customerFullName,
        );
        _customerController.text = detail.customerFullName;
        _selectedSource = _sources.firstWhere(
          (e) => e.code == detail.inquirySource,
          orElse: () => _sources.first,
        );
        _selectedSalesman = _salesmen.firstWhere(
          (e) => e.salesmanCode == detail.salesmanCode,
          orElse: () => _salesmen.first,
        );
        _selectedRegion = _regions.firstWhere(
          (e) => e.code == detail.salesRegionCode,
          orElse: () => _regions.first,
        );
        _items
          ..clear()
          ..addAll(
            detail.inqEntryItemModel.map(
              (item) => LeadItemEntry(
                item: SalesItemModel(
                  itemCode: item.salesItemCode,
                  itemName: item.itemName,
                  salesUOM: item.uom,
                  salesItemFullName: "${item.salesItemCode} - ${item.itemName}",
                ),
                qty: item.itemQty,
                rate: item.basicPrice,
              ),
            ),
          );
        _leadNumber = detail.inquiryNumber;
        _leadNumberController.text = detail.inquiryNumber;
        _editableAttachments
          ..clear()
          ..addAll(attachments.map((a) => LeadAttachmentEdit(original: a)));
        _formId = formId;
        _docYear = docYear;
        _documentNo = documentNo;
        _loading = false;
      });
      final salesPolicy = await _formService.getSalesPolicy();
      _isDuplicateItem =
          salesPolicy['allowduplictae'] ??
          salesPolicy['allowduplicate'] ??
          false;
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      });
      debugPrint('Error loading lead data: $e');
      debugPrint('StackTrace: $stackTrace');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // --- Attachment Management ---

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _newAttachments.addAll(result.files);
      });
    }
  }

  void _removeNewAttachment(int index) {
    setState(() {
      _newAttachments.removeAt(index);
    });
  }

  // --- Form Item Management ---

  // void _addItem(SalesItemModel item) {
  //   setState(() {
  //     _items.add(LeadItemEntry(item: item, qty: 1, rate: 0));
  //     _itemError = null;
  //   });
  // }
  void _addItem(SalesItemModel item) {
    setState(() {
      if (_isDuplicateItem ||
          !_items.any((entry) => entry.item.itemCode == item.itemCode)) {
        _items.add(LeadItemEntry(item: item, qty: 1, rate: 0));
        _itemError = null;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This item is already added.')),
        );
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  // --- Validation ---

  bool _validateItems() {
    if (_items.isEmpty) {
      setState(() => _itemError = 'Add at least one item');
      return false;
    }
    for (final item in _items) {
      if (item.qty <= 0) {
        setState(() => _itemError = 'Quantity must be greater than 0');
        return false;
      }
      if (item.rate <= 0) {
        setState(() => _itemError = 'Rate must be greater than 0');
        return false;
      }
    }
    setState(() => _itemError = null);
    return true;
  }

  bool _validateAll() {
    bool valid = true;
    setState(() {
      _customerError = _selectedCustomer == null ? 'Select a customer' : null;
      _sourceError = _selectedSource == null ? 'Select a source' : null;
      _salesmanError = _selectedSalesman == null ? 'Select a salesman' : null;
      _regionError = _selectedRegion == null ? 'Select a region' : null;
      _leadDateError = _validateLeadDate(_leadDate);
    });
    if (_customerError != null ||
        _sourceError != null ||
        _salesmanError != null ||
        _regionError != null ||
        _leadDateError != null) {
      valid = false;
    }
    if (!_validateItems()) valid = false;
    return valid;
  }

  // --- Attachment API Helpers ---

  Future<bool> _deleteAttachment(LeadAttachment att) async {
    final baseUrl = 'http://${await StorageUtils.readValue('url')}';
    return await _attachmentService.deleteAttachment(
      baseUrl: baseUrl,
      docYear: _docYear ?? _year ?? '',
      documentNo: _documentNo ?? '',
      formId: _formId ?? '06100',
      deletedFileList: [
        {"sysFileName": att.sysFileName, "id": att.id},
      ],
    );
  }

  Future<bool> _uploadAttachment(PlatformFile file) async {
    final baseUrl = 'http://${await StorageUtils.readValue('url')}';
    final companyDetails = await StorageUtils.readJson('selected_company');
    final locationDetails = await StorageUtils.readJson('selected_location');
    final companyId = companyDetails['id'];
    final companyCode = companyDetails['code'];
    final locationCode = locationDetails['code'];
    final locationId = locationDetails['id'];
    final docYear = _docYear!;
    final formId = _formId!;
    final documentNo =
        _documentNo ??
        "$docYear/${_groupCode ?? ''}/${_locationCode ?? ''}/${_leadNumber ?? ''}/LEADENTRY";
    final userId = _userId!;

    final formData = FormData();
    formData.fields.addAll([
      MapEntry("LocationID", locationId.toString()),
      MapEntry("CompanyID", companyId.toString()),
      MapEntry("CompanyCode", companyCode),
      MapEntry("LocationCode", locationCode),
      MapEntry("DocYear", docYear),
      MapEntry("FormID", formId),
      MapEntry("DocumentNo", documentNo),
      MapEntry("DocumentID", widget.lead.inquiryID.toString()),
      MapEntry("CreatedBy", userId.toString()),
    ]);
    formData.files.add(
      MapEntry(
        "AttachmentsFile",
        await MultipartFile.fromFile(file.path!, filename: file.name),
      ),
    );
    final dio = Dio();
    final tokenDetails = await StorageUtils.readJson('session_token');
    final token = tokenDetails['token']['value'];
    dio.options.headers = {
      'Authorization': 'Bearer $token',
      'companyid': companyId.toString(),
      'Accept': 'application/json',
    };
    final response = await dio.post(
      "$baseUrl/api/Lead/uploadAttachmentnew2",
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return response.statusCode == 200 && response.data['success'] == true;
  }

  // --- Submission ---

  Future<void> _submit() async {
    if (!_validateAll()) return;
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
            content: Text('Location access is required to update the lead'),
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
      // 1. Update lead entry
      final docDetail = await _formService.fetchDefaultDocDetail(
        year: _year!,
        locationId: _siteId!,
      );
      final isLocationRequired = docDetail['isLocationRequired'] ?? false;
      final isAutorisationRequired = docDetail['isAutorisationRequired'];
      final isAutoNumberGenerated = docDetail['isAutoNumberGenerated'];
      final locationCode = docDetail['locationCode'];
      final groupCode = docDetail['groupCode'];
      final companyCode = docDetail['companyCode'] ?? '';
      final formId = docDetail['formId'] ?? _formId;

      final baseUrl = 'http://${await StorageUtils.readValue('url')}';
      final companyDetails = await StorageUtils.readJson('selected_company');
      final tokenDetails = await StorageUtils.readJson('session_token');
      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      final body = {
        "InquiryId": widget.lead.inquiryID,
        "InquiryFMSiteId": _siteId,
        "UserID": _userId,
        "IsAutoNumberGenerated": isAutoNumberGenerated ? "Y" : "N",
        "SiteReq": isLocationRequired ? "Y" : "N",
        "IsAutorisationRequired": isAutorisationRequired,
        "XININQSTAT": null,
        "CompanyID": companyId,
        "LocationID": companyDetails['locationId'] ?? '',
        "InqEntryModel": {
          "InquiryID": widget.lead.inquiryID,
          "CustomerCode": _selectedCustomer!.customerCode,
          "CustomerName": _selectedCustomer!.customerName,
          "InquirySiteId": _siteId,
          "InquiryYear": _year,
          "InquiryGroup": groupCode,
          "InquiryNumber": _leadNumber,
          "InquiryDate": _leadDate!.toIso8601String(),
          "SalesmanCode": _selectedSalesman!.salesmanCode,
          "SalesRegionCode": _selectedRegion!.code,
          "InquirySource": _selectedSource!.code,
          "Remarks": null,
          "NextFollowup": null,
          "TenderNumber": null,
          "EMDRequiredDate": null,
          "EMDAmount": 0,
          "EMDEndDate": null,
          "InquiryRefNumber": null,
          "InquiryStatus": null,
          "SalesmanName": _selectedSalesman!.salesManFullName,
          "LocationCode": locationCode,
          "SalesRegionCodeDesc": _selectedRegion!.codeFullName,
          "SourceName": null,
          "CustomerContactID": 0,
          "ProjectItemID": 0,
          "InquiryType": null,
          "ItemCode": null,
          "ItemName": null,
          "ConsultantCode": null,
          "ConsultantName": null,
          "InqEntryItemModel":
              _items
                  .map(
                    (e) => {
                      "ModelNo": null,
                      "SalesItemCode": e.item.itemCode,
                      "UOM": e.item.salesUOM,
                      "ItemQty": e.qty,
                      "BasicPrice": e.rate,
                      "Application": null,
                      "PDO": null,
                      "InquiryStatus": null,
                      "XIMFUGID": null,
                      "CurrencyCode": null,
                      "ItemName": e.item.itemName,
                      "SalesItemType": null,
                      "Precision": null,
                      "CustomerPoItemSrNo": null,
                      "CustomerItemCode": null,
                      "CustomerItemName": null,
                      "LnNumber": 0,
                      "ApplicationCode": null,
                      "ProductSize": null,
                      "InvoiceType": null,
                      "AllowChange": false,
                      "DispatchWithoutMfg": false,
                    },
                  )
                  .toList(),
          "EquipmentAttributeDetails": [],
          "inqkndattControl": null,
        },
      };

      final dio = Dio();
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'companyid': companyId.toString(),
        'Authorization': 'Bearer $token',
      };

      final response = await dio.post(
        "$baseUrl/api/Lead/UpdateLeadEntry",
        data: body,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Step 4: Submit location and handle attachments with proper error handling
        bool locationSuccess = true;
        bool attachmentSuccess = true;

        List<String> errorMessages = [];

        // Extract function ID for location submission
        String? functionId = widget.lead.inquiryID.toString();

        // Submit location if we have the function ID
        if (functionId != null) {
          try {
            locationSuccess = await _formService.submitLocation(
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
        // 2. Handle attachments in background
        final List<Future> attachmentOps = [];

        for (final attEdit in _editableAttachments) {
          if (attEdit.action == AttachmentEditAction.delete) {
            attachmentOps.add(_deleteAttachment(attEdit.original));
          } else if (attEdit.action == AttachmentEditAction.replace) {
            attachmentOps.add(
              _deleteAttachment(attEdit.original).then((success) {
                if (success && attEdit.replacementFile != null) {
                  return _uploadAttachment(attEdit.replacementFile!);
                }
                return Future.value(false);
              }),
            );
          }
        }
        for (final file in _newAttachments) {
          attachmentOps.add(_uploadAttachment(file));
        }

        await Future.wait(attachmentOps);

        if (!mounted) return;
        setState(() => _submitting = false);
        try {
          final updatedLeadNumber = _leadNumber ?? widget.lead.inquiryNumber;
          if (updatedLeadNumber != null) {
            final leadDetails = await _formService.fetchLeadByNumber(
              leadNumber: updatedLeadNumber,
              userId: _userId ?? 2,
            );
            if (leadDetails != null && leadDetails.isNotEmpty) {
              final leadData = leadDetails.first;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lead updated successfully!')),
              );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => InquiryDetailsPage(lead: leadData),
                ),
              );
              return;
            }
          }
        } catch (e) {
          debugPrint('Error fetching updated lead details: $e');
        }
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Lead updated successfully!')),
        // );
        Navigator.of(context).pop(true);
      } else {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to update lead')));
      }
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update lead')));
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Lead')),
      body: AbsorbPointer(
        absorbing: _submitting,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- Lead Date ---
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Lead Date',
                  errorText: _leadDateError,
                ),
                child: InkWell(
                  onTap: _pickLeadDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _leadDate != null
                          ? FormatUtils.formatDateForUser(_leadDate)
                          : 'Select lead date',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Lead Number (read-only) ---
              TextFormField(
                controller: _leadNumberController,
                enabled: false,
                decoration: const InputDecoration(labelText: 'Lead Number'),
              ),
              const SizedBox(height: 16),

              // --- Customer Name (Typeahead) ---
              TypeAheadField<CustomerModel>(
                controller: _customerController,
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        errorText: _customerError,
                      ),
                      enabled: !_submitting,
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      onChanged: (val) {
                        if (_customerError != null && val.isNotEmpty) {
                          setState(() => _customerError = null);
                        }
                      },
                    ),
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 4) return [];
                  return await _formService.searchCustomers(pattern);
                },
                itemBuilder:
                    (context, suggestion) =>
                        ListTile(title: Text(suggestion.customerFullName)),
                onSelected: (suggestion) {
                  setState(() {
                    _selectedCustomer = suggestion;
                    _customerError = null;
                  });
                  _customerController.text = suggestion.customerFullName;
                },
                emptyBuilder: (context) => const SizedBox(),
              ),
              const SizedBox(height: 16),

              // --- Source of Lead ---
              DropdownButtonFormField<SourceModel>(
                decoration: InputDecoration(
                  labelText: 'Source of Lead',
                  errorText: _sourceError,
                ),
                value: _selectedSource,
                items:
                    _sources
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.codeFullName),
                          ),
                        )
                        .toList(),
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedSource = v;
                          if (_sourceError != null && v != null) {
                            _sourceError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // --- Salesman ---
              DropdownButtonFormField<SalesmanModel>(
                decoration: InputDecoration(
                  labelText: 'Salesman',
                  errorText: _salesmanError,
                ),
                value: _selectedSalesman,
                items:
                    _salesmen
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(
                              e.salesManFullName.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedSalesman = v;
                          if (_salesmanError != null && v != null) {
                            _salesmanError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // --- Sales Region ---
              DropdownButtonFormField<RegionModel>(
                decoration: InputDecoration(
                  labelText: 'Sales Region',
                  errorText: _regionError,
                ),
                value: _selectedRegion,
                items:
                    _regions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.codeFullName),
                          ),
                        )
                        .toList(),
                onChanged:
                    _submitting
                        ? null
                        : (v) => setState(() {
                          _selectedRegion = v;
                          if (_regionError != null && v != null) {
                            _regionError = null;
                          }
                        }),
                validator: (_) => null,
                autovalidateMode: AutovalidateMode.disabled,
              ),
              const SizedBox(height: 16),

              // --- Sales Item (Typeahead) ---
              // TypeAheadField<SalesItemModel>(
              //   controller: _salesItemController,
              //   focusNode: _salesItemFocusNode,
              //   suggestionsController: _salesItemSuggestionsController,
              //   builder:
              //       (context, controller, focusNode) => TextFormField(
              //         controller: controller,
              //         focusNode: focusNode,
              //         decoration: const InputDecoration(
              //           labelText: 'Sales Item',
              //           isDense: true,
              //           contentPadding: EdgeInsets.symmetric(
              //             vertical: 12,
              //             horizontal: 12,
              //           ),
              //         ),
              //         onTapOutside: (event) => FocusScope.of(context).unfocus(),
              //         enabled: !_submitting,
              //         maxLines: 1,
              //       ),
              //   suggestionsCallback: (pattern) async {
              //     if (pattern.length < 3) return [];
              //     return await _formService.searchSalesItems(pattern);
              //   },
              //   itemBuilder:
              //       (context, suggestion) => ListTile(
              //         title: Text(
              //           suggestion.salesItemFullName.trim(),
              //           maxLines: 1,
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //   onSelected: (suggestion) {
              //     final alreadyExists = _items.any(
              //       (item) => item.item.itemCode == suggestion.itemCode,
              //     );
              //     if (alreadyExists) {
              //       _showSnackBar('This sales item is already added.');
              //       return;
              //     }
              //     _addItem(suggestion);
              //     _salesItemController.clear();
              //   },
              //   emptyBuilder: (context) => const SizedBox(),
              //   decorationBuilder:
              //       (context, child) => Material(
              //         elevation: 4.0,
              //         borderRadius: BorderRadius.circular(8),
              //         child: child,
              //       ),
              //   direction: VerticalDirection.up,
              // ),
              TypeAheadField<SalesItemModel>(
                controller: _salesItemController,
                focusNode: _salesItemFocusNode,
                suggestionsController: _salesItemSuggestionsController,
                builder:
                    (context, controller, focusNode) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Sales Item',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 12,
                        ),
                      ),
                      onTapOutside: (event) => FocusScope.of(context).unfocus(),
                      enabled: !_submitting,
                      maxLines: 1,
                    ),
                suggestionsCallback: (pattern) async {
                  if (pattern.length < 3) return [];
                  final allItems = await _formService.searchSalesItems(pattern);

                  if (!_isDuplicateItem) {
                    // Filter out items that are already added
                    final addedItemCodes =
                        _items.map((entry) => entry.item.itemCode).toSet();
                    return allItems
                        .where(
                          (item) => !addedItemCodes.contains(item.itemCode),
                        )
                        .toList();
                  }

                  return allItems;
                },
                itemBuilder:
                    (context, suggestion) => ListTile(
                      title: Text(
                        suggestion.salesItemFullName.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                onSelected: (suggestion) {
                  _addItem(suggestion);
                  _salesItemController.clear();
                },
                emptyBuilder: (context) => const SizedBox(),
                decorationBuilder:
                    (context, child) => Material(
                      elevation: 4.0,
                      borderRadius: BorderRadius.circular(8),
                      child: child,
                    ),
                direction: VerticalDirection.up,
              ),
              const SizedBox(height: 8),

              // --- Items List ---
              if (_itemError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _itemError!,
                    style: const TextStyle(color: Colors.red),
                  ),
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
                              item.item.itemCode,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            Text(
                              item.item.itemName,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.qty.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                    ),
                                    onChanged:
                                        (v) => setState(
                                          () =>
                                              item.qty =
                                                  double.tryParse(v) ?? 0,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.item.salesUOM,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'UOM',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: item.rate.toString(),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Rate',
                                    ),
                                    onChanged:
                                        (v) => setState(
                                          () =>
                                              item.rate =
                                                  double.tryParse(v) ?? 0,
                                        ),
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
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => _removeItem(idx),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // --- Attachments Section ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Existing Attachments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._editableAttachments.asMap().entries.map((entry) {
                    final attEdit = entry.value;
                    final isReplaced =
                        attEdit.action == AttachmentEditAction.replace;
                    final isDeleted =
                        attEdit.action == AttachmentEditAction.delete;
                    if (isDeleted) {
                      return ListTile(
                        title: Text(
                          'To be deleted: ${attEdit.original.originalName}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.undo),
                          tooltip: 'Undo Delete',
                          onPressed:
                              () => setState(
                                () =>
                                    attEdit.action = AttachmentEditAction.none,
                              ),
                        ),
                      );
                    }
                    return ListTile(
                      title: Text(
                        isReplaced
                            ? 'Replaced: ${attEdit.replacementFile!.name}'
                            : attEdit.original.originalName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        isReplaced
                            ? 'Will replace ${attEdit.original.originalName}'
                            : 'Size: ${attEdit.original.size} bytes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isReplaced)
                            IconButton(
                              icon: const Icon(Icons.swap_horiz),
                              tooltip: 'Replace',
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(allowMultiple: false);
                                if (result != null && result.files.isNotEmpty) {
                                  setState(() {
                                    attEdit.action =
                                        AttachmentEditAction.replace;
                                    attEdit.replacementFile =
                                        result.files.first;
                                  });
                                }
                              },
                            ),
                          IconButton(
                            icon: Icon(isReplaced ? Icons.undo : Icons.delete),
                            tooltip: isReplaced ? 'Undo Replace' : 'Delete',
                            onPressed: () {
                              setState(() {
                                if (isReplaced) {
                                  attEdit.action = AttachmentEditAction.none;
                                  attEdit.replacementFile = null;
                                } else {
                                  attEdit.action = AttachmentEditAction.delete;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const Text(
                    'New Attachments:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ..._newAttachments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final file = entry.value;
                    return ListTile(
                      title: Text(file.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeNewAttachment(idx),
                      ),
                    );
                  }),
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add Attachment'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Submit Button ---
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child:
                    _submitting
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
