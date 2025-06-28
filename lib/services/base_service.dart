import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/network_utils.dart';

abstract class BaseService {
  final Dio _dio = NetworkUtils.createDioInstance();
  
  Dio get dio => _dio;

  Future<Map<String, dynamic>> getAuthHeaders() async {
    final companyDetails = await StorageUtils.readJson('selected_company');
    final tokenDetails = await StorageUtils.readJson('session_token');
    
    if (companyDetails == null) {
      throw Exception("Company not set");
    }
    
    if (tokenDetails == null) {
      throw Exception("Session token not found");
    }

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'companyid': companyId.toString(),
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> getBaseUrl() async {
    final url = await StorageUtils.readValue('url');
    if (url == null) {
      throw Exception("URL not set");
    }
    return 'http://$url';
  }

  Future<T> executeRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await request();
      
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['success'] == true) {
          return parser(response.data['data']);
        } else if (response.data is Map && response.data.containsKey('success') && response.data['success'] == false) {
          throw Exception(response.data['message'] ?? 'Request failed');
        } else {
          return parser(response.data);
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception(NetworkUtils.getErrorMessage(e));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<T>> executeListRequest<T>(
    Future<Response> Function() request,
    T Function(dynamic item) itemParser,
  ) async {
    return executeRequest<List<T>>(
      request,
      (data) {
        if (data is List) {
          return data.map((item) => itemParser(item)).toList();
        } else {
          throw Exception('Expected list data but got ${data.runtimeType}');
        }
      },
    );
  }

  Future<bool> executeBooleanRequest(
    Future<Response> Function() request,
  ) async {
    return executeRequest<bool>(
      request,
      (data) => true, // If request succeeds, return true
    );
  }
}