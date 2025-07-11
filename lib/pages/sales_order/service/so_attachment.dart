import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';

class SalesOrderAttachmentService {
  final Dio _dio;

  SalesOrderAttachmentService(this._dio);

  Future<List<Map<String, dynamic>>> fetchAttachments({
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
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to fetch attachments');
  }

  Future<List<Map<String, dynamic>>> fetchSalesOrderAttachments({
    required String baseUrl,
    required String ioYear,
    required String ioGroup,
    required String ioSiteCode,
    required String ioNumber,
  }) async {
    final documentNo = "$ioYear/$ioGroup/$ioSiteCode/$ioNumber/SALESORDERENTRY";
    return fetchAttachments(
      baseUrl: baseUrl,
      documentNo: documentNo,
      formId: "06105", // Form ID for sales order
    );
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

  Future<bool> uploadAttachments({
    required List<String> filePaths,
    required String documentNo,
    required String documentId,
    required String docYear,
    required String formId,
    required String locationCode,
    required String companyCode,
    required int locationId,
    required int companyId,
    required int userId,
  }) async {
    try {
      final baseUrl = 'http://${await StorageUtils.readValue('url')}';
      final tokenDetails = await StorageUtils.readJson('session_token');
      final token = tokenDetails['token']['value'];

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'companyid': companyId.toString(),
        'Accept': 'application/json',
      };

      for (final filePath in filePaths) {
        final formData = FormData();
        formData.fields.addAll([
          MapEntry("LocationID", locationId.toString()),
          MapEntry("CompanyID", companyId.toString()),
          MapEntry("CompanyCode", companyCode),
          MapEntry("LocationCode", locationCode),
          MapEntry("DocYear", docYear),
          MapEntry("FormID", formId),
          MapEntry("DocumentNo", documentNo),
          MapEntry("DocumentID", documentId),
          MapEntry("CreatedBy", userId.toString()),
        ]);

        formData.files.add(
          MapEntry("AttachmentsFile", await MultipartFile.fromFile(filePath)),
        );

        final response = await dio.post(
          "$baseUrl/api/Lead/uploadAttachmentnew2",
          data: formData,
          options: Options(contentType: 'multipart/form-data'),
        );

        if (response.statusCode != 200 || response.data['success'] != true) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error uploading attachments: $e');
      return false;
    }
  }
}
