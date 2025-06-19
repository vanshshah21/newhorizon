import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/quotation_list_item.dart';
import '../models/quotation_detail.dart';

class QuotationService {
  final Dio _dio = Dio();

  Future<List<QuotationListItem>> fetchQuotationList({
    required int pageNumber,
    required int pageSize,
    String? searchValue,
  }) async {
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

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "userLocationIds": locationId,
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue ?? "",
      "restcoresalestrans": "false",
    };

    final endpoint = "/api/Quotation/QuotationEntryList";

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => QuotationListItem.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch quotations');
  }

  Future<String> fetchQuotationPdfUrl(QuotationListItem q) async {
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

    final endpoint = "/api/Quotation/QuotationGetPrint";

    final body = {
      "AutoId": q.qtnID,
      "DocType": "SQ",
      "FormID": "06104",
      "GSTDateTimeTemp": "01/07/2017",
      "LocCode": q.siteCode,
      "QtnGrp": q.qtnGroup,
      "QtnNo": q.qtnNumber,
      "QtnYear": q.qtnYear,
      "intCompId": companyId,
      "intSiteId": q.siteId,
      "strDomCurrency": "INR",
      "companyData": companyDetails,
    };

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    }
    throw Exception('Failed to fetch PDF');
  }

  Future<QuotationDetail> fetchQuotationDetail(QuotationListItem q) async {
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

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Quotation/QuotationGetDetails";

    final response = await _dio.post(
      'http://$url$endpoint',
      queryParameters: <String, dynamic>{
        "QtnYear": q.qtnYear,
        "QtnGrp": q.qtnGroup,
        "QtnNumber": q.qtnNumber,
        "QtnSiteId": q.siteId,
        "UserLocations": locationId,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      return QuotationDetail.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch quotation details');
  }
}
