import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import '../../../utils/storage_utils.dart';

class EditProformaInvoiceService {
  late final Dio _dio;
  late final String _baseUrl;
  late final Map<String, dynamic> _companyDetails;
  late final Map<String, dynamic> _tokenDetails;
  late final Map<String, dynamic> _locationDetails;
  late final Map<String, dynamic> _financeDetails;
  late final Map<String, dynamic> _quotationDocumentDetails;
  late final Map<String, dynamic> _salesOrderDocumentDetails;
  late int _companyId;

  EditProformaInvoiceService._();

  static Future<EditProformaInvoiceService> create() async {
    final service = EditProformaInvoiceService._();
    await service._initializeService();
    return service;
  }

  Future<void> _initializeService() async {
    _baseUrl = "http://${await StorageUtils.readValue('url') ?? ""}";

    _companyDetails = await StorageUtils.readJson('selected_company');
    if (_companyDetails.isEmpty) throw Exception("Company not set");
    _locationDetails = await StorageUtils.readJson('selected_location');
    if (_locationDetails.isEmpty) throw Exception("Location not set");
    _tokenDetails = await StorageUtils.readJson('session_token');
    if (_tokenDetails.isEmpty) throw Exception("Session token not found");
    _financeDetails = await StorageUtils.readJson('finance_period');
    if (_financeDetails.isEmpty) throw Exception("Finance details not found");

    _companyId = _companyDetails['id'];
    final token = _tokenDetails['token']['value'];

    _dio = Dio();
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = _companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    await _fetchQuotationDefaultDocumentDetail("SQ");
    await _fetchSalesOrderDefaultDocumentDetail("OB");
  }

