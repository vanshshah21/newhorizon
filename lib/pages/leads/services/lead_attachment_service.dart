import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/lead_attachment.dart';

class LeadAttachmentService {
  final Dio _dio;

  LeadAttachmentService(this._dio);

  Future<List<LeadAttachment>> fetchAttachments({
    required String baseUrl,
    required String documentNo,
    required String formId,
  }) async {
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

    final endpoint = "/api/Login/attachment_details";

    final response = await _dio.post(
      '$baseUrl$endpoint',
      data: {"DocumentNo": documentNo, "FormID": formId},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => LeadAttachment.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch attachments');
  }

  Future<bool> deleteAttachment({
    required String baseUrl,
    required String docYear,
    required String documentNo,
    required String formId,
    required List<Map<String, dynamic>> deletedFileList,
  }) async {
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

    final endpoint = "/api/Login/attachment_delete";

    final response = await _dio.post(
      '$baseUrl$endpoint',
      data: {
        "DocYear": docYear,
        "DocumentNo": documentNo,
        "DeletedFileList": deletedFileList,
        "FormID": formId,
      },
    );
    return response.statusCode == 200 && response.data['success'] == true;
  }
}
