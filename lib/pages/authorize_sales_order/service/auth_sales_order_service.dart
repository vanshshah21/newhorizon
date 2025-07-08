// // sales_order_service.dart
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class SalesOrderService {
//   final Dio _dio = Dio();

//   late String _year;

//   Future<String> fetchFinancialYearForSite(int companyId, int siteId) async {
//     final url = await StorageUtils.readValue('url');
//     final tokendetails = await StorageUtils.readJson('session_token');
//     if (tokendetails == null) throw Exception("Session token not found");

//     final token = tokendetails['token']['value'];

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';

//     final endpoint = '/api/Login/GetCompanyCurrentYearDatesData';

//     final response = await _dio.get(
//       'http://$url$endpoint',
//       queryParameters: {"companyid": companyId},
//     );
//     if (response.statusCode == 200 && response.data['success'] == true) {
//       final List<dynamic> settings =
//           response.data['data']['financePeriodSetting'] ?? [];
//       final match = settings.firstWhere(
//         (e) => e['siteId'] == siteId,
//         orElse: () => null,
//       );
//       if (match != null && match['financialYear'] != null) {
//         _year = match['financialYear'];
//         return match['financialYear'];
//       } else {
//         throw Exception('Financial year not found for site $siteId');
//       }
//     } else {
//       throw Exception('Failed to fetch financial year');
//     }
//   }

//   Future<List<SalesOrderData>> fetchSalesOrderList({
//     required int page,
//     required int pageSize,
//     String? searchValue,
//   }) async {
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) throw Exception("Company not set");
//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) throw Exception("Location not set");
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) throw Exception("Session token not found");

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];
//     final user = tokenDetails['user']["userName"];
//     final String year =
//         _year.isNotEmpty
//             ? _year
//             : await fetchFinancialYearForSite(companyId, locationDetails['id']);

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['CompanyId'] = companyId;

//     final endpoint = '/api/SalesOrder/salesOrderGetListPendAuth';

//     final body = {
//       "year": year,
//       "type": "OB",
//       "subType": "OB",
//       "locId": locationDetails['id'],
//       "userId": user,
//       "comCode": companyDetails['code'],
//       "flag": "SITEID",
//       "pageSize": pageSize,
//       "pageNumber": page,
//       "sortField": "",
//       "sortDirection": "asc",
//       "searchValue": searchValue ?? "",
//       "restcoresalestrans": "false",
//       "companyId": companyDetails['id'],
//       "usrLvl": 0,
//       "usrSubLvl": 0,
//       "valLimit": 0,
//     };

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['CompanyId'] = companyId;

//     final response = await _dio.post('http://$url$endpoint', data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       final List<dynamic> data = response.data['data']?['solist'] ?? [];
//       return await compute(
//         (list) => list.map((e) => SalesOrderData.fromJson(e)).toList(),
//         List<Map<String, dynamic>>.from(data),
//       );
//     } else {
//       throw Exception('Failed to load sales order list');
//     }
//   }

//   Future<String> fetchSalesOrderPdfUrl(SalesOrderData so) async {
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) throw Exception("Company not set");
//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) throw Exception("Location not set");
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) throw Exception("Session token not found");

//     final companyId = companyDetails['id'];
//     final companyCode = companyDetails['code'];
//     final token = tokenDetails['token']['value'];
//     final userId = tokenDetails['user']["id"];

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
//       "strDomCurrency": "INR",
//       "strDomCurrencyDNOMITN": "INR",
//       "strDomCurrencyDesc": "Indian Rupee",
//       "FormID": "06106",
//       "reportselection": "withvalue",
//       "techspec": "multiline",
//     };

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['CompanyId'] = companyId;

//     final response = await _dio.post('http://$url$endpoint', data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       return response.data['data'] ?? '';
//     } else {
//       throw Exception('Failed to fetch PDF');
//     }
//   }

//   Future<bool> authorizeSalesOrder(SalesOrderData so) async {
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) throw Exception("Company not set");
//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) throw Exception("Location not set");
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) throw Exception("Session token not found");

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token']['value'];

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

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['CompanyId'] = companyId;

//     final response = await _dio.post('http://$url$endpoint', data: body);

