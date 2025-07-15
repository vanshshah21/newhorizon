import 'package:dio/dio.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_details.dart';
import 'package:nhapp/pages/proforma_invoice/models/proforma_invoice_item.dart';
import 'package:nhapp/utils/storage_utils.dart';

class ProformaInvoiceService {
  final Dio _dio = Dio();

  Future<List<ProformaInvoice>> fetchProformaInvoiceList({
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

    final token = tokenDetails['token']['value'];
    final locationId = locationDetails['id'] ?? 0;

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyDetails['id'].toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "locationId": locationId,
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue,
    };

    final endpoint = "/api/Proforma/proformaInvoiceEntryList";

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] ?? [];
      return data.map((e) => ProformaInvoice.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch proforma invoices');
  }

  Future<String> fetchProformaInvoicePdfUrl(ProformaInvoice invoice) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final domCurrency = await StorageUtils.readJson('domestic_currency');
    if (domCurrency == null) throw Exception("Domestic currency not set");

    final currency = domCurrency['domCurCode'] ?? 'INR';

    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyDetails['id'].toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "pipDplCpy": false,
      "pipFromDate": "01/12/2024",
      "pipToDate": "21/04/2025",
      "pipOrgCpy": true,
      "showdescription": true,
      "valuetype": "withvalue",
      "printtype": "word",
      "showitemcd": "yes",
      "companyData": companyDetails,
      "strDomCurrency": currency,
      "strDomCurrencyDesc": "Indian Rupee",
      "chkOriginalCopy": true,
      "chkDuplicateCopy": false,
      "strNumber": invoice.id.toString(),
      "strDomCurrencyDNOMITN": currency,
      "Detailselection": "withdetail",
      "Valuetype": "both",
    };

    final endpoint = "/api/Proforma/proformaInvoicePrint";

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    }
    throw Exception('Failed to fetch Proforma Invoice PDF');
  }

  Future<bool> proformaDelete(int invoiceNumber) async {
    final url = await StorageUtils.readValue('url');
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyDetails['id'].toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final endpoint = "/api/Proforma/proformaInvoiceDelete";

    final response = await _dio.delete(
      'http://$url$endpoint',
      queryParameters: {"invoiceNumber": invoiceNumber},
    );
    if (response.statusCode == 200 && response.data['success'] == true ||
        response.data['success'] == 'true') {
      return true;
    }
    throw Exception('Failed to delete proforma invoice');
  }

  Future<ProformaInvoiceDetails> fetchProformaInvoiceDetails({
    required int invSiteId,
    required String invYear,
    required String invGroup,
    required String invNumber,
    required String piOn,
    required int fromLocationId,
    required String custCode,
    String search = "S",
  }) async {
    final url = await StorageUtils.readValue('url');
    final endpoint =
        "/api/Proforma/proformaInvoiceGetInvoiceDetails"
        "?invSiteId=$invSiteId"
        "&invYear=$invYear"
        "&invGroup=$invGroup"
        "&invNumber=$invNumber"
        "&piOn=$piOn"
        "&fromLoactionId=$fromLocationId"
        "&custCode=$custCode"
        "&search=$search";

    final companyDetails = await StorageUtils.readJson('selected_company');
    final tokenDetails = await StorageUtils.readJson('session_token');
    final token = tokenDetails['token']['value'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyDetails['id'].toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final response = await _dio.get('http://$url$endpoint');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return ProformaInvoiceDetails.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch proforma invoice details');
  }
}
