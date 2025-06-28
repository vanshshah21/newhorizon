// import 'package:dio/dio.dart';
// import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
// import '../../../utils/storage_utils.dart';

// class ProformaInvoiceService {
//   late final Dio _dio;
//   late final String _baseUrl;
//   late final Map<String, dynamic> _companyDetails;
//   late final Map<String, dynamic> _tokenDetails;
//   late final Map<String, dynamic> _locationDetails;
//   late int _companyId;

//   ProformaInvoiceService() {
//     _dio = Dio();
//     _initializeService();
//   }

//   Future<void> _initializeService() async {
//     _baseUrl = "http://${await StorageUtils.readValue('url') ?? ""}";

//     _companyDetails = await StorageUtils.readJson('selected_company');
//     if (_companyDetails.isEmpty) throw Exception("Company not set");
//     _locationDetails = await StorageUtils.readJson('selected_location');
//     if (_locationDetails.isEmpty) throw Exception("Location not set");
//     _tokenDetails = await StorageUtils.readJson('session_token');
//     if (_tokenDetails.isEmpty) throw Exception("Session token not found");

//     _companyId = _companyDetails['id'];
//     final token = _tokenDetails['token']['value'];

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['companyid'] = _companyId.toString();
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   Future<DefaultDocumentDetail> fetchDefaultDocumentDetail(String type) async {
//     String endpoint = "";
//     if (type == "SQ") {
//       endpoint =
//           "/api/Lead/GetDefaultDocumentDetail?year=24-25&type=SQ&subType=SQ&locationId=8";
//     } else if (type == "OB") {
//       endpoint =
//           "/api/Lead/GetDefaultDocumentDetail?year=24-25&type=OB&subType=OB&locationId=8";
//     }

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return DefaultDocumentDetail.fromJson(response.data['data'][0]);
//   }

//   Future<List<Customer>> fetchCustomerSuggestions(String pattern) async {
//     const endpoint = "/api/Followup/FollowUpGetCustomer";
//     final body = {
//       "pageNumber": 1,
//       "pageSize": 10,
//       "sortField": "",
//       "sortDirection": "",
//       "searchValue": pattern,
//       "restcoresalestrans": "false",
//     };

//     final response = await _dio.post("$_baseUrl$endpoint", data: body);
//     final data = response.data['data'] as List;
//     return data.map((item) => Customer.fromJson(item)).toList();
//   }

//   Future<List<QuotationNumber>> fetchQuotationNumberList(
//     String custCode,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetQuatationNumberList?fromLocationId=8&locationCode=8&year=24-25&group=QA&custCode=$custCode";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     final data = response.data['data'] as List;
//     return data.map((item) => QuotationNumber.fromJson(item)).toList();
//   }

//   Future<List<SalesOrderNumber>> fetchSalesOrderNumberList(
//     String custCode,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetSONumberList?fromLocationId=8&locationCode=8&year=24-25&group=SO&custCode=$custCode";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     final data = response.data['data'] as List;
//     return data.map((item) => SalesOrderNumber.fromJson(item)).toList();
//   }

//   Future<QuotationDetails> fetchQuotationDetails(String quotationNumber) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetModelItemDetails_Quatation?PILocationId=8&year=24-25&groupCode=QA&SONumber=$quotationNumber&srNo=0";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return QuotationDetails.fromJson(response.data['data']);
//   }

//   Future<SalesOrderDetails> fetchSalesOrderDetails(
//     String salesOrderNumber,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetModelItemDetails_SO?PILocationId=8&year=24-25&groupCode=SO&SONumber=$salesOrderNumber&srNo=1";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return SalesOrderDetails.fromJson(response.data['data']);
//   }

//   Future<List<SalesItem>> fetchSalesItemList(String pattern) async {
//     const endpoint = "/api/Lead/GetSalesItemList?flag=L";
//     final body = {
//       "pageSize": 10,
//       "pageNumber": 1,
//       "sortField": "",
//       "sortDirection": "",
//       "searchValue": pattern,
//     };

//     final response = await _dio.post("$_baseUrl$endpoint", data: body);
//     final data = response.data['data'] as List;
//     return data.map((item) => SalesItem.fromJson(item)).toList();
//   }

//   Future<List<RateStructure>> fetchRateStructures(int companyId) async {
//     const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";

//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails.isEmpty) {
//       throw Exception("Company details not found");
//     }
//     final companyId = companyDetails['id'] ?? 0;
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails.isEmpty) {
//       throw Exception("Session token not found");
//     }
//     final token = tokenDetails['token']['value'] ?? '';

//     _dio.options.headers['companyid'] = companyId.toString();
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';

//     final response = await _dio.get(
//       "$_baseUrl$endpoint",
//       queryParameters: {
//         'companyID': companyId.toString(),
//         'currencyCode': 'INR',
//       },
//     );
//     final data = response.data['data'] as List;
//     return data.map((item) => RateStructure.fromJson(item)).toList();
//   }

//   Future<void> fetchRateStructureDetails(String rateStructureCode) async {
//     final endpoint =
//         "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
//     await _dio.get("$_baseUrl$endpoint");
//   }

//   Future<Map<String, dynamic>> calculateRateStructure(
//     double itemAmount,
//     String rateStructureCode,
//   ) async {
//     const endpoint = "/api/Quotation/CalcRateStructure";
//     final body = {
//       "ItemAmount": itemAmount,
//       "ExchangeRt": "1",
//       "DomCurrency": "INR",
//       "CurrencyCode": "INR",
//       "DiscType": "",
//       "BasicRate": 0,
//       "DiscValue": 0,
//       "From": "sales",
//       "Flag": "",
//       "TotalItemAmount": itemAmount,
//       "LandedPrice": 0,
//       "uniqueno": 0,
//       "RateCode": rateStructureCode,
//       "RateStructureDetails": [],
//       "rateType": "S",
//       "IsView": false,
//     };

//     final response = await _dio.post(
//       "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
//       data: body,
//     );
//     return response.data['data'];
//   }

//   Future<bool> submitProformaInvoice(Map<String, dynamic> payload) async {
//     const endpoint =
//         "/api/Proforma/SubmitProformaInvoice"; // Replace with actual endpoint

//     try {
//       final response = await _dio.post("$_baseUrl$endpoint", data: payload);
//       return response.data['success'] == true;
//     } catch (e) {
//       throw Exception("Failed to submit proforma invoice: $e");
//     }
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:nhapp/pages/proforma_invoice/models/add_proforma_invoice.dart';
// import 'package:nhapp/pages/quotation/models/create_quotation.dart';
// import '../../../utils/storage_utils.dart';

// class ProformaInvoiceService {
//   late final Dio _dio;
//   late final String _baseUrl;
//   late final Map<String, dynamic> _companyDetails;
//   late final Map<String, dynamic> _tokenDetails;
//   late final Map<String, dynamic> _locationDetails;
//   late int _companyId;

//   ProformaInvoiceService._();

//   static Future<ProformaInvoiceService> create() async {
//     final service = ProformaInvoiceService._();
//     await service._initializeService();
//     return service;
//   }

//   Future<void> _initializeService() async {
//     _baseUrl = "http://${await StorageUtils.readValue('url') ?? ""}";

//     _companyDetails = await StorageUtils.readJson('selected_company');
//     if (_companyDetails.isEmpty) throw Exception("Company not set");
//     _locationDetails = await StorageUtils.readJson('selected_location');
//     if (_locationDetails.isEmpty) throw Exception("Location not set");
//     _tokenDetails = await StorageUtils.readJson('session_token');
//     if (_tokenDetails.isEmpty) throw Exception("Session token not found");

//     _companyId = _companyDetails['id'];
//     final token = _tokenDetails['token']['value'];

//     _dio = Dio();
//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['companyid'] = _companyId.toString();
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   Future<DefaultDocumentDetail> fetchDefaultDocumentDetail(String type) async {
//     String endpoint = "";
//     if (type == "SQ") {
//       endpoint =
//           "/api/Lead/GetDefaultDocumentDetail?year=24-25&type=SQ&subType=SQ&locationId=8";
//     } else if (type == "OB") {
//       endpoint =
//           "/api/Lead/GetDefaultDocumentDetail?year=24-25&type=OB&subType=OB&locationId=8";
//     }

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return DefaultDocumentDetail.fromJson(response.data['data'][0]);
//   }

//   Future<List<Customer>> fetchCustomerSuggestions(String pattern) async {
//     const endpoint = "/api/Followup/FollowUpGetCustomer";
//     final body = {
//       "pageNumber": 1,
//       "pageSize": 10,
//       "sortField": "",
//       "sortDirection": "",
//       "searchValue": pattern,
//       "restcoresalestrans": "false",
//     };

//     final response = await _dio.post("$_baseUrl$endpoint", data: body);
//     final data = response.data['data'] as List;
//     return data.map((item) => Customer.fromJson(item)).toList();
//   }

//   Future<List<QuotationNumber>> fetchQuotationNumberList(
//     String custCode,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetQuatationNumberList?fromLocationId=8&locationCode=8&year=24-25&group=QA&custCode=$custCode";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     final data = response.data['data'] as List;
//     return data.map((item) => QuotationNumber.fromJson(item)).toList();
//   }

//   Future<List<SalesOrderNumber>> fetchSalesOrderNumberList(
//     String custCode,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetSONumberList?fromLocationId=8&locationCode=8&year=24-25&group=SO&custCode=$custCode";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     final data = response.data['data'] as List;
//     return data.map((item) => SalesOrderNumber.fromJson(item)).toList();
//   }

//   Future<QuotationDetails> fetchQuotationDetails(String quotationNumber) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetModelItemDetails_Quatation?PILocationId=8&year=24-25&groupCode=QA&SONumber=$quotationNumber&srNo=0";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return QuotationDetails.fromJson(response.data['data']);
//   }

//   Future<SalesOrderDetails> fetchSalesOrderDetails(
//     String salesOrderNumber,
//   ) async {
//     final endpoint =
//         "/api/Proforma/proformaInvoiceGetModelItemDetails_SO?PILocationId=8&year=24-25&groupCode=SO&SONumber=$salesOrderNumber&srNo=1";

//     final response = await _dio.get("$_baseUrl$endpoint");
//     return SalesOrderDetails.fromJson(response.data['data']);
//   }

//   Future<List<SalesItem>> fetchSalesItemList(String pattern) async {
//     const endpoint = "/api/Lead/GetSalesItemList?flag=L";
//     final body = {
//       "pageSize": 10,
//       "pageNumber": 1,
//       "sortField": "",
//       "sortDirection": "",
//       "searchValue": pattern,
//     };

//     final response = await _dio.post("$_baseUrl$endpoint", data: body);
//     final data = response.data['data'] as List;
//     return data.map((item) => SalesItem.fromJson(item)).toList();
//   }

//   Future<List<RateStructure>> fetchRateStructures(int companyId) async {
//     const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";

//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails.isEmpty) {
//       throw Exception("Company details not found");
//     }
//     final companyId = companyDetails['id'] ?? 0;
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails.isEmpty) {
//       throw Exception("Session token not found");
//     }
//     final token = tokenDetails['token']['value'] ?? '';

//     _dio.options.headers['companyid'] = companyId.toString();
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';

//     final response = await _dio.get(
//       "$_baseUrl$endpoint",
//       queryParameters: {
//         'companyID': companyId.toString(),
//         'currencyCode': 'INR',
//       },
//     );
//     final data = response.data['data'] as List;
//     return data.map((item) => RateStructure.fromJson(item)).toList();
//   }

//   Future<List<Map<String, dynamic>>> fetchRateStructureDetails(
//     String rateStructureCode,
//   ) async {
//     final endpoint =
//         "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
//     final response = await _dio.get("$_baseUrl$endpoint");
//     return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
//   }

//   Future<Map<String, dynamic>> calculateRateStructure(
//     double itemAmount,
//     String rateStructureCode,
//     List<Map<String, dynamic>> rateStructureDetails,
//     String itemCode,
//   ) async {
//     const endpoint = "/api/Quotation/CalcRateStructure";
//     final body = {
//       "ItemAmount": itemAmount,
//       "ExchangeRt": "1",
//       "DomCurrency": "INR",
//       "CurrencyCode": "INR",
//       "DiscType": "",
//       "BasicRate": 0,
//       "DiscValue": 0,
//       "From": "sales",
//       "Flag": "",
//       "TotalItemAmount": itemAmount,
//       "LandedPrice": 0,
//       "uniqueno": 0,
//       "RateCode": rateStructureCode,
//       "RateStructureDetails":
//           rateStructureDetails
//               .map((e) => {...e, "itemCode": itemCode})
//               .toList(),
//       "rateType": "S",
//       "IsView": false,
//     };

//     final response = await _dio.post(
//       "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
//       data: body,
//     );
//     return response.data;
//   }

//   Future<bool> submitProformaInvoice(Map<String, dynamic> payload) async {
//     const endpoint = "/api/Proforma/SubmitProformaInvoice";
//     try {
//       final response = await _dio.post("$_baseUrl$endpoint", data: payload);
//       return response.data['success'] == true;
//     } catch (e) {
//       throw Exception("Failed to submit proforma invoice: $e");
//     }
//   }
// }

//------------------------------------------------------------------------------

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

  Future<bool> submitProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryCreate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data['success'] == true;
    } catch (e) {
      throw Exception("Failed to submit proforma invoice: $e");
    }
  }

  Future<bool> updateProformaInvoice(Map<String, dynamic> payload) async {
    const endpoint = "/api/Proforma/proformaInvoiceEntryUpdate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data['success'] == true;
    } catch (e) {
      throw Exception("Failed to update proforma invoice: $e");
    }
  }
}
