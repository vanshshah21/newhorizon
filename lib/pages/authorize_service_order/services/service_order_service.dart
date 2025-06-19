import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/authorize_service_order/models/service_po_ath.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/service_order_data.dart';

// This function will be run in a background isolate
List<ServiceOrderData> parseServiceOrderList(List<dynamic> data) {
  return data.map((e) => ServiceOrderData.fromJson(e)).toList();
}

class ServiceOrderService {
  final Dio _dio = Dio();

  Future<List<ServiceOrderData>> fetchServiceOrderList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    debugPrint("Fetching Auth Service Order List");
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

    final String endpoint = '/api/Podata/servicePOPendAuthList';

    final response = await _dio.post(
      "http://$url$endpoint",
      data: body,
      queryParameters: {"locationIds": locationId.toString()},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Service Order List fetched successfully");
      debugPrint("Response: ${response.data}");
      final List<dynamic> data = response.data['data'] ?? [];
      // return data.map((e) => ServiceOrderData.fromJson(e)).toList();
      return await compute(parseServiceOrderList, data);
    } else {
      throw Exception('Failed to load service order list');
    }
  }

  Future<String> fetchServiceOrderPdfUrl(ServiceOrderData so) async {
    debugPrint("Fetching Auth Service Order PDF");
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationCode = locationDetails['code'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final String endpoint = '/api/Podata/poGetPrint_Service';

    final body = {
      "rbtDraft": false,
      "rbtFinal": true,
      "FormID": "01125",
      "strPoNumber": so.id.toString(),
      "companyData": companyDetails,
      "locationData": locationDetails,
      "strDomCurrency": "INR",
      "SiteCode": locationCode,
      "GSTDateTimeTemp": "01/07/2017",
    };

    final response = await _dio.post("http://$url$endpoint", data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      // The PDF URL is in response.data['data']
      return response.data['data'] ?? '';
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }

  Future<bool> authorizeServiceOrder(ServiceOrderData so) async {
    debugPrint("Authorizing Service Order");
    debugPrint("Service Order ID: ${so.id}");
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

    final body = {
      "siteid": locationId,
      "sitecode": locationCode,
      "ServicePOAthList": [
        ServicePOAth(
          id: so.id,
          year: so.year,
          grp: so.grp,
          number: so.number,
          siteid: so.siteid,
          sitecode: so.sitecode,
          vendorcode: so.vendorcode,
          vendorname: so.vendorname,
          loginsiteid: locationId,
          loginsitecode: locationCode,
          loginsitename: locationName,
          formid: "01116",
        ).toJson(),
      ],
    };

    final String endpoint = '/api/Podata/servicePOAuth';

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      debugPrint("Service Order authorized successfully");
      debugPrint("Response: ${response.data}");
      return true;
    } else {
      debugPrint("Failed to authorize Service Order");
      debugPrint("Response: ${response.data}");
      return false;
    }
  }
}
