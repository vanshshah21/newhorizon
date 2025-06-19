// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:nhapp/utils/storage_utils.dart';
// import '../models/login_response.dart';

// class LoginService {
//   final Dio _dio = Dio();
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<LoginResponse> login({
//     required String url,
//     required String username,
//     required String password,
//   }) async {
//     final response = await _dio.post(
//       'http://$url/api/Login/LoginCall',
//       data: {'userName': username, 'password': password},
//     );
//     return LoginResponse.fromJson(response.data);
//   }

//   Future<Map<String, dynamic>> getCompanyAndLocation({
//     required String url,
//     required String username,
//   }) async {
//     final response = await _dio.get(
//       'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
//       queryParameters: {'UserName': username},
//     );
//     return response.data['data'] as Map<String, dynamic>;
//   }

//   Future<Map<String, dynamic>> getCompanyCurrentYearDatesData() async {
//     final url = await StorageUtils.readValue("url");
//     final companyDetails = await StorageUtils.readJson("selected_company");
//     if (url == null || companyDetails == null) {
//       throw Exception("URL or company details not found");
//     }

//     final tokenDetails = await StorageUtils.readJson("session_token");
//     if (tokenDetails == null) {
//       throw Exception("Session token not found");
//     }

//     final companyId = companyDetails['id'];
//     final token = tokenDetails['token'];

//     _dio.options.headers['Content-Type'] = 'application/json';
//     _dio.options.headers['Accept'] = 'application/json';
//     _dio.options.headers['Authorization'] = 'Bearer $token';
//     _dio.options.headers['CompanyId'] = companyId;

//     final response = await _dio.get(
//       'http://$url/api/Login/GetCompanyCurrentYearDatesData',
//       queryParameters: {'companyid': companyId},
//     );
//     return response.data['data'] as Map<String, dynamic>;
//   }

//   Future<void> saveToStorage(String key, dynamic value) async {
//     await _storage.write(key: key, value: jsonEncode(value));
//   }

//   Future<dynamic> readFromStorage(String key) async {
//     final value = await _storage.read(key: key);
//     return value != null ? value : null;
//   }

//   Future<void> deleteAllStorage() async {
//     await _storage.deleteAll();
//   }
// }

import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/login_response.dart';

class LoginService {
  final Dio _dio = Dio();

  LoginService() {
    // Configure Dio defaults
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<LoginResponse> login({
    required String url,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        'http://$url/api/Login/LoginCall',
        data: {'userName': username, 'password': password},
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return LoginResponse(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> getCompanyAndLocation({
    required String url,
    required String username,
  }) async {
    final response = await _dio.get(
      'http://$url/api/Login/GetCompanyAndLocationByUserOnLogin',
      queryParameters: {'UserName': username},
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCompanyCurrentYearDatesData() async {
    final url = await StorageUtils.readValue("url");
    final companyDetails = await StorageUtils.readJson("selected_company");
    if (url == null || companyDetails == null) {
      throw Exception("URL or company details not found");
    }

    final tokenDetails = await StorageUtils.readJson("session_token");
    if (tokenDetails == null) {
      throw Exception("Session token not found");
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token'];

    final response = await _dio.get(
      'http://$url/api/Login/GetCompanyCurrentYearDatesData',
      queryParameters: {'companyid': companyId},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'CompanyId': companyId.toString(),
        },
      ),
    );
    return response.data['data'] as Map<String, dynamic>;
  }
}
