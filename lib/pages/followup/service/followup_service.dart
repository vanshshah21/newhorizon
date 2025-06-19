import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/followup_list_item.dart';
import '../models/followup_detail.dart';

class FollowupService {
  final Dio _dio = Dio();

  Future<List<FollowupListItem>> fetchFollowupList({
    required int pageNumber,
    required int pageSize,
    String? searchValue,
  }) async {
    final url = await StorageUtils.readValue("url");
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId;
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue,
      "restcoresalestrans": "false",
    };

    final endpoint = "/api/Followup/FollowUpEntryList";

    final response = await _dio.post('http://$url$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => FollowupListItem.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch followups');
  }

  Future<List<FollowupDetail>> fetchFollowupDetails(
    FollowupListItem item,
  ) async {
    final url = await StorageUtils.readValue("url");
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

    final endpoint = "/api/Followup/FollowupGetEntryDetail2";

    final response = await _dio.get(
      'http://$url$endpoint',
      queryParameters: {
        "custCode": item.custCode,
        "baseOn": item.baseOn,
        "docId": item.docId,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => FollowupDetail.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch followup details');
  }
}