  Future<void> _fetchQuotationDefaultDocumentDetail(String type) async {
    try {
      String endpoint = "/api/Lead/GetDefaultDocumentDetail";
      final year = _financeDetails['financialYear'];
      final locationId = _locationDetails['id'];

      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          "year": year,
          "type": type,
          "subType": type,
          "locationId": locationId,
        },
      );
      if (response.data['data'].isEmpty || response.statusCode != 200) {
        throw Exception("No data found for quotation document detail");
      }
      _quotationDocumentDetails = response.data['data'][0];
    } catch (e) {
      debugPrint("Error fetching quotation document detail: $e");
      throw Exception("Failed to fetch quotation document detail");
    }
  }

  Future<void> _fetchSalesOrderDefaultDocumentDetail(String type) async {
    try {
      String endpoint = "/api/Lead/GetDefaultDocumentDetail";
      final year = _financeDetails['financialYear'];
      final locationId = _locationDetails['id'];

      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          "year": year,
          "type": type,
          "subType": type,
          "locationId": locationId,
        },
      );
      if (response.data['data'].isEmpty || response.statusCode != 200) {
        throw Exception("No data found for sales order document detail");
      }
      _salesOrderDocumentDetails = response.data['data'][0];
    } catch (e) {
      debugPrint("Error fetching sales order document detail: $e");
      throw Exception("Failed to fetch sales order document detail");
    }
  }

  /// Fetch proforma invoice details for editing
  Future<ProformaInvoiceDetails> fetchProformaInvoiceDetails({
    required int invSiteId,
    required String invYear,
    required String invGroup,
    required String invNumber,
    required String piOn,
    required int fromLocationId,
    required String custCode,
    String search = "S",
  }) async {
    final endpoint =
        "/api/Proforma/proformaInvoiceGetInvoiceDetails"
        "?invSiteId=$invSiteId"
        "&invYear=$invYear"
        "&invGroup=$invGroup"
        "&invNumber=$invNumber"
        "&piOn=$piOn"
        "&fromLoactionId=$fromLocationId"
        "&custCode=$custCode"
        "&search=$search";

    final response = await _dio.get("$_baseUrl$endpoint");
    if (response.statusCode == 200 && response.data['success'] == true) {
      return ProformaInvoiceDetails.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch proforma invoice details');
  }

  /// Fetch default document detail for quotation/sales order
  Future<DefaultDocumentDetail> fetchDefaultDocumentDetail(String type) async {
    String endpoint = "/api/Lead/GetDefaultDocumentDetail";
    final year = _financeDetails['financialYear'];
    final locationId = _locationDetails['id'];

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "year": year,
        "type": type,
        "subType": type,
        "locationId": locationId,
      },
    );
    return DefaultDocumentDetail.fromJson(response.data['data'][0]);
  }

  /// Fetch customer suggestions for typeahead
  Future<List<Customer>> fetchCustomerSuggestions(String pattern) async {
    const endpoint = "/api/Proforma/proformaInvoiceCustomerList";
    final body = {
      "pageNumber": 1,
      "pageSize": 10,
      "sortField": "",
      "sortDirection": "",
      "searchValue": pattern,
      "restcoresalestrans": "false",
    };

    final response = await _dio.post("$_baseUrl$endpoint", data: body);
    final data = response.data['data'] as List;
    return data.map((item) => Customer.fromJson(item)).toList();
  }

  /// Fetch quotation numbers for selected customer
  Future<List<QuotationNumber>> fetchQuotationNumberList(
    String custCode,
  ) async {
    final endpoint = "/api/Proforma/proformaInvoiceGetQuatationNumberList";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "fromLocationId": _locationDetails['id'],
        "locationCode": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "group": _quotationDocumentDetails['groupCode'],
        "custCode": custCode,
      },
    );
    final data = response.data['data'] as List;
    return data.map((item) => QuotationNumber.fromJson(item)).toList();
  }

  /// Fetch sales order numbers for selected customer
  Future<List<SalesOrderNumber>> fetchSalesOrderNumberList(
    String custCode,
  ) async {
    final endpoint = "/api/Proforma/proformaInvoiceGetSONumberList";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "fromLocationId": _locationDetails['id'],
        "locationCode": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "group": _salesOrderDocumentDetails['groupCode'],
        "custCode": custCode,
      },
    );
    final data = response.data['data'] as List;
    return data.map((item) => SalesOrderNumber.fromJson(item)).toList();
  }

  /// Fetch quotation details
  Future<QuotationDetails> fetchQuotationDetails(String quotationNumber) async {
    final endpoint =
        "/api/Proforma/proformaInvoiceGetModelItemDetails_Quatation";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "PILocationId": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "groupCode": _quotationDocumentDetails['groupCode'],
        "SONumber": quotationNumber,
        "srNo": 0,
      },
    );
    return QuotationDetails.fromJson(response.data['data']);
  }

  /// Fetch sales order details
  Future<SalesOrderDetails> fetchSalesOrderDetails(
    String salesOrderNumber,
  ) async {
    final endpoint = "/api/Proforma/proformaInvoiceGetModelItemDetails_SO";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "PILocationId": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "groupCode": _salesOrderDocumentDetails['groupCode'],
        "SONumber": salesOrderNumber,
        "srNo": 1,
      },
    );
    return SalesOrderDetails.fromJson(response.data['data']);
  }

  /// Fetch sales item list for add item functionality
  Future<List<SalesItem>> fetchSalesItemList(String pattern) async {
    const endpoint = "/api/Lead/GetSalesItemList?flag=L";
    final body = {
      "pageSize": 10,
      "pageNumber": 1,
      "sortField": "",
      "sortDirection": "",
      "searchValue": pattern,
    };

    final response = await _dio.post("$_baseUrl$endpoint", data: body);
    final data = response.data['data'] as List;
    return data.map((item) => SalesItem.fromJson(item)).toList();
  }

  /// Fetch rate structures for company
  Future<List<RateStructure>> fetchRateStructures(int companyId) async {
    const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        'companyID': companyId.toString(),
        'currencyCode': 'INR',
      },
    );
    final data = response.data['data'] as List;
    return data.map((item) => RateStructure.fromJson(item)).toList();
  }

  /// Fetch rate structure details
  Future<List<Map<String, dynamic>>> fetchRateStructureDetails(
    String rateStructureCode,
  ) async {
    final endpoint =
        "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
    final response = await _dio.get("$_baseUrl$endpoint");
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  /// Build rate structure details for calculation
  List<Map<String, dynamic>> buildRateStructureDetails(
    List<Map<String, dynamic>> rateStructureRows,
    String itemCode,
    int itmModelRefNo,
  ) {
    final templist =
        rateStructureRows
            .where((x) => (x['itmModelRefNo'] ?? 1) == itmModelRefNo)
            .toList();

    return templist.map((item) {
      return {
        'rateCode': item['rateCode'] ?? item['msprtcd'],
        'rateDesc': item['rateDesc'] ?? item['mprrtdesc'],
        'ie': item['incExc'] ?? item['mspincexc'],
        'pv': item['perValueCode'] ?? item['mspperval'],
        'applicableOn': item['applicableOn'] ?? item['mtrslvlno'] ?? "",
        'appOnDisplay': item['appOnDisplay'] ?? item['mspappondesc'] ?? "",
        'taxValue':
            item['taxValue']?.toString() ??
            item['msprtval']?.toString() ??
            "0.00",
        'prevTaxValue':
            item['taxValue']?.toString() ??
            item['msprtval']?.toString() ??
            "0.00",
        'postnonpost':
            item['pNYN'] ??
            item['msppnyn'] == "True" || item['msppnyn'] == true,
        'rateAmount': 0.00,
        'currencyCode': item['curCode'] ?? item['mprcurcode'] ?? "INR",
        'itmModelRefNo': itmModelRefNo,
        'sequenceNo':
            item['seqNo']?.toString() ?? item['mspseqno']?.toString() ?? "1",
        'taxType': item['taxType'] ?? item['mprtaxtyp'],
        'itemCode': itemCode,
        'uniqueno': 0,
      };
    }).toList();
  }

  Future<bool> submitLocation({
    required String functionId,
    required double longitude,
    required double latitude,
  }) async {
    const endpoint = "/api/Quotation/InsertLocation";
    try {
      final body = {
        "strFunction": "PI",
        "intFunctionID": functionId,
        "Longitude": longitude,
        "Latitude": latitude,
      };

      debugPrint("Submitting location with body: ${body.toString()}");

      final response = await _dio.post('$_baseUrl$endpoint', data: body);

      debugPrint("Location submission response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final success = data['success'];
          if (success == true || success == 'true') {
            debugPrint("Location submission successful");
            return true;
          } else {
            debugPrint(
              "Location submission failed: ${data['message'] ?? 'Unknown error'}",
            );
            return false;
          }
        }
      }

      debugPrint(
        "Location submission failed with status: ${response.statusCode}",
      );
      return false;
    } catch (e) {
      debugPrint("Error in submitLocation: $e");
      return false;
    }
  }

  /// Calculate rate structure for item
  Future<Map<String, dynamic>> calculateRateStructure(
    double itemAmount,
    String rateStructureCode,
    List<Map<String, dynamic>> rateStructureDetails,
    String itemCode,
  ) async {
    const endpoint = "/api/Quotation/CalcRateStructure";
    final body = {
      "ItemAmount": itemAmount,
      "ExchangeRt": "1",
      "DomCurrency": "INR",
      "CurrencyCode": "INR",
      "DiscType": "",
      "BasicRate": 0,
      "DiscValue": 0,
      "From": "sales",
      "Flag": "",
      "TotalItemAmount": itemAmount,
      "LandedPrice": 0,
      "uniqueno": 0,
      "RateCode": rateStructureCode,
      "RateStructureDetails": rateStructureDetails,
      "rateType": "P",
      "IsView": false,
    };

    final response = await _dio.post(
      "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
      data: body,
    );
    return response.data;
  }

  /// Update proforma invoice
  Future<bool> updateProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryUpdate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data['success'] == true;
    } catch (e) {
      throw Exception("Failed to update proforma invoice: $e");
    }
  }

  /// Submit new proforma invoice (in case user wants to save as new)
  Future<bool> submitProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryCreate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data['success'] == true;
    } catch (e) {
      throw Exception("Failed to submit proforma invoice: $e");
    }
  }

  /// Get default quotation document details
  Map<String, dynamic> get quotationDocumentDetails =>
      _quotationDocumentDetails;

  /// Get default sales order document details
  Map<String, dynamic> get salesOrderDocumentDetails =>
      _salesOrderDocumentDetails;

  /// Get finance details
  Map<String, dynamic> get financeDetails => _financeDetails;

  /// Get location details
  Map<String, dynamic> get locationDetails => _locationDetails;

  /// Get company details
  Map<String, dynamic> get companyDetails => _companyDetails;

  /// Get user details from token
  Map<String, dynamic>? get userDetails => _tokenDetails['user'];
}
