// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class SalesOrderService {
//   final Dio _dio = Dio();
//   String? _baseUrl;
//   Map<String, dynamic>? _companyDetails;
//   Map<String, dynamic>? _locationDetails;
//   Map<String, dynamic>? _tokenDetails;
//   Map<String, dynamic>? _financialYear;
//   bool _initialized = false;

//   Future<void> _initialize() async {
//     if (_initialized) return;
//     _baseUrl = "http://${await StorageUtils.readValue('url') ?? ''}";
//     _companyDetails = await StorageUtils.readJson('selected_company');
//     _locationDetails = await StorageUtils.readJson('selected_location');
//     _tokenDetails = await StorageUtils.readJson('session_token');
//     _financialYear = await StorageUtils.readJson('finance_period');
//     _initialized = true;
//   }

//   Future<void> _setHeaders() async {
//     await _initialize();
//     if (_tokenDetails == null || _tokenDetails!.isEmpty) {
//       throw Exception("Session token not found");
//     }
//     final token = _tokenDetails!['token']['value'];
//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   Future<List<SalesOrderData>> fetchSalesOrderList({
//     required int page,
//     required int pageSize,
//     String? searchValue,
//   }) async {
//     await _initialize();
//     final year = _financialYear?['financialYear'] ?? '';
//     final companyId = _companyDetails?['id'];
//     final companyCode = _companyDetails?['code'];
//     final siteId = _locationDetails?['id'];
//     final user = _tokenDetails?['user']?["userName"];
//     if (companyId == null ||
//         companyCode == null ||
//         siteId == null ||
//         user == null) {
//       throw Exception("Missing required details");
//     }
//     await _setHeaders();
//     _dio.options.headers['CompanyId'] = companyId;

//     final endpoint = '/api/SalesOrder/salesOrderGetListPendAuth';

//     final body = {
//       "year": year,
//       "type": "OB",
//       "subType": "OB",
//       "locId": siteId,
//       "userId": user,
//       "comCode": companyCode,
//       "flag": "SITEID",
//       "pageSize": pageSize,
//       "pageNumber": page,
//       "sortField": "",
//       "sortDirection": "asc",
//       "searchValue": searchValue ?? "",
//       "restcoresalestrans": "false",
//       "companyId": companyId,
//       "usrLvl": 0,
//       "usrSubLvl": 0,
//       "valLimit": 0,
//     };

//     final response = await _dio.post('$_baseUrl$endpoint', data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       final List<dynamic> data = response.data['data']?['solist'] ?? [];
//       return await compute(_parseSalesOrderList, data);
//     } else {
//       throw Exception('Failed to load sales order list');
//     }
//   }

//   static List<SalesOrderData> _parseSalesOrderList(List<dynamic> data) {
//     return data
//         .map((e) => SalesOrderData.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }

//   Future<String> fetchSalesOrderPdfUrl(SalesOrderData so) async {
//     await _initialize();
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = _companyDetails;
//     final locationDetails = _locationDetails;
//     final tokenDetails = _tokenDetails;
//     if (companyDetails == null) throw Exception("Company not set");
//     if (locationDetails == null) throw Exception("Location not set");
//     if (tokenDetails == null) throw Exception("Session token not found");
//     final domCurrency = await StorageUtils.readJson('domestic_currency');
//     if (domCurrency == null) throw Exception("Domestic currency not set");

//     final currencyCode = domCurrency['domCurCode'] ?? 'INR';
//     final domCurDesc = domCurrency['domCurDesc'] ?? 'Indian Rupee';
//     final domCurNomin = domCurrency['domCurNomin'] ?? 'INR';

//     final companyId = companyDetails['id'];
//     final companyCode = companyDetails['code'];
//     final userId = tokenDetails['user']["id"];

//     await _setHeaders();
//     _dio.options.headers['CompanyId'] = companyId;

//     final endpoint = '/api/SalesOrder/SalesOrderPrint';

