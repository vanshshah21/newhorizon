import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nhapp/pages/purchase_order/model/po_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

class POService {
  final Dio _dio = Dio();

  Future<List<POData>> fetchPOListPaged({
    required bool isRegular,
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    debugPrint("Fetching PO List");
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
    final String endpoint =
        isRegular
            ? '/api/Podata/PurchasePOList_Regular'
            : '/api/Podata/PurchasePOList_Capital';

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post(
      "http://$url$endpoint",
      data: body,
      queryParameters: {
        "locIds": locationId.toString(),
        "locationId": locationId,
        "companyId": companyId,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint(
        "Response: ${response.data['data']}",
      ); // Debug print for response
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => POData.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load PO list');
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

    final domCurrency = await StorageUtils.readJson('domestic_currency');
    if (domCurrency == null) throw Exception("Domestic currency not set");

    final currency = domCurrency['domCurCode'] ?? 'INR';

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    final endpoint =
        isRegular
            ? '/api/Podata/poGetPrint_Regular'
            : '/api/Podata/poGetPrint_Capital';

    final body = {
      "POData": [po.toJson()],
      "companyData": companyDetails,
      "locationData": locationDetails,
      "typeCopyControl": "1",
      "strDomCurrency": currency,
      "FormID": "01109",
      "typeSelection": "P",
      "GSTDateTimeTemp": "01/07/2017",
      "strtctype": "GEN",
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
}
