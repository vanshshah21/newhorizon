import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/authorize_labor_purchase_order/model/labor_po_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

List<LaborPOData> parseLaborPOList(List<Map<String, dynamic>> data) {
  return data.map((e) => LaborPOData.fromJson(e)).toList();
}

class LaborPOService {
  final Dio _dio = Dio();

  Future<List<LaborPOData>> fetchLaborPOList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    debugPrint("Fetching Auth Labor PO List");
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

    final endpoint = '/api/Podata/labourPOPendAuthList';

    final body = {
      "pageNumber": page,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue,
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post(
      'http://$url$endpoint',
      data: body,
      queryParameters: {"locationIds": locationId.toString()},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Response Data: ${response.data}");
      final List<dynamic> data = response.data['data'] ?? [];
      // return data.map((e) => LaborPOData.fromJson(e)).toList();
      return await compute(
        parseLaborPOList,
        List<Map<String, dynamic>>.from(data),
      );
    } else {
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Error: ${response.data['message']}");
      throw Exception('Failed to load labor PO list');
    }
  }

  Future<String> fetchLaborPOPdfUrl(LaborPOData po) async {
    debugPrint("Fetching Auth Labor PO PDF");
    debugPrint("PO ID: ${po.id}");
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

    final endpoint = '/api/Podata/poGetPrint_LabourRate';

    final body = {
      "POData": [po.pdfPOBody()],
      "companyData": companyDetails,
      "locationData": locationDetails,
      "typeCopyControl": "1",
      "strDomCurrency": currency,
      "FormID": "01109",
      "typeSelection": "R",
      "GSTDateTimeTemp": "01/07/2017",
      "blnpocomparision_fabcon": false,
      "printtype": "pdf",
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("PDF URL Response: ${response.data}");
      return response.data['data'] ?? '';
    } else {
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Error: ${response.data['message']}");
      throw Exception('Failed to fetch PDF');
    }
  }

  // Future<bool> authorizeLaborPO(LaborPOData po) async {
  //   debugPrint("Authorizing Labor PO");
  //   debugPrint("PO ID: ${po.id}");
  //   final url = await StorageUtils.readValue('url');

  //   final companyDetails = await StorageUtils.readJson('selected_company');
  //   if (companyDetails == null) throw Exception("Company not set");

  //   final locationDetails = await StorageUtils.readJson('selected_location');
  //   if (locationDetails == null) throw Exception("Location not set");

  //   final tokenDetails = await StorageUtils.readJson('session_token');
  //   if (tokenDetails == null) throw Exception("Session token not found");

  //   final companyId = companyDetails['id'];
  //   final locationId = locationDetails['id'];
  //   final locationCode = locationDetails['code'];
  //   final locationName = locationDetails['name'];
  //   final token = tokenDetails['token']['value'];

  //   final endpoint = '/api/Podata/labourPOAuth';

  //   final body = {
  //     "strDoctyp": "PR",
  //     "strFormTyp": "A",
  //     "FormID": "01106",
  //     "fromlocationid": locationId,
  //     "fromlocationcode": locationCode,
  //     "fromlocationname": locationName,
  //     "poAuthoriseList": [
  //       {po.authPOBody()},
  //     ],
  //   };

  //   _dio.options.headers['Content-Type'] = 'application/json';
  //   _dio.options.headers['Accept'] = 'application/json';
  //   _dio.options.headers['companyid'] = companyId.toString();
  //   _dio.options.headers['Authorization'] = 'Bearer $token';

  //   final response = await _dio.post('http://$url$endpoint', data: body);
  //   if (response.statusCode == 200 && response.data['success'] == true) {
  //     debugPrint("Authorization successful");
  //     return true;
  //   } else {
  //     debugPrint("Authorization failed");
  //     return false;
  //   }
  // }
  Future<bool> authorizeLaborPO(LaborPOData po) async {
    debugPrint("Authorizing Labor PO");
    debugPrint("PO ID: ${po.id}");
    final url = await StorageUtils.readValue('url');

    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final locationCode = locationDetails['code'];
    final locationName = locationDetails['name'];
    final token = tokenDetails['token']['value'];

    final endpoint = '/api/Podata/labourPOAuth';

    final body = {
      "strDoctyp": "PR",
      "strFormTyp": "A",
      "FormID": "01106",
      "fromlocationid": locationId,
      "fromlocationcode": locationCode,
      "fromlocationname": locationName,
      "poAuthoriseList": [
        po.authPOBody(), // Remove the curly braces
      ],
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Authorization successful");
      return true;
    } else {
      debugPrint("Authorization failed");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Error: ${response.data}");
      return false;
    }
  }

  Future<bool> authorizeBulkLaborPO(List<LaborPOData> poList) async {
    debugPrint("Authorizing Multiple Labor POs");
    debugPrint("Count: ${poList.length}");
    final url = await StorageUtils.readValue('url');

    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final locationCode = locationDetails['code'];
    final locationName = locationDetails['name'];
    final token = tokenDetails['token']['value'];

    final endpoint = '/api/Podata/labourPOAuth';

    final body = {
      "strDoctyp": "PR",
      "strFormTyp": "A",
      "FormID": "01106",
      "fromlocationid": locationId,
      "fromlocationcode": locationCode,
      "fromlocationname": locationName,
      "poAuthoriseList": poList.map((po) => po.authPOBody()).toList(),
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Bulk authorization successful");
      return true;
    } else {
      debugPrint("Bulk authorization failed");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Error: ${response.data}");
      return false;
    }
  }
}
