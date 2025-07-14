import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nhapp/pages/leads/models/lead_detail_data.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/network_utils.dart';
import '../models/lead_data.dart';

class LeadService {
  final Dio _dio = NetworkUtils.createDioInstance();

  Future<List<LeadData>> fetchLeadsList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails == null) throw Exception("Location not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final userId = tokenDetails['user']['id'];
      final locationId = locationDetails['id'];

      final endpoint = "/api/Lead/LeadEntryList";

      final body = {
        "PageNumber": page,
        "PageSize": pageSize,
        "SortField": "",
        "SortDirection": "",
        "SearchValue": searchValue ?? "",
        "UserId": userId,
        "locationIds": locationId.toString(),
        "restcoresalestrans": "false",
      };

      final response = await _dio.post(
        "http://$url$endpoint",
        data: body,
        options: Options(
          headers: {
            'companyid': companyId.toString(),
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint("fetchLeadsList Status Code: ${response.statusCode}");
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => LeadData.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load leads list: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      debugPrint("fetchLeadsList DioException: ${e.message}");
      throw Exception(NetworkUtils.getErrorMessage(e));
    } catch (e) {
      debugPrint("fetchLeadsList Error: $e");
      throw Exception('Failed to load leads list: $e');
    }
  }

  Future<String> fetchLeadPdfUrl(LeadData lead) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final companyName = companyDetails['name'];
    final companyCode = companyDetails['code'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Lead/LeadGetPrint";

    final body = {
      "intCompId": companyId,
      "strCompanyName": companyName,
      "inquiryId": lead.inquiryID,
      "companycode": companyCode,
    };

    final response = await _dio.post('http://$url$endpoint', data: body);
    debugPrint("fetchLeadPdfUrl Status Code: ${response.statusCode}");
    //debugPrint("fetchLeadPdfUrl Response: ${response.data}");
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    } else {
      debugPrint("fetchLeadPdfUrl Error throwing exception");
      throw Exception('Failed to fetch PDF');
    }
  }

  Future<bool> deleteLead(LeadData lead) async {
    final url = "http://${await StorageUtils.readValue('url')}";
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Lead/DeleteLeadEntry";

    final response = await _dio.delete(
      '$url$endpoint',
      queryParameters: {"InquiryID": lead.inquiryID},
    );
    debugPrint("deleteLead Status Code: ${response.statusCode}");
    debugPrint("deleteLead Response Type: ${response.data.runtimeType}");
    debugPrint("deleteLead Response: ${response.data['message']}");
    debugPrint("deleteLead Response Data: ${response.data['success']}");
    if (response.statusCode == 200 && response.data["success"] == true) {
      return true;
    } else {
      debugPrint("deleteLead Error for InquiryID: ${lead.inquiryID}");
      return false;
    }
  }

  Future<LeadDetailData> fetchLeadDetails({
    required String customerCode,
    required String salesmanCode,
    required String inquiryYear,
    required String inquiryGroup,
    required String inquirySiteCode,
    required String inquiryNumber,
    required int inquiryID,
  }) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Lead/FetchInquiryEntryDetail";

    final response = await _dio.get(
      'http://$url$endpoint',
      queryParameters: {
        'CustomerCode': customerCode,
        'SalesmanCode': salesmanCode,
        'InquiryYear': inquiryYear,
        'InquiryGroup': inquiryGroup,
        'InquirySiteCode': inquirySiteCode,
        'InquiryNumber': inquiryNumber,
        'flag': 'S',
        'InquiryID': inquiryID,
      },
    );
    debugPrint("fetchLeadDetails Status Code: ${response.statusCode}");
    //debugPrint("fetchLeadDetails Response: ${response.data}");
    if (response.statusCode == 200 && response.data["success"] == true) {
      return LeadDetailData.fromJson(response.data['data']);
    } else {
      debugPrint("fetchLeadDetails Error for InquiryID: $inquiryID");
      throw Exception('Failed to fetch lead details');
    }
  }

  Future<Map<String, dynamic>?> getGeoLocation({
    required String functionId,
  }) async {
    try {
      final url = await StorageUtils.readValue('url');
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];

      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['Authorization'] = 'Bearer $token';
      const endpoint = "/api/Login/getGeoLocation";

      final response = await _dio.get(
        'http://$url$endpoint',
        queryParameters: {
          'companyid': companyId,
          'functioncode': 'LD',
          'functionid': functionId,
        },
      );
      final data = jsonDecode(response.data);

      if (response.statusCode == 200 && data.isNotEmpty) {
        // Parse the location data and convert strings to doubles

        // Convert string coordinates to double for easier use
        final parsedData = {
          'mLOCFUNCTIONID': data['mLOCFUNCTIONID'],
          'longitude': double.tryParse(data['mLOCLONGITUDE'].toString()) ?? 0.0,
          'latitude': double.tryParse(data['mLOCLATITUDE'].toString()) ?? 0.0,
          'mLOCLONGITUDE': data['data']['mLOCLONGITUDE'],
          'mLOCLATITUDE': data['data']['mLOCLATITUDE'],
        };

        return parsedData;
      }

      return null;
    } catch (e) {
      debugPrint("Error in getGeoLocation: $e");
      return null;
    }
  }
}
