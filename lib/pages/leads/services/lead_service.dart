import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nhapp/pages/leads/models/lead_detail_data.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/lead_data.dart';

class LeadService {
  final Dio _dio = Dio();

  Future<List<LeadData>> fetchLeadsList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    final userId = tokenDetails['user']['id'];

    final endpoint = "/api/Lead/LeadEntryList";

    final body = {
      "PageNumber": page,
      "PageSize": pageSize,
      "SortField": "",
      "SortDirection": "",
      "SearchValue": searchValue ?? "",
      "UserId": userId,
      "restcoresalestrans": "false",
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.post("http://$url$endpoint", data: body);
    debugPrint("fetchLeadsList Status Code: ${response.statusCode}");
    //debugPrint("fetchLeadsList Response: ${response.data}");
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => LeadData.fromJson(e)).toList();
    } else {
      debugPrint("fetchLeadsList Error throwing exception");
      throw Exception('Failed to load leads list');
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

    final endpoint = "/api/Lead/DeleteLeadEntry";

    final response = await _dio.delete(
      'http://$url$endpoint',
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
}