//     final body = {
//       "site": so.siteId,
//       "selectitem": so.customerFullName,
//       "valuetype": "withvalue",
//       "printtype": "word",
//       "AutoId": so.orderId,
//       "LocCode": so.siteCode,
//       "SalYear": so.ioYear,
//       "SalGrp": so.ioGroup,
//       "SalNo": so.ioNumber,
//       "CmpCode": companyCode,
//       "intSiteId": so.siteId,
//       "intCompId": companyId,
//       "companyData": companyDetails,
//       "userid": userId,
//       "strDomCurrency": currencyCode,
//       "strDomCurrencyDNOMITN": domCurNomin,
//       "strDomCurrencyDesc": domCurDesc,
//       "FormID": "06106",
//       "reportselection": "withvalue",
//       "techspec": "multiline",
//     };

//     final response = await _dio.post('http://$url$endpoint', data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       return response.data['data'] ?? '';
//     } else {
//       throw Exception('Failed to fetch PDF');
//     }
//   }

//   Future<bool> authorizeSalesOrder(SalesOrderData so) async {
//     await _initialize();
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = _companyDetails;
//     if (companyDetails == null) throw Exception("Company not set");

//     final companyId = companyDetails['id'];

//     await _setHeaders();
//     _dio.options.headers['CompanyId'] = companyId;

//     final endpoint = '/api/SalesOrder/salesOrderAuthPendData';

//     final body = [
//       {
//         "OrderId": so.orderId,
//         "fromLocationId": so.siteId,
//         "AuthDate": DateTime.now().toIso8601String(),
//         "fromLocationCode": so.siteCode,
//         "fromLocationName": so.siteFullName,
//         "Year": so.ioYear,
//         "GroupCode": so.ioGroup,
//         "OrderNo": so.ioNumber,
//         "SiteId": so.siteId,
//         "SiteCode": so.siteCode,
//         "CustomerFullName": so.customerFullName,
//       },
//     ];

//     final response = await _dio.post("http://$url$endpoint", data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       return true;
//     } else {
//       return false;
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

