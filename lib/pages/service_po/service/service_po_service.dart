// import 'package:dio/dio.dart';
// import 'package:nhapp/pages/service_po/models/service_po_data.dart';
// import 'package:nhapp/utils/storage_utils.dart';

// class ServicePOService {
//   final Dio _dio = Dio();

//   Future<List<ServicePOData>> fetchServicePOListPaged({
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
//     final locationId = locationDetails['id'];
//     final token = tokenDetails['token']['value'];

//     final String endpoint = '/api/Podata/servicePOList';

//     final body = {
//       "pageNumber": page,
//       "pageSize": pageSize,
//       "sortField": "",
//       "sortDirection": "",
//       "searchValue": searchValue,
//     };

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['companyid'] = companyId.toString();
//     _dio.options.headers['Authorization'] = 'Bearer $token';

//     final response = await _dio.post(
//       "http://$url$endpoint",
//       data: body,
//       queryParameters: {"locationId": locationId.toString()},
//     );
//     if (response.statusCode == 200 && response.data['success'] == true) {
//       final List<dynamic> data = response.data['data'] ?? [];
//       print("Service PO List: $data");
//       return data.map((e) => ServicePOData.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load Service PO list');
//     }
//   }

//   Future<String> fetchServicePOPdfUrl(ServicePOData po) async {
//     final endpoint = '/api/Podata/poGetPrint_Service';

//     final body = {
//       "rbtDraft": false,
//       "rbtFinal": true,
//       "FormID": "01125",
//       "strPoNumber": po.id.toString(),
//       "companyData": {
//         "id": 1,
//         "name": "Cybernetik Technologies Pvt Ltd",
//         "code": "CTL",
//         "companyFullName": null,
//         "siplCode": "EIRICH",
//         "compCountry": "IND",
//         "strConnstring":
//             "Server=PC87;Database=NH1Cybernetik210722;uid=sa;pwd=;Connection TimeOut=3000;",
//         "externalFinancialSystemIntegration": "Y",
//         "depreciationCalculationMethod": "W",
//       },
//       "locationData": {
//         "id": po.siteid,
//         "isDefault": true,
//         "name": po.site,
//         "code": po.sitecode,
//         "companyCode": "CTL",
//         "gstRegNo": "",
//         "stateGSTCode": "24",
//         "isShowSwipColumn": false,
//       },
//       "strDomCurrency": "INR",
//       "SiteCode": po.sitecode,
//       "GSTDateTimeTemp": "01/07/2017",
//     };

//     final response = await _dio.post(endpoint, data: body);
//     if (response.statusCode == 200 && response.data['success'] == true) {
//       return response.data['data'] ?? '';
//     } else {
//       throw Exception('Failed to fetch PDF');
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/service_po/models/service_po_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

class ServicePOService {
  final Dio _dio = Dio();

  Future<List<ServicePOData>> fetchServicePOListPaged({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];

    final String endpoint = '/api/Podata/servicePOList';
    final body = {
      "pageNumber": page,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue,
    };

    try {
      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['companyid'] = companyId.toString();
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.post(
        "http://$url$endpoint",
        data: body,
        queryParameters: {
          "locationIds": locationId.toString(), // Set headers here
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        debugPrint("Service PO List: $data");
        // Parse in background isolate for large lists
        return await compute(_parseServicePOList, data);
      } else {
        throw Exception('Failed to load Service PO list');
      }
    } catch (e) {
      rethrow;
    }
  }

  static List<ServicePOData> _parseServicePOList(List<dynamic> data) {
    return data.map((e) => ServicePOData.fromJson(e)).toList();
  }

  Future<String> fetchServicePOPdfUrl(ServicePOData po) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final domCurrency = await StorageUtils.readJson('domestic_currency');
    final currencyCode = domCurrency?['domCurCode'] ?? 'INR';

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    final endpoint = '/api/Podata/poGetPrint_Service';

    final body = {
      "rbtDraft": false,
      "rbtFinal": true,
      "FormID": "01125",
      "strPoNumber": po.id.toString(),
      "companyData": companyDetails,
      "locationData": locationDetails,
      "strDomCurrency": currencyCode,
      "SiteCode": po.sitecode,
      "GSTDateTimeTemp": "01/07/2017",
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post("http://$url$endpoint", data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }
}
