import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/sales_order/models/sales_order_detail.dart';
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

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location details not found");

    final financeDetails = await StorageUtils.readJson('finance_period');
    if (financeDetails == null) throw Exception("Finance details not found");

    final companyId = companyDetails['id'];
    final locationId = locationDetails['id'];
    final token = tokenDetails['token']['value'];
    final year = financeDetails['financialYear'];
    final companycd = companyDetails['code'];
    final userId = tokenDetails['user']['userName'];

    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId;
    _dio.options.headers['Authorization'] = 'Bearer $token';

    final body = {
      "year": year,
      "type": "OB",
      "subType": "OB",
      "locId": locationId,
      "userId": userId,
      "comCode": companycd,
      "flag": "SITEID",
      "pageSize": pageSize,
      "pageNumber": page,
      "sortField": "",
      "sortDirection": "",
      "searchValue": searchValue ?? "",
      "restcoresalestrans": "false",
      "companyId": companyId,
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

  Future deleteSalesOrder(int orderId) async {
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

    final response = await _dio.delete(
      'http://$url/api/SalesOrder/salesOrderDeleteEntry',
      queryParameters: {'orderId': orderId},
    );
    debugPrint(
      'Delete Sales Order Response: ${response.data}, message: ${response.data['message']}, success: ${response.data['success']}',
    );
    if (response.statusCode == 200 && response.data['success'] == true ||
        response.data['success'] == 'true') {
      return true;
    } else {
      throw Exception('Failed to delete Sales Order');
    }
  }

  Future<SalesOrderDetailsResponse> fetchSalesOrderDetails(
    SalesOrder salesOrder,
  ) async {
    try {
      final url = await StorageUtils.readValue("url");
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final locationDetails = await StorageUtils.readJson('selected_location');
      if (locationDetails == null) {
        throw Exception("Location details not found");
      }

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");

      final companyId = companyDetails['id'];
      final token = tokenDetails['token']['value'];
      final locationId = locationDetails['id'];

      _dio.options.headers['Content-Type'] = 'application/json';
      _dio.options.headers['Accept'] = 'application/json';
      _dio.options.headers['companyid'] = companyId;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      final body = {
        "IOYear": salesOrder.ioYear,
        "ioGroup": salesOrder.ioGroup,
        "IOSiteCode": salesOrder.siteCode,
        "ioNumber": salesOrder.ioNumber,
        "locid": salesOrder.siteId,
        "mode": "SEARCH",
        "AuthReq": "Y",
        "IsInterBranchTransfer": false,
        "locationId": locationId,
        "compantid": companyId,
        "DomCurrency": "INR",
      };

      final response = await _dio.post(
        "http://$url/api/SalesOrder/salesOrderGetDetails",
        data: body,
      );

      return SalesOrderDetailsResponse.fromJson(response.data);
    } catch (e) {
      print('Error fetching sales order details: $e');
      rethrow;
    }
  }
}
