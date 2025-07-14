import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
import '../../../utils/storage_utils.dart';

class ProformaInvoiceService {
  late final Dio _dio;
  late final String _baseUrl;
  late final Map<String, dynamic> _companyDetails;
  late final Map<String, dynamic> _tokenDetails;
  late final Map<String, dynamic> _locationDetails;
  late final Map<String, dynamic> _financeDetails;
  late final Map<String, dynamic> _quotationDocumentDetails;
  late final Map<String, dynamic> _salesOrderDocumentDetails;
  late int _companyId;

  ProformaInvoiceService._();

  static Future<ProformaInvoiceService> create() async {
    final service = ProformaInvoiceService._();
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

    fetchQuotationDefaultDocumentDetail("SQ");
    fetchSalesOrderDefaultDocumentDetail("OB");
  }

  Future<void> fetchQuotationDefaultDocumentDetail(String type) async {
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
      return;
    } catch (e) {
      debugPrint("Error fetching quotation document detail: $e");
      throw Exception("Failed to fetch quotation document detail");
    }
  }

  Future<void> fetchSalesOrderDefaultDocumentDetail(String type) async {
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
      return;
    } catch (e) {
      debugPrint("Error fetching sales order document detail: $e");
      throw Exception("Failed to fetch sales order document detail");
    }
  }

  Future<Map<String, dynamic>> fetchDefaultDocumentDetail(String type) async {
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
    return response.data['data'][0];
  }

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

  // Future<QuotationDetails> fetchQuotationDetails(String quotationNumber) async {
  //   final endpoint =
  //       "/api/Proforma/proformaInvoiceGetModelItemDetails_Quatation";

  //   final response = await _dio.get(
  //     "$_baseUrl$endpoint",
  //     queryParameters: {
  //       "PILocationId": _locationDetails['id'],
  //       "year": _financeDetails['financialYear'],
  //       "groupCode": _quotationDocumentDetails['groupCode'],
  //       "SONumber": quotationNumber,
  //       "srNo": 0,
  //     },
  //   );
  //   return QuotationDetails.fromJson(response.data['data']);
  // }

  // Future<SalesOrderDetails> fetchSalesOrderDetails(
  //   String salesOrderNumber,
  // ) async {
  //   final endpoint = "/api/Proforma/proformaInvoiceGetModelItemDetails_SO";

  //   final response = await _dio.get(
  //     "$_baseUrl$endpoint",
  //     queryParameters: {
  //       "PILocationId": _locationDetails['id'],
  //       "year": _financeDetails['financialYear'],
  //       "groupCode": _salesOrderDocumentDetails['groupCode'],
  //       "SONumber": salesOrderNumber,
  //       "srNo": 0,
  //     },
  //   );
  //   return SalesOrderDetails.fromJson(response.data['data']);
  // }
  // Update fetchQuotationDetails method
  Future<QuotationDetails> fetchQuotationDetails(
    String quotationNumber,
    int srNo,
  ) async {
    final endpoint =
        "/api/Proforma/proformaInvoiceGetModelItemDetails_Quatation";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "PILocationId": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "groupCode": _quotationDocumentDetails['groupCode'],
        "SONumber": quotationNumber,
        "srNo": srNo,
      },
    );
    return QuotationDetails.fromJson(response.data['data']);
  }

  // Update fetchSalesOrderDetails method
  Future<SalesOrderDetails> fetchSalesOrderDetails(
    String salesOrderNumber,
    int srNo,
  ) async {
    final endpoint = "/api/Proforma/proformaInvoiceGetModelItemDetails_SO";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "PILocationId": _locationDetails['id'],
        "year": _financeDetails['financialYear'],
        "groupCode": _salesOrderDocumentDetails['groupCode'],
        "SONumber": salesOrderNumber,
        "srNo": srNo,
      },
    );
    return SalesOrderDetails.fromJson(response.data['data']);
  }

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

  Future<List<RateStructure>> fetchRateStructures(int companyId) async {
    const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";

    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails.isEmpty) {
      throw Exception("Company details not found");
    }
    final companyId = companyDetails['id'];
    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails.isEmpty) {
      throw Exception("Session token not found");
    }
    final token = tokenDetails['token']['value'];

    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        'companyID': companyId.toString(),
        'currencyCode': 'INR',
      },
    );
    debugPrint("Response: ${response.data}");
    final data = response.data['data'] as List;
    debugPrint("Rate Structures: $data");
    return data.map((item) => RateStructure.fromJson(item)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchRateStructureDetails(
    String rateStructureCode,
  ) async {
    final endpoint =
        "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
    final response = await _dio.get("$_baseUrl$endpoint");
    return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
  }

  Future<List<DiscountCode>> fetchDiscountCodes() async {
    const endpoint =
        "/api/Quotation/QuotationGetDiscount?codeType=DD&codeValue=GEN";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => DiscountCode.fromJson(item)).toList();
      } else {
        throw Exception(
          "Failed to fetch discount codes: ${response.data['errorMessage']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch discount codes: $e");
    }
  }

  /// NEW: Build RateStructureDetails for CalcRateStructure API
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

  /// UPDATED: Use RateStructureDetails as per new API
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

  // Future<Map<String, dynamic>> calculateRateStructure(
  //   double itemAmount,
  //   String rateStructureCode,
  //   List<Map<String, dynamic>> rateStructureDetails,
  //   String itemCode,
  // ) async {
  //   const endpoint = "/api/Quotation/CalcRateStructure";
  //   final body = {
  //     "ItemAmount": itemAmount,
  //     "ExchangeRt": "1",
  //     "DomCurrency": "INR",
  //     "CurrencyCode": "INR",
  //     "DiscType": "",
  //     "BasicRate": 0,
  //     "DiscValue": 0,
  //     "From": "sales",
  //     "Flag": "",
  //     "TotalItemAmount": itemAmount,
  //     "LandedPrice": 0,
  //     "uniqueno": 0,
  //     "RateCode": rateStructureCode,
  //     "RateStructureDetails":
  //         rateStructureDetails
  //             .map((e) => {...e, "itemCode": itemCode})
  //             .toList(),
  //     "rateType": "P",
  //     "IsView": false,
  //   };

  //   final response = await _dio.post(
  //     "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
  //     data: body,
  //   );
  //   return response.data;
  // }

  // Future<bool> submitProformaInvoice(Map<String, dynamic> payload) async {
  //   const endpoint = "/api/Proforma/proformaInvoiceEntryCreate";
  //   try {
  //     final response = await _dio.post("$_baseUrl$endpoint", data: payload);
  //     return response.data['success'] == true;
  //   } catch (e) {
  //     throw Exception("Failed to submit proforma invoice: $e");
  //   }
  // }

  // Future<bool> updateProformaInvoice(Map<String, dynamic> payload) async {
  //   const endpoint = "/api/Proforma/proformaInvoiceEntryUpdate";
  //   try {
  //     final response = await _dio.post("$_baseUrl$endpoint", data: payload);
  //     return response.data['success'] == true;
  //   } catch (e) {
  //     throw Exception("Failed to update proforma invoice: $e");
  //   }
  // }
  Future<String> submitProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryCreate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      if (response.data['success'] == true) {
        return response.data['data']?.toString() ?? "0";
      } else {
        throw Exception(response.data['errorMessage'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception("Failed to submit proforma invoice: $e");
    }
  }

  Future<String> updateProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryUpdate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      if (response.data['success'] == true) {
        return response.data['data']?.toString() ?? "0";
      } else {
        throw Exception(response.data['errorMessage'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception("Failed to update proforma invoice: $e");
    }
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

  Future<Map<String, dynamic>?> getGeoLocation({
    required String functionId,
  }) async {
    try {
      const endpoint = "/api/Login/getGeoLocation";

      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: {
          'companyid': _companyId,
          'functioncode': 'PI',
          'functionid': functionId,
        },
      );

      debugPrint("GeoLocation API response: ${response.data}");

      final data = jsonDecode(response.data) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        // Convert string coordinates to double for easier use
        final parsedData = {
          'mLOCFUNCTIONID': data['mLOCFUNCTIONID'],
          'longitude': double.tryParse(data['mLOCLONGITUDE'].toString()) ?? 0.0,
          'latitude': double.tryParse(data['mLOCLATITUDE'].toString()) ?? 0.0,
          'mLOCLONGITUDE': data['mLOCLONGITUDE'],
          'mLOCLATITUDE': data['mLOCLATITUDE'],
        };

        return parsedData;
      }

      return null;
    } catch (e) {
      debugPrint("Error in getGeoLocation: $e");
      return null;
    }
  }
}
