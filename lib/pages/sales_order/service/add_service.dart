import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/sales_order/models/add_sales_order.dart';
import 'package:nhapp/utils/storage_utils.dart';

class SalesOrderService {
  late final Dio _dio;
  late final String _baseUrl;
  late final Map<String, dynamic> companyDetails;
  late final Map<String, dynamic> tokenDetails;
  late final Map<String, dynamic> locationDetails;
  late final Map<String, dynamic> financeDetails;
  late final Map<String, dynamic> QuotationDocumentDetails;
  late int companyId;

  SalesOrderService._();

  static Future<SalesOrderService> create() async {
    final service = SalesOrderService._();
    await service._initializeService();
    return service;
  }

  Future<void> _initializeService() async {
    _baseUrl = "http://${await StorageUtils.readValue('url') ?? ""}";

    companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails.isEmpty) throw Exception("Company not set");
    locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails.isEmpty) throw Exception("Location not set");
    tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails.isEmpty) throw Exception("Session token not found");
    financeDetails = await StorageUtils.readJson('finance_period');
    if (financeDetails.isEmpty) throw Exception("Finance details not found");

    companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio = Dio();
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    Future<void> fetchQuotationDocumentDetail(String type) async {
      String endpoint = "/api/Lead/GetDefaultDocumentDetail";
      final year = financeDetails['financialYear'];
      final locationId = locationDetails['id'];

      try {
        final response = await _dio.get(
          "$_baseUrl$endpoint",
          queryParameters: {
            "year": year,
            "type": type,
            "subType": type,
            "locationId": locationId,
          },
        );
        QuotationDocumentDetails = response.data['data'][0];
        return;
      } catch (e) {
        throw Exception("Failed to fetch document detail: $e");
      }
    }

    fetchQuotationDocumentDetail("SQ")
        .then((_) {
          // Document details fetched successfully
        })
        .catchError((error) {
          throw Exception("Failed to fetch quotation document details: $error");
        });
  }

  // --- API Methods ---

  Future<DocumentDetail> fetchDefaultDocumentDetail(String type) async {
    String endpoint = "/api/Lead/GetDefaultDocumentDetail";
    final year = financeDetails['financialYear'];
    final locationId = locationDetails['id'];

    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          "year": year,
          "type": type,
          "subType": type,
          "locationId": locationId,
        },
      );
      return DocumentDetail.fromJson(response.data['data'][0]);
    } catch (e) {
      throw Exception("Failed to fetch document detail: $e");
    }
  }

  Future<List<Customer>> fetchCustomerSuggestions(String pattern) async {
    const endpoint = "/api/Quotation/QuotationGetCustomer";
    final body = {
      "PageSize": 10,
      "PageNumber": 1,
      "SortField": "",
      "SortDirection": "",
      "SearchValue": pattern,
      "UserId": tokenDetails['user']['id'],
    };

    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: body);
      final data = response.data['data'] as List;
      return data.map((item) => Customer.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch customer suggestions: $e");
    }
  }

  // Future<List<QuotationNumber>> fetchQuotationNumberList(
  //   String custCode,
  // ) async {
  //   final endpoint = "/api/SalesOrder/salesOrderGetOpenQuotationListForSO";

  //   final response = await _dio.get(
  //     "$_baseUrl$endpoint",
  //     queryParameters: {
  //       "custCode": custCode,
  //       "locCode": locationDetails['code'],
  //     },
  //   );
  //   final data = response.data['data'];
  //   return data;
  // }

  // Future<QuotationDetails> fetchQuotationDetails(String quotationNumber) async {
  //   final groupcode = QuotationDocumentDetails['groupCode'];
  //   final endpoint = "/api/SalesOrder/salesOrderGetOpenQuotationDetailsForSO";

  //   final response = await _dio.post(
  //     "$_baseUrl$endpoint",
  //     queryParameters: {
  //       "PILocationId": locationDetails['id'],
  //       "year": financeDetails['financialYear'],
  //       "groupCode": groupcode,
  //       "SONumber": quotationNumber,
  //       "srNo": 0,
  //     },
  //   );
  //   debugPrint("Response: ${response.data}");
  //   return QuotationDetails.fromJson(response.data['data']);
  // }

  Future<QuotationListResponse> fetchQuotationNumberList(
    String custCode,
  ) async {
    final endpoint = "/api/SalesOrder/salesOrderGetOpenQuotationListForSO";

    final response = await _dio.get(
      "$_baseUrl$endpoint",
      queryParameters: {
        "custCode": custCode,
        "locCode": locationDetails['code'],
      },
    );

    return QuotationListResponse.fromJson(response.data['data']);
  }

  Future<QuotationDetails> fetchQuotationDetails(
    Map<String, dynamic> requestBody,
  ) async {
    final endpoint = "/api/SalesOrder/salesOrderGetOpenQuotationDetailsForSO";

    final response = await _dio.post("$_baseUrl$endpoint", data: requestBody);
    debugPrint("Response: ${response.data}");
    return QuotationDetails.fromJson(response.data['data']);
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

    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: body);
      final data = response.data['data'] as List;
      return data.map((item) => SalesItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch sales item list: $e");
    }
  }

  Future<List<RateStructure>> fetchRateStructures() async {
    const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";
    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          'companyID': companyId.toString(),
          'currencyCode': 'INR',
        },
      );
      final data = response.data['data'] as List;
      return data.map((item) => RateStructure.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch rate structures: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchRateStructureDetails(
    String rateStructureCode,
  ) async {
    final endpoint =
        "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      throw Exception("Failed to fetch rate structure details: $e");
    }
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

  List<Map<String, dynamic>> buildRateStructureDetails(
    List<Map<String, dynamic>> rateStructureRows,
    String itemCode,
    int itmModelRefNo,
  ) {
    return rateStructureRows.map((item) {
      return {
        'rateCode': item['msprtcd'] ?? '',
        'rateDesc': item['mprrtdesc'] ?? '',
        'ie': item['mspincexc'] ?? '',
        'pv': item['mspperval'] ?? '',
        'applicableOn': item['mtrslvlno'] ?? "",
        'appOnDisplay': item['mspappondesc'] ?? "",
        'taxValue': item['msprtval']?.toString() ?? "0.00",
        'prevTaxValue': item['msprtval']?.toString() ?? "0.00",
        'postnonpost': item['msppnyn'] == "True" || item['msppnyn'] == true,
        'rateAmount': 0.00,
        'currencyCode': item['mprcurcode'] ?? "INR",
        'itmModelRefNo': itmModelRefNo,
        'sequenceNo': item['mspseqno']?.toString() ?? "1",
        'taxType': item['mprtaxtyp'] ?? '',
        'itemCode': itemCode,
        'uniqueno': 0,
      };
    }).toList();
  }

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
      "rateType": "S",
      "IsView": false,
    };

    try {
      final response = await _dio.post(
        "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
        data: body,
      );
      return response.data;
    } catch (e) {
      throw Exception("Failed to calculate rate structure: $e");
    }
  }

  Future<Map<String, dynamic>> submitSalesOrder(
    Map<String, dynamic> payload,
  ) async {
    const endpoint = "/api/SalesOrder/salesOrderCreateEntry";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data;
    } catch (e) {
      throw Exception("Failed to submit sales order: $e");
    }
  }

  Future<Map<String, dynamic>> fetchSalesOrderDetails(
    String ioYear,
    String ioGroup,
    String ioSiteCode,
    String ioNumber,
    int locationId,
    int companyId,
  ) async {
    const endpoint = "/api/SalesOrder/salesOrderGetDetails";
    final body = {
      "IOYear": ioYear,
      "ioGroup": ioGroup,
      "IOSiteCode": ioSiteCode,
      "ioNumber": ioNumber,
      "locid": locationId.toString(),
      "mode": "SEARCH",
      "AuthReq": "Y",
      "IsInterBranchTransfer": false,
      "locationId": locationId,
      "compantid": companyId,
      "DomCurrency": "INR",
    };

    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: body);
      return response.data;
    } catch (e) {
      throw Exception("Failed to fetch sales order details: $e");
    }
  }

  Future<Map<String, dynamic>> updateSalesOrder(
    Map<String, dynamic> payload,
  ) async {
    const endpoint = "/api/SalesOrder/salesOrderUpdateEntry";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data;
    } catch (e) {
      throw Exception("Failed to update sales order: $e");
    }
  }

  Future<Map<String, dynamic>> getSalesPolicy() async {
    try {
      final companyCode = companyDetails['code'];
      const endpoint = "/api/Login/GetSalesPolicyDetails";
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: {"companyCode": companyCode},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['salesPolicyResultModel'][0]
            as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }
}
