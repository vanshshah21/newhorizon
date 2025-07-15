import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/utils/storage_utils.dart';
import 'package:nhapp/utils/network_utils.dart';
import 'package:nhapp/services/base_service.dart';
import '../models/quotation_list_item.dart';
import '../models/quotation_detail.dart';

class QuotationService extends BaseService {
  Future<List<QuotationListItem>> fetchQuotationList({
    required int pageNumber,
    required int pageSize,
    String? searchValue,
  }) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");
    final locationId = locationDetails['id'];

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

    return executeListRequest<QuotationListItem>(
      () => dio.post(
        '$baseUrl$endpoint',
        data: body,
        options: Options(headers: headers),
      ),
      (item) => QuotationListItem.fromJson(item),
    );
  }

  Future<String> fetchQuotationPdfUrl(QuotationListItem q) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final domCurrency = await StorageUtils.readJson('domestic_currency');
    if (domCurrency == null) throw Exception("Domestic currency not set");

    final currency = domCurrency['domCurCode'] ?? 'INR';

    final companyId = companyDetails['id'];
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
      "strDomCurrency": currency,
      "companyData": companyDetails,
      "documentprint": "regular",
      "printtype": "pdf",
      "discountprint": "withdisc",
      "reportselection": "withvalue",
    };

    return executeRequest<String>(
      () => dio.post(
        '$baseUrl$endpoint',
        data: body,
        options: Options(headers: headers),
      ),
      (data) {
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] != null) {
            return data['data'];
          } else {
            throw Exception(
              data['errorMessage'] ??
                  data['message'] ??
                  'Failed to get PDF URL',
            );
          }
        }
        return data?.toString() ?? '';
      },
    );
  }

  Future<QuotationDetail> fetchQuotationDetail(QuotationListItem q) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");
    final locationId = locationDetails['id'];

    final endpoint = "/api/Quotation/QuotationGetDetails";

    return executeRequest<QuotationDetail>(
      () => dio.post(
        '$baseUrl$endpoint',
        queryParameters: <String, dynamic>{
          "QtnYear": q.qtnYear,
          "QtnGrp": q.qtnGroup,
          "QtnNumber": q.qtnNumber,
          "QtnSiteId": q.siteId,
          "UserLocations": locationId,
        },
        options: Options(headers: headers),
      ),
      (data) => QuotationDetail.fromJson(data),
    );
  }

  /// Delete a quotation
  Future<bool> deleteQuotation(QuotationListItem quotation) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final endpoint = "/api/Quotation/DeleteQuotation";

    return executeBooleanRequest(
      () => dio.delete(
        '$baseUrl$endpoint',
        queryParameters: {
          "QtnID": quotation.qtnID,
          "QtnYear": quotation.qtnYear,
          "QtnGroup": quotation.qtnGroup,
          "QtnNumber": quotation.qtnNumber,
        },
        options: Options(headers: headers),
      ),
    );
  }

  /// Update quotation status (if such functionality exists)
  Future<bool> updateQuotationStatus(
    QuotationListItem quotation,
    String newStatus,
  ) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final endpoint = "/api/Quotation/UpdateStatus";

    final body = {
      "QtnID": quotation.qtnID,
      "QtnYear": quotation.qtnYear,
      "QtnGroup": quotation.qtnGroup,
      "QtnNumber": quotation.qtnNumber,
      "NewStatus": newStatus,
    };

    return executeBooleanRequest(
      () => dio.put(
        '$baseUrl$endpoint',
        data: body,
        options: Options(headers: headers),
      ),
    );
  }

  /// Search quotations by customer
  Future<List<QuotationListItem>> searchQuotationsByCustomer({
    required String customerCode,
    required int pageNumber,
    required int pageSize,
  }) async {
    final baseUrl = await getBaseUrl();
    final headers = await getAuthHeaders();

    final locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails == null) throw Exception("Location not set");
    final locationId = locationDetails['id'];

    final body = {
      "userLocationIds": locationId,
      "pageNumber": pageNumber,
      "pageSize": pageSize,
      "sortField": "",
      "sortDirection": "",
      "searchValue": customerCode,
      "searchType": "customer",
      "restcoresalestrans": "false",
    };

    final endpoint = "/api/Quotation/SearchByCustomer";

    return executeListRequest<QuotationListItem>(
      () => dio.post(
        '$baseUrl$endpoint',
        data: body,
        options: Options(headers: headers),
      ),
      (item) => QuotationListItem.fromJson(item),
    );
  }

  Future<Map<String, dynamic>> getSalesPolicy() async {
    try {
      final baseUrl = await getBaseUrl();
      final headers = await getAuthHeaders();
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");
      final companyCode = companyDetails['code'];
      const endpoint = "/api/Login/GetSalesPolicyDetails";
      final response = await dio.get(
        '$baseUrl$endpoint',
        queryParameters: {"companyCode": companyCode},
        options: Options(headers: headers),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['salesPolicyResultModel'][0]
            as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }
}
