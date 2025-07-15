import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/labour_po_data.dart';

class LabourPOService {
  final Dio _dio = Dio();

  // Make this a static function so it doesn't capture the instance
  static List<LabourPOData> _parseLabourPOList(List<dynamic> data) {
    return data.map((e) => LabourPOData.fromJson(e)).toList();
  }

  Future<List<LabourPOData>> fetchLabourPOListPaged({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    final String endpoint = '/api/Podata/labourPOList/';
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

    final response = await _dio.post(
      "http://$url$endpoint",
      data: body,
      queryParameters: {"locationIds": locationId.toString()},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      // Use static function reference instead of instance method
      return await compute(_parseLabourPOList, data);
    } else {
      throw Exception('Failed to load Labour PO list');
    }
  }

  // Future<List<LabourPOData>> fetchLabourPOListPaged({
  //   required int page,
  //   required int pageSize,
  //   String? searchValue,
  // }) async {
  //   final String endpoint = '/api/Podata/labourPOList/';
  //   final url = await StorageUtils.readValue('url');
  //   final companyDetails = await StorageUtils.readJson('selected_company');
  //   if (companyDetails == null) throw Exception("Company not set");

  //   final locationDetails = await StorageUtils.readJson('selected_location');
  //   if (locationDetails == null) throw Exception("Location not set");

  //   final tokenDetails = await StorageUtils.readJson('session_token');
  //   if (tokenDetails == null) throw Exception("Session token not found");

  //   final companyId = companyDetails['id'];
  //   final locationId = locationDetails['id'];
  //   final token = tokenDetails['token']['value'];

  //   final body = {
  //     "pageNumber": page,
  //     "pageSize": pageSize,
  //     "sortField": "",
  //     "sortDirection": "",
  //     "searchValue": searchValue,
  //   };

  //   _dio.options.headers['Content-Type'] = 'application/json';
  //   _dio.options.headers['Accept'] = 'application/json';
  //   _dio.options.headers['companyid'] = companyId.toString();
  //   _dio.options.headers['Authorization'] = 'Bearer $token';

  //   final response = await _dio.post(
  //     "http://$url$endpoint",
  //     data: body,
  //     queryParameters: {"locationIds": locationId.toString()},
  //   );
  //   if (response.statusCode == 200 && response.data['success'] == true) {
  //     final List<dynamic> data = response.data['data'] ?? [];
  //     // Heavy parsing off the main thread (optional, for very large lists)
  //     // return data.map((e) => LabourPOData.fromJson(e)).toList();
  //     return await compute(_parseLabourPOList, data);
  //   } else {
  //     throw Exception('Failed to load Labour PO list');
  //   }
  // }

  // List<LabourPOData> _parseLabourPOList(List<dynamic> data) {
  //   return data.map((e) => LabourPOData.fromJson(e)).toList();
  // }

  Future<String> fetchLabourPOPdfUrl(LabourPOData po) async {
    final endpoint = '/api/Podata/poGetPrint_LabourRate';
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
    final body = {
      "POData": [po.toPdfJson()],
      "companyData": companyDetails,
      "locationData": locationDetails,
      "typeCopyControl": "1",
      "strDomCurrency": currency ?? "INR",
      "FormID": "01109",
      "typeSelection": "R",
      "GSTDateTimeTemp": "01/07/2017",
      "printtype": "pdf",
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
