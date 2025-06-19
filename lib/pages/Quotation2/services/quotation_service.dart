// lib/services/quotation_form_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/Quotation2/models/add_quotation.dart';
import 'package:nhapp/pages/quotation/helper/quotation_helper.dart';
import 'package:nhapp/utils/storage_utils.dart';

class QuotationFormService {
  final Dio _dio = Dio();

  Map<String, dynamic>? defaultDocDetail;
  List<QuotationBase>? quotationBases;
  List<DiscountCode>? discountCodes;
  List<RateStructure>? rateStructures;
  List<Salesman>? salesmen;
  List<QuotationCustomer>? customers;

  QuotationFormService() {
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  Future<void> _setupHeaders() async {
    final baseUrl = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'companyid': companyId.toString(),
      'Authorization': 'Bearer $token',
    };

    _dio.options.baseUrl = 'http://$baseUrl';
  }

  /// Get company current year dates and finance period settings.
  Future<Map<String, dynamic>> fetchDateRange() async {
    try {
      final baseUrl = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails == null) throw Exception("Location not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final siteId = locationDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'companyid': companyId.toString(),
        'Authorization': 'Bearer $token',
      };

      _dio.options.baseUrl = 'http://$baseUrl';

      const endpoint = "/api/Login/GetCompanyCurrentYearDatesData";
      final response = await _dio.get(
        endpoint,
        queryParameters: {"companyid": companyId},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final periods = response.data['data']['financePeriodSetting'];
        final period = periods?.firstWhere(
          (e) => e['siteId'] == siteId,
          orElse: () => null,
        );
        if (period != null) {
          await StorageUtils.writeJson("current_financial_period", period);
          return period;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching date range: $e');
      throw Exception("Failed to fetch year dates: $e");
    }
  }

  /// Get default document details.
  Future<Map<String, dynamic>> fetchDefaultDocDetail({
    required String year,
  }) async {
    final baseUrl = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'companyid': companyId.toString(),
      'Authorization': 'Bearer $token',
    };

    _dio.options.baseUrl = 'http://$baseUrl';

    const endpoint = "/api/Lead/GetDefaultDocumentDetail";
    final response = await _dio.get(
      endpoint,
      queryParameters: {
        "year": year,
        "type": "SQ",
        "subType": "SQ",
        "locationId": locationId,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List && data.isNotEmpty) {
        defaultDocDetail = data.first as Map<String, dynamic>;
        return data.first as Map<String, dynamic>;
      }
    }
    debugPrint('Error fetching default document detail: ${response.data}');
    return {};
  }

  /// Fetch list for Quotation Base dropdown.
  Future<List<QuotationBase>> fetchQuotationBases() async {
    try {
      await _setupHeaders();
      const endpoint = "/api/Quotation/QuotationBaseList";
      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => QuotationBase.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching quotation bases: $e');
      throw "Failed to fetch quotation bases";
    }
    return [];
  }

