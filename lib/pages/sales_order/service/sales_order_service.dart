import 'package:dio/dio.dart';
import 'package:nhapp/utils/storage_utils.dart';
import '../models/sales_order.dart';

class SalesOrderService {
  final Dio _dio = Dio();

  Future<List<SalesOrder>> fetchSalesOrderPaged({
    required int page,
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
      "year": "24-25",
      "type": "OB",
      "subType": "OB",
      "locId": 8,
      "userId": "SUPER",
      "comCode": "CTL",
      "flag": "SITEID",
      "pageSize": pageSize,
      "pageNumber": page,
      "sortField": "",
      "sortDirection": "asc",
      "searchValue": searchValue ?? "",
      "restcoresalestrans": "false",
      "companyId": 1,
      "usrLvl": 0,
      "usrSubLvl": 0,
      "valLimit": 0,
    };

    final endpoint = "/api/SalesOrder/SalesOrderGetList";

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> data = response.data['data']?['solist'] ?? [];
      return data.map((e) => SalesOrder.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load Sales Orders');
    }
  }

  Future<String> fetchSalesOrderPdfUrl(SalesOrder so) async {
    final url = await StorageUtils.readValue("url");
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final companycd = companyDetails['code'];
    final token = tokenDetails['token']['value'];
    final userId = tokenDetails['user']['id'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId;
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "site": so.siteId,
      "selectitem": so.customerFullName,
      "valuetype": "withvalue",
      "printtype": "word",
      "AutoId": so.orderId,
      "LocCode": so.siteCode,
      "SalYear": so.ioYear,
      "SalGrp": so.ioGroup,
      "SalNo": so.ioNumber,
      "CmpCode": companycd,
      "intSiteId": so.siteId,
      "intCompId": companyId,
      "companyData": companyDetails,
      "userid": userId,
      "strDomCurrency": "INR",
      "fromDate": so.date.substring(0, 10),
      "toDate": so.date.substring(0, 10),
      "strDomCurrencyDNOMITN": "INR",
      "strDomCurrencyDesc": "Indian Rupee",
      "FormID": "06106",
      "reportselection": "withvalue",
      "techspec": "multiline",
    };

    final endpoint = "/api/SalesOrder/SalesOrderPrint";

    final response = await _dio.post('http://$url$endpoint', data: body);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'] ?? '';
    } else {
      throw Exception('Failed to fetch PDF');
    }
  }
}
