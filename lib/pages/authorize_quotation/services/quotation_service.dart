import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhapp/pages/authorize_quotation/models/quotation_data.dart';
import 'package:nhapp/utils/storage_utils.dart';

class QuotationService {
  final Dio _dio = Dio();

  Future<List<QuotationData>> fetchQuotationList({
    required int page,
    required int pageSize,
    String? searchValue,
  }) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    final locationDetails = await StorageUtils.readJson('selected_location');
    final tokenDetails = await StorageUtils.readJson('session_token');

    if (companyDetails == null) throw Exception("Company not set");
    if (locationDetails == null) throw Exception("Location not set");
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];

    final endpoint = '/api/Quotation/QuotationEntryListPendAuth';

    final body = {
      "UserLocationIds": locationId.toString(),
      "AuthStatus": "P",
      "mulLvlAuthRed": false,
      "pageSize": pageSize,
      "pageNumber": page,
      "restcoresalestrans": "false",
      "searchValue": searchValue,
      "sortDirection": "",
      "sortField": "",
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['CompanyId'] = companyId;

    final response = await _dio.post('http://$url$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return await compute(
        (list) => list.map((e) => QuotationData.fromJson(e)).toList(),
        List<Map<String, dynamic>>.from(data),
      );
    } else {
      throw Exception('Failed to load quotation list');
    }
  }

  Future<String> fetchQuotationPdfUrl(QuotationData qtn) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    final tokenDetails = await StorageUtils.readJson('session_token');
    final locationDetails = await StorageUtils.readJson('selected_location');

    if (companyDetails == null) throw Exception("Company not set");
    if (locationDetails == null) throw Exception("Location not set");
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    final endpoint = '/api/Quotation/QuotationGetPrint';

    final body = {
      "AutoId": qtn.qtnID,
      "DocType": "SQ",
      "LocCode": qtn.siteCode,
      "QtnGrp": qtn.qtnGroup,
      "QtnNo": qtn.qtnNumber,
      "QtnYear": qtn.qtnYear,
      "intCompId": companyId,
      "intSiteId": qtn.siteId,
      "documentprint": "regular",
      "strDomCurrency": "INR",
      "companyData": companyDetails,
    };

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['CompanyId'] = companyId;

    final response = await _dio.post('http://$url$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }

  Future<bool> authorizeQuotation(QuotationData qtn) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    final endpoint = '/api/Quotation/quotationAuthPendData';

    final body = [
      {
        "QuotationId": qtn.qtnID,
        "QuotationSiteId": qtn.siteId,
        "AuthorizationDate": DateTime.now().toIso8601String(),
        "qtnNumber": qtn.qtnNumber,
        "qtnYear": qtn.qtnYear,
        "qtnGroup": qtn.qtnGroup,
        "siteFullName": qtn.siteFullName,
        "siteCode": qtn.siteCode,
        "customerFullName": qtn.customerFullName,
        "custCode": qtn.customerCode,
      },
    ];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _dio.options.headers['CompanyId'] = companyId;

    final response = await _dio.post('http://$url$endpoint', data: body);

    if (response.statusCode == 200 && response.data['success'] == true) {
      return true;
    } else {
      return false;
    }
  }
}