  /// Regular customer search.
  Future<List<QuotationCustomer>> searchCustomers(String pattern) async {
    final endpoint = "/api/Quotation/QuotationGetCustomer";

    final body = {
      "PageSize": 100,
      "PageNumber": 1,
      "SortField": "",
      "SortDirection": "",
      "SearchValue": pattern,
    };

    final response = await _dio.post(endpoint, data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => QuotationCustomer.fromJson(e))
          .toList();
    }
    debugPrint('Error searching customers: ${response.data}');
    return [];
  }

  /// Inquiry customer search (for quotations with inquiry reference).
  Future<List<QuotationCustomer>> searchInquiryCustomers(String pattern) async {
    final endpoint = "/api/Quotation/QuotationInquiryCustomerList";

    final body = {
      "PageSize": 100,
      "PageNumber": 1,
      "SortField": "",
      "SortDirection": "",
      "SearchValue": pattern,
    };

    final response = await _dio.post(endpoint, data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => QuotationCustomer.fromJson(e))
          .toList();
    }
    debugPrint('Error searching inquiry customers: ${response.data}');
    return [];
  }

  /// Regular Salesman list.
  Future<List<Salesman>> fetchSalesmen() async {
    final endpoint = "/api/Lead/LeadSalesManList";
    final response = await _dio.get(endpoint);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => Salesman.fromJson(e))
          .toList();
    }
    debugPrint('Error fetching salesmen: ${response.data}');
    return [];
  }

  /// Inquiry Salesman list for quotations with inquiry reference.
  Future<List<Salesman>> fetchInquirySalesmen() async {
    final endpoint = "/api/Quotation/QuotationInquirySalesmanList";
    final response = await _dio.get(endpoint);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => Salesman.fromJson(e))
          .toList();
    }
    debugPrint('Error fetching inquiry salesmen: ${response.data}');
    return [];
  }

  /// Search items for regular quotation.
  Future<List<QuotationSalesItem>> searchItems(String pattern) async {
    final endpoint = "/api/Lead/GetSalesItemList";

    final body = {
      "pageSize": 10,
      "pageNumber": 1,
      "sortField": "",
      "sortDirection": "",
      "searchValue": pattern,
    };

    if (pattern.length < 3) return [];
    final response = await _dio.post(
      endpoint,
      data: body,
      queryParameters: {"flag": "L"},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => QuotationSalesItem.fromJson(e))
          .toList();
    }
    debugPrint('Error searching items: ${response.data}');
    return [];
  }

  /// Fetch discount codes.
  Future<List<DiscountCode>> fetchDiscountCodes() async {
    await _setupHeaders();
    const endpoint = "/api/Quotation/QuotationGetDiscount";
    final response = await _dio.get(
      endpoint,
      queryParameters: {"codeType": "DD", "codeValue": "GEN"},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => DiscountCode.fromJson(e))
          .toList();
    }
    debugPrint('Error fetching discount codes: ${response.data}');
    return [];
  }

  /// Fetch rate structures.
  Future<List<RateStructure>> fetchRateStructures() async {
    final String baseUrl = await StorageUtils.readValue('url') ?? '';
    if (baseUrl.isEmpty) throw Exception("Base URL not set");
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");
    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    const endpoint = '/api/Quotation/QuotationGetRateStructureForSales';

    final response = await _dio.get(
      endpoint,
      queryParameters: {"companyID": companyId, "currencyCode": "INR"},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => RateStructure.fromJson(e))
          .toList();
    }
    return [];
  }

  /// Fetch rate structure details.
  Future<List<Map<String, dynamic>>> fetchRateStructureDetails({
    required String rateStructureCode,
  }) async {
    final endpoint = "/api/Quotation/QuotationSelectOnRateStruCode";
    final response = await _dio.get(
      endpoint,
      queryParameters: {"rateStructureCode": rateStructureCode},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      if (response.data['data'] is List) {
        rateStructures =
            (response.data['data'] as List)
                .map((e) => RateStructure.fromJson(e))
                .toList();
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
    }
    throw Exception("Failed to fetch rate structure details");
  }

  /// Calculate tax for an item.
  Future<Map<String, dynamic>> calculateTax({
    required String rateStructureCode,
    required String itemCode,
    required double itemAmount,
    required double basicRate,
    required String discountType,
    required double discountValue,
    required List<Map<String, dynamic>> rateStructureDetails,
  }) async {
    final String baseUrl = await StorageUtils.readValue('url') ?? '';
    if (baseUrl.isEmpty) throw Exception("Base URL not set");
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");
    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Quotation/CalcRateStructure";
    final body = {
      "ItemAmount": itemAmount,
      "ExchangeRt": "1",
      "DomCurrency": "INR",
      "CurrencyCode": "INR",
      "DiscType": discountType,
      "BasicRate": basicRate,
      "DiscValue": discountValue,
      "From": "sales",
      "Flag": "",
      "TotalItemAmount": itemAmount,
      "LandedPrice": 0,
      "uniqueno": 0,
      "RateCode": rateStructureCode,
      "RateStructureDetails": rateStructureDetails,
      "rateType": "S",
      "IsView": false,
    };
    final response = await _dio.post(
      endpoint,
      queryParameters: {"RateStructureCode": rateStructureCode},
      data: body,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw Exception('Failed to calculate tax');
  }

  /// Get open inquiry numbers.
  Future<List<String>> fetchOpenInquiryNumbers() async {
    final endpoint = "/api/Quotation/QuotationInquirygetOpenInquiryNumberList";
    final response = await _dio.get(endpoint);
    if (response.statusCode == 200 && response.data['success'] == true) {
      // Assume response.data['data'] is a list of inquiry numbers
      return List<String>.from(response.data['data']);
    }
    debugPrint('Error fetching open inquiry numbers: ${response.data}');
    return [];
  }

  /// Get sales item details for an inquiry.
  Future<List<QuotationSalesItem>> fetchInquirySalesItemDetails(
    String inquiryNumber,
  ) async {
    final endpoint = "/api/Quotation/QuotationInquirygetSalesItemDetails";
    final response = await _dio.get(
      endpoint,
      queryParameters: {"inquiryNumber": inquiryNumber},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((e) => QuotationSalesItem.fromJson(e))
          .toList();
    }
    debugPrint('Error fetching inquiry sales item details: ${response.data}');
    return [];
  }

  /// Submit the quotation payload.
  Future<Map<String, dynamic>> submitQuotation(
    QuotationSubmissionData data,
  ) async {
    // Build DiscountDetails and ModelDetails, totals calculation and collection happens here.
    List<Map<String, dynamic>> discountDetails = [];
    List<Map<String, dynamic>> modelDetails = [];
    double totalBasic = 0, totalDiscount = 0, totalTax = 0, totalAmount = 0;

    for (int i = 0; i < data.items.length; i++) {
      final item = data.items[i];
      final calc = calculateDiscountedTotal(
        qty: item['qty'],
        rate: item['rate'],
        discountType: item['discountType'],
        discountValue: item['discountValue'],
      );

      totalBasic += calc.discountedAmount;
      totalDiscount += calc.discountValueApplied;

      // Call tax API for each item; for simplicity we call synchronously.
      final taxResult = await calculateTax(
        rateStructureCode: item['rateStructure'] ?? '',
        itemCode: item['itemCode'] ?? '',
        itemAmount: calc.discountedAmount,
        basicRate: item['rate'],
        discountType: item['discountType'],
        discountValue: calc.discountValueApplied,
        rateStructureDetails:
            [], // You can pass rate structure details if available.
      );
      final taxAmount =
          (taxResult['totalExclusiveDomCurrAmount'] ?? 0.0).toDouble();
      final totalItemAmount =
          (taxResult['itemLandedCost'] ?? (calc.discountedAmount + taxAmount))
              .toDouble();

      totalTax += taxAmount;
      totalAmount += totalItemAmount;

      if (calc.discountValueApplied > 0) {
        discountDetails.add({
          "AmendSrNo": 0,
          "CurrencyCode": "INR",
          "DiscountCode": item['discountCode'] ?? "01",
          "DiscountType": item['discountType'] ?? "None",
          "DiscountValue": calc.discountValueApplied,
          "SalesItemCode": item['itemCode'] ?? "",
        });
      }

      modelDetails.add({
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
        "DiscountAmt": calc.discountValueApplied,
        "DiscountType": item['discountType'] ?? "",
        "DiscountTypeText":
            (item['discountType'] ?? "").toLowerCase() == "percentage"
                ? "PERCENTAGE"
                : "",
        "DiscountValue": calc.discountValueApplied,
        "DrawingNo": "",
        "GroupId": 0,
        "InvoiceMethod": "Q",
        "InvoiceType": "Regular",
        "InvoiceTypeShortText": "R",
        "IsSubItem": false,
        "ItemAmountAfterDisc": calc.discountedAmount,
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

    // Build QuotationDetails section.
    final quotationDetails = {
      "AttachFlag": "",
      "BillToCustomerCode": data.billTo.customerCode,
      "CustomerCode": data.quoteTo.customerCode,
      "CustomerInqRefNo": "",
      "CustomerName": data.quoteTo.customerName,
      "DiscountAmount": totalDiscount,
      "DiscountType": "None",
      "DiscountTypeText": "",
      "ExchangeRate": 1,
      "IsAgentAssociated": false,
      "IsBudgetaryQuotation": false,
      "ModValue": 0,
      "ProjectItemId": 0,
      "QtnStatus": "O",
      "QuotationDate":
          "${data.quotationDate.toIso8601String().split('T').first}T00:00:00",
      "QuotationGroup": data.docDetail["groupCode"],
      "QuotationId": 0,
      "QuotationNumber": "0",
      "QuotationSiteCode": data.docDetail["locationCode"],
      "QuotationSiteId": data.docDetail["locationId"],
      "QuotationStatus": "NS",
      "QuotationTypeConfig": "3",
      "QuotationTypeSalesOrder": "REG",
      "QuotationYear": data.quotationYear,
      "SalesPersonCode": data.salesman.salesManFullName,
      "Subject": data.subject,
      "SubmittedDate": null,
      "TotalAmountAfterDiscountCustomerCurrency": totalBasic,
      "TotalAmountAfterTaxCustomerCurrency": totalAmount,
      "TotalAmounttAfterTaxDomesticCurrency": totalAmount,
      "Validity": 30,
    };

    final payload = {
      "AddOnDetails": null,
      "AuthorizationDate": "0001-01-01T00:00:00",
      "AuthorizationRequired": "Y",
      "AutoNumberRequired": "Y",
      "CompanyId": data.docDetail["CompanyId"] ?? 1,
      "DiscountDetails": discountDetails,
      "DocSubType": "SQ",
      "DocType": "SQ",
      "DomesticCurrencyCode": "INR",
      "EquipmentAttributeDetails": null,
      "FromLocationCode": data.docDetail["locationCode"],
      "FromLocationId": data.docDetail["locationId"],
      "FromLocationName": data.docDetail["locationName"],
      "HistoryDetails": null,
      "IP": null,
      "MAC": null,
      "ModelDetails": modelDetails,
      "NoteDetails": null,
      "QuotationDetails": quotationDetails,
      "QuotationRemarks": null,
      "QuotationTextDetails": null,
      "RateStructureDetails": rateStructures,
      "SiteRequired": "Y",
      "StandardTerms": null,
      "SubItemDetails": null,
      "TermDetails": null,
      "UserId": data.userId,
      "msctechspecifications": false,
      "technicalspec": null,
    };

    // Setup headers before submission.
    final String baseUrl = await StorageUtils.readValue('url') ?? '';
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");
    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");
    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';
    const endpoint = "/api/Quotation/QuotationCreate";
    final response = await _dio.post(endpoint, data: payload);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data;
    }
    throw Exception('Failed to submit quotation');
  }

  /// Upload attachments if any.
  Future<bool> uploadAttachments({
    required List<String> filePaths,
    required String documentNo,
    required String documentId,
    required String docYear,
    required String formId,
    required String locationCode,
    required String companyCode,
    required int locationId,
    required int companyId,
    required int userId,
  }) async {
    try {
      await _setupHeaders();
      const endpoint = "/api/Quotation/uploadAttachmentNew";
      final documentNumber = documentNo;
      final formData = FormData();

      formData.fields.addAll([
        MapEntry("LocationID", locationId.toString()),
        MapEntry("CompanyID", companyId.toString()),
        MapEntry("CompanyCode", companyCode),
        MapEntry("LocationCode", locationCode),
        MapEntry("DocYear", docYear),
        MapEntry("FormID", formId),
        MapEntry("DocumentNo", documentNumber),
        MapEntry("DocumentID", documentId),
      ]);

      for (final path in filePaths) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            "AttachmentsFile",
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

      final headers = Map<String, dynamic>.from(_dio.options.headers);
      headers.remove('Content-Type');

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
          followRedirects: false,
        ),
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Error uploading attachments: $e');
      return false;
    }
  }

  // Future fetchLeadNumbers({required String customerCode}) async {
  //   try {
  //     var dio = Dio();
  //     final baseUrl = await StorageUtils.readValue('url');
  //     final companyDetails = await StorageUtils.readJson('selected_company');
  //     if (companyDetails == null) throw Exception("Company not set");
  //     final locationDetails = await StorageUtils.readJson('selected_location');
  //     if (locationDetails == null) throw Exception("Location not set");
  //     final tokenDetails = await StorageUtils.readJson('session_token');
  //     if (tokenDetails == null) throw Exception("Session token not found");

  //     final companyId = companyDetails['id'];
  //     String siteCode = locationDetails['code'];
  //     final token = tokenDetails['token']['value'];
  //     dio.options.headers = {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'companyid': companyId,
  //       'Authorization': 'Bearer $token',
  //     };
  //     const endpoint =
  //         "/api/Quotation/QuotationInquirygetOpenInquiryNumberList";
  //     final response = await dio.get(
  //       "http://$baseUrl$endpoint",
  //       queryParameters: {
  //         "CustomerCode": customerCode,
  //         "UserLocationCodes": "'$siteCode'",
  //       },
  //     );
  //     if (response.statusCode == 200 && response.data['success'] == true) {
  //       var leadnumbers = List<String>.from(response.data['data']);
  //       if (leadnumbers.isEmpty) {
  //         leadnumbers.add("No Open Inquiry Found");
  //       }
  //       return leadnumbers;
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching lead numbers: $e');
  //   }
  //   return [];
  // }

  Future<List<String>> fetchLeadNumbers({required String customerCode}) async {
    try {
      var dio = Dio();
      final baseUrl = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");
      final locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails == null) throw Exception("Location not set");
      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      String siteCode = locationDetails['code'];
      final token = tokenDetails['token']['value'];
      dio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'companyid': companyId,
        'Authorization': 'Bearer $token',
      };
      const endpoint =
          "/api/Quotation/QuotationInquirygetOpenInquiryNumberList";
      final response = await dio.get(
        "http://$baseUrl$endpoint",
        queryParameters: {
          "CustomerCode": customerCode,
          "UserLocationCodes": "'$siteCode'",
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        List<String> leadNumbers = [];

        if (data is List) {
          // Handle the case where data is a list of maps or strings
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              // If it's a map, extract the inquiry number field
              // Common field names might be: inquiryNumber, inquiryNo, number, etc.
              String? inquiryNumber =
                  item['inquiryNumber']?.toString() ??
                  item['inquiryNo']?.toString() ??
                  item['number']?.toString() ??
                  item['id']?.toString() ??
                  item['leadNumber']?.toString() ??
                  item['leadNo']?.toString();

              if (inquiryNumber != null && inquiryNumber.isNotEmpty) {
                leadNumbers.add(inquiryNumber);
              }
            } else if (item is String) {
              // If it's already a string, add it directly
              leadNumbers.add(item);
            } else {
              // Convert to string as fallback
              leadNumbers.add(item.toString());
            }
          }
        }

        // Return empty list message if no leads found
        if (leadNumbers.isEmpty) {
          return ["No Open Inquiry Found"];
        }

        return leadNumbers;
      } else {
        debugPrint('API Error: ${response.data}');
        return ["No Open Inquiry Found"];
      }
    } catch (e) {
      debugPrint('Error fetching lead numbers: $e');
      return ["Error loading lead numbers"];
    }
  }
}