//     if (response.statusCode == 200 && response.data['success'] == true) {
//       return true;
//     } else {
//       return false;
//     }
//   }
// }

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:nhapp/pages/authorize_sales_order/models/sales_order_pend_auth_data.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class SalesOrderService {
//   final Dio _dio = Dio();
//   late String _baseUrl;
//   late Map<String, dynamic> _companyDetails;
//   late Map<String, dynamic> _locationDetails;
//   late Map<String, dynamic> _tokenDetails;
//   late Map<String, dynamic> _financialYear;

//   SalesOrderService() {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     _baseUrl = "http://${await StorageUtils.readValue('url') ?? ''}";
//     _companyDetails = await StorageUtils.readJson('selected_company');
//     _locationDetails = await StorageUtils.readJson('selected_location');
//     _tokenDetails = await StorageUtils.readJson('session_token');
//     _financialYear = await StorageUtils.readJson('finance_period');
//   }

//   // Helper to set headers
//   Future<void> _setHeaders() async {
//     if (_tokenDetails.isEmpty) throw Exception("Session token not found");
//     final token = _tokenDetails['token']['value'];

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//   }

//   // Fetch and cache the financial year for a site
//   // Future<String> fetchFinancialYearForSite(int companyId, int siteId) async {
//   //   if (_cachedYear != null &&
//   //       _cachedCompanyId == companyId &&
//   //       _cachedSiteId == siteId) {
//   //     return _cachedYear!;
//   //   }
//   //   await _setHeaders();
//   //   final url = _url.isNotEmpty ? _url : await StorageUtils.readValue('url');
//   //   final endpoint = '/api/Login/GetCompanyCurrentYearDatesData';
//   //   final response = await _dio.get(
//   //     'http://$url$endpoint',
//   //     queryParameters: {"companyid": companyId},
//   //   );
//   //   if (response.statusCode == 200 && response.data['success'] == true) {
//   //     final List<dynamic> settings =
//   //         response.data['data']['financePeriodSetting'] ?? [];
//   //     final match = settings.firstWhere(
//   //       (e) => e['siteId'] == siteId,
//   //       orElse: () => null,
//   //     );
//   //     if (match != null && match['financialYear'] != null) {
//   //       _cachedYear = match['financialYear'];
//   //       _cachedCompanyId = companyId;
//   //       _cachedSiteId = siteId;
//   //       return _cachedYear!;
//   //     } else {
//   //       throw Exception('Financial year not found for site $siteId');
//   //     }
//   //   } else {
//   //     throw Exception('Failed to fetch financial year');
//   //   }
//   // }

//   Future<List<SalesOrderData>> fetchSalesOrderList({
//     required int page,
//     required int pageSize,
//     String? searchValue,
//   }) async {
//     final year = _financialYear['financialYear'] ?? '';
//     final companyId = _companyDetails['id'];
//     final companyCode = _companyDetails['code'];
//     final siteId = _locationDetails['id'];
//     final user = _tokenDetails['user']["userName"];
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
//       // Use compute to parse in background
//       return await compute(_parseSalesOrderList, data);
//     } else {
//       throw Exception('Failed to load sales order list');
//     }
//   }

//   // Top-level function for compute
//   static List<SalesOrderData> _parseSalesOrderList(List<dynamic> data) {
//     return data
//         .map((e) => SalesOrderData.fromJson(Map<String, dynamic>.from(e)))
//         .toList();
//   }

//   Future<String> fetchSalesOrderPdfUrl(SalesOrderData so) async {
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
//     if (companyDetails == null) throw Exception("Company not set");
//     final locationDetails = await StorageUtils.readJson('selected_location');
//     if (locationDetails == null) throw Exception("Location not set");
//     final tokenDetails = await StorageUtils.readJson('session_token');
//     if (tokenDetails == null) throw Exception("Session token not found");

//     final companyId = companyDetails['id'];
//     final companyCode = companyDetails['code'];
//     final token = tokenDetails['token']['value'];
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
//       "strDomCurrency": "INR",
//       "strDomCurrencyDNOMITN": "INR",
//       "strDomCurrencyDesc": "Indian Rupee",
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
//     final url = await StorageUtils.readValue('url');
//     final companyDetails = await StorageUtils.readJson('selected_company');
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
      return true;
    } else {
      return false;
    }
  }
}
