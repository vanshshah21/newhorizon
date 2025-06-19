// lib/services/authorize_po_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/authorize_purchase_order/models/authorize_po_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

List<POData> parsePODataList(List<Map<String, dynamic>> data) {
  return data.map((e) => POData.fromJson(e)).toList();
}

class AuthorizePOService {
  final Dio _dio = Dio();

  Future<List<POData>> fetchPendingAuthPOList({
    required bool isRegular,
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    debugPrint("Fetching Pending Auth PO List");
    debugPrint("Page: $page, PageSize: $pageSize, SearchValue: $searchValue");

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
    final userId = tokenDetails['user']['id'];

    final body = {
      "pageNumber": page,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue,
      "potype": isRegular ? "'R'" : "'C'",
      "usrLvl": 0,
      "usrSubLvl": 0,
      "mulLvlAuthRed": false,
      "valLimit": 0,
      "docType": "PR",
      "docSubType": isRegular ? "RP" : "CP",
      "companyId": companyId,
      "userId": userId,
    };

    final String endpoint = '/api/Podata/FetchPendingAuthPOList';

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';
    final response = await _dio.post(
      "http://$url$endpoint",
      data: body,
      queryParameters: {
        "locationId": locationId,
        "companyId": companyId,
        "locIds": locationId.toString(),
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      // return data.map((e) => POData.fromJson(e)).toList();
      return await compute(
        parsePODataList,
        List<Map<String, dynamic>>.from(data),
      );
    } else {
      throw Exception('Failed to load pending PO list');
    }
  }

  Future<String> fetchPOPdfUrl(POData po, bool isRegular) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    final endpoint =
        isRegular
            ? '/api/Podata/poGetPrint_Regular'
            : '/api/Podata/poGetPrint_Capital';

    final body = {
      "POData": [po.toJsonForPrint()],
      "companyData": companyDetails,
      "locationData": locationDetails,
      "typeCopyControl": "1",
      "strDomCurrency": "INR",
      "FormID": "01109",
      "typeSelection": "P",
      "GSTDateTimeTemp": "01/07/2017",
      "blnpocomparision_fabcon": true,
      "blnpoitemwisestock_fabcon": true,
      "strtctype": "GEN",
      "printtype": "pdf",
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post("http://$url$endpoint", data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }

  Future<bool> authorizePO(POData po, bool isRegular) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final authorizeBody = {
      "strDoctyp": "PR",
      "strSubtyp": "RP",
      "strFormTyp": "A",
      "FormID": "01107",
      "fromlocationid": locationDetails['id'],
      "fromlocationcode": locationDetails['code'],
      "fromlocationname": locationDetails['name'],
      "docLevel": 0,
      "docSubLevel": 0,
      "mulLvlauthred": false,
      "maxlevel": false,
      "poAuthoriseList": [po.toJsonForAuthorize()],
    };
    final endpoint = '/api/Podata/AuthPurOrder';
    final response = await _dio.post(
      "http://$url$endpoint",
      data: authorizeBody,
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("PO Authorized Successfully");
      debugPrint("Response: ${response.data}");
      return true;
    } else {
      debugPrint("Failed to authorize PO");
      debugPrint("Response: ${response.data}");
      return false;
    }
  }
}