class SalesOrderService {
  final Dio _dio = Dio();
  String? _baseUrl;
  Map<String, dynamic>? _companyDetails;
  Map<String, dynamic>? _locationDetails;
  Map<String, dynamic>? _tokenDetails;
  Map<String, dynamic>? _financialYear;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    _baseUrl = "http://${await StorageUtils.readValue('url') ?? ''}";
    _companyDetails = await StorageUtils.readJson('selected_company');
    _locationDetails = await StorageUtils.readJson('selected_location');
    _tokenDetails = await StorageUtils.readJson('session_token');
    _financialYear = await StorageUtils.readJson('finance_period');
    _initialized = true;
  }

  Future<void> _setHeaders() async {
    await _initialize();
    if (_tokenDetails == null || _tokenDetails!.isEmpty) {
      throw Exception("Session token not found");
    }
    final token = _tokenDetails!['token']['value'];
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<List<SalesOrderData>> fetchSalesOrderList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    await _initialize();
    final year = _financialYear?['financialYear'] ?? '';
    final companyId = _companyDetails?['id'];
    final companyCode = _companyDetails?['code'];
    final siteId = _locationDetails?['id'];
    final user = _tokenDetails?['user']?["userName"];
    if (companyId == null ||
        companyCode == null ||
        siteId == null ||
        user == null) {
      throw Exception("Missing required details");
    }
    await _setHeaders();
    _dio.options.headers['CompanyId'] = companyId;

    final endpoint = '/api/SalesOrder/salesOrderGetListPendAuth';

    final body = {
      "year": year,
      "type": "OB",
      "subType": "OB",
      "locId": siteId,
      "userId": user,
      "comCode": companyCode,
      "flag": "SITEID",
      "pageSize": pageSize,
      "pageNumber": page,
      "sortField": "",
      "sortDirection": "asc",
      "searchValue": searchValue ?? "",
      "restcoresalestrans": "false",
      "companyId": companyId,
      "usrLvl": 0,
      "usrSubLvl": 0,
      "valLimit": 0,
    };

    final response = await _dio.post('$_baseUrl$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data']?['solist'] ?? [];
      return await compute(_parseSalesOrderList, data);
    } else {
      throw Exception('Failed to load sales order list');
    }
  }

  static List<SalesOrderData> _parseSalesOrderList(List<dynamic> data) {
    return data
        .map((e) => SalesOrderData.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<String> fetchSalesOrderPdfUrl(SalesOrderData so) async {
    await _initialize();
    final url = await StorageUtils.readValue('url');
    final companyDetails = _companyDetails;
    final locationDetails = _locationDetails;
    final tokenDetails = _tokenDetails;
    if (companyDetails == null) throw Exception("Company not set");
    if (locationDetails == null) throw Exception("Location not set");
    if (tokenDetails == null) throw Exception("Session token not found");
    final domCurrency = await StorageUtils.readJson('domestic_currency');
    if (domCurrency == null) throw Exception("Domestic currency not set");

    final currencyCode = domCurrency['domCurCode'] ?? 'INR';
    final domCurDesc = domCurrency['domCurDesc'] ?? 'Indian Rupee';
    final domCurNomin = domCurrency['domCurNomin'] ?? 'INR';

    final companyId = companyDetails['id'];
    final companyCode = companyDetails['code'];
    final userId = tokenDetails['user']["id"];

    await _setHeaders();
    _dio.options.headers['CompanyId'] = companyId;

    final endpoint = '/api/SalesOrder/SalesOrderPrint';

    final body = {
      "site": so.siteId,
      "selectitem": so.customerFullName,
      "valuetype": "withvalue",
      "printtype": "word",
      "AutoId": so.orderId,
      "LocCode": so.siteCode,
      "SalYear": so.ioYear,
      "SalGrp": so.ioGroup,
      "SalNo": so.ioNumber,
      "CmpCode": companyCode,
      "intSiteId": so.siteId,
      "intCompId": companyId,
      "companyData": companyDetails,
      "userid": userId,
      "strDomCurrency": currencyCode,
      "strDomCurrencyDNOMITN": domCurNomin,
      "strDomCurrencyDesc": domCurDesc,
      "FormID": "06106",
      "reportselection": "withvalue",
      "techspec": "multiline",
    };

    final response = await _dio.post('http://$url$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }

  Future<bool> authorizeSalesOrder(SalesOrderData so) async {
    await _initialize();
    final url = await StorageUtils.readValue('url');
    final companyDetails = _companyDetails;
    if (companyDetails == null) throw Exception("Company not set");

    final companyId = companyDetails['id'];

    await _setHeaders();
    _dio.options.headers['CompanyId'] = companyId;

    final endpoint = '/api/SalesOrder/salesOrderAuthPendData';

    final body = [
      {
        "OrderId": so.orderId,
        "fromLocationId": so.siteId,
        "AuthDate": DateTime.now().toIso8601String(),
        "fromLocationCode": so.siteCode,
        "fromLocationName": so.siteFullName,
        "Year": so.ioYear,
        "GroupCode": so.ioGroup,
        "OrderNo": so.ioNumber,
        "SiteId": so.siteId,
        "SiteCode": so.siteCode,
        "CustomerFullName": so.customerFullName,
      },
    ];

    final response = await _dio.post("http://$url$endpoint", data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Sales Order Authorized Successfully");
      debugPrint("Response: ${response.data}");
      return true;
    } else {
      debugPrint("Failed to authorize Sales Order");
      debugPrint("Response: ${response.data}");
      return false;
    }
  }

  Future<bool> authorizeSalesOrderBatch(List<SalesOrderData> soList) async {
    await _initialize();
    final url = await StorageUtils.readValue('url');
    final companyDetails = _companyDetails;
    if (companyDetails == null) throw Exception("Company not set");

    final companyId = companyDetails['id'];

    await _setHeaders();
    _dio.options.headers['CompanyId'] = companyId;

    final endpoint = '/api/SalesOrder/salesOrderAuthPendData';

    final body =
        soList
            .map(
              (so) => {
                "OrderId": so.orderId,
                "fromLocationId": so.siteId,
                "AuthDate": DateTime.now().toIso8601String(),
                "fromLocationCode": so.siteCode,
                "fromLocationName": so.siteFullName,
                "Year": so.ioYear,
                "GroupCode": so.ioGroup,
                "OrderNo": so.ioNumber,
                "SiteId": so.siteId,
                "SiteCode": so.siteCode,
                "CustomerFullName": so.customerFullName,
              },
            )
            .toList();

    final response = await _dio.post("http://$url$endpoint", data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Batch Sales Order Authorized Successfully");
      return true;
    } else {
      debugPrint("Failed to authorize batch Sales Order");
      return false;
    }
  }
}
