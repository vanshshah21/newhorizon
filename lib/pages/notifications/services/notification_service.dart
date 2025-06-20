import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/notification_item.dart';

class NotificationService {
  final Dio _dio = Dio();

  Future<List<NotificationItem>> fetchNotificationsPaged({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    final endpoint = '/api/Login/GetUserNotification';
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];
    final userId = tokenDetails['user']['id'];
    final body = {
      "pageNumber": page,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "asc",
      "searchValue": searchValue,
      "userId": userId,
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';
    debugPrint("Search Value: $searchValue");
    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => NotificationItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<bool> markAsRead({required int notificationId}) async {
    debugPrint("Marking notification as read: $notificationId");
    final endpoint = '/api/Login/Markasreadnotification';
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

    final response = await _dio.get(
      'http://$url$endpoint',
      queryParameters: {
        'companyid': companyId,
        'NotificationId': notificationId,
      },
    );
    debugPrint("Response: ${response.data.runtimeType}");
    debugPrint("Success: ${response.data['success']}");
    return response.data['success'] == true;
  }

  Future<bool> deleteNotification({required int notificationId}) async {
    final endpoint = '/api/Login/DeleteUserNotification';

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

    final response = await _dio.get(
      'http://$url$endpoint',
      queryParameters: {
        'companyid': companyId,
        'NotificationId': notificationId,
      },
    );
    return response.data['success'] == true;
  }
}
