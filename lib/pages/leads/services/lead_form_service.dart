import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:nhapp/pages/leads/models/lead_data.dart';
import '../models/lead_form.dart';
import 'package:nhapp/utils/storage_utils.dart';

class LeadFormService {
  LeadFormService._internal();
  static final LeadFormService _instance = LeadFormService._internal();
  factory LeadFormService() => _instance;

  final Dio _dio = Dio();

  Future<void> _setupHeaders() async {
    final companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails == null) throw Exception("Company not set");

    final tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails == null) throw Exception("Session token not found");

    final companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'companyid': companyId.toString(),
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> _getBaseUrl() async {
    final url = await StorageUtils.readValue('url');
    if (url == null || url.isEmpty) throw Exception("Base URL not set");
    return 'http://$url';
  }

  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/GetCustCodeListForSalesInquiry";
      final response = await _dio.post(
        '$baseUrl$endpoint',
        queryParameters: {"mode": "A", "flag": "L"},
        data: {
          "pageNumber": 1,
          "pageSize": 0,
          "sortField": "",
          "sortDirection": "asc",
          "searchValue": query,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => CustomerModel.fromJson(e)).toList();
        }
      }
      return <CustomerModel>[];
    } catch (e) {
      debugPrint("Error in searchCustomers: $e");
      rethrow;
    }
  }

  Future<List<SourceModel>> fetchSources() async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/GetCodeTypeList";
      final tokenDetails = await StorageUtils.readJson('session_token');
      final token = tokenDetails?['token']?['value'] ?? '';
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: {"codeType": "SI", "codeValue": "GEN", "token": token},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => SourceModel.fromJson(e)).toList();
        }
      }
      return <SourceModel>[];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSalesPolicy() async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");
      final companyCode = companyDetails['code'];
      const endpoint = "/api/Login/GetSalesPolicyDetails";
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: {"companyCode": companyCode},
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

  Future<List<SalesmanModel>> fetchSalesmen() async {
    try {
      await _setupHeaders();
      final url = await StorageUtils.readValue('url');
      if (url == null || url.isEmpty) throw Exception("Base URL not set");
      const endpoint = "/api/Lead/LeadSalesManList";
      final response = await _dio.get('http://$url$endpoint');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => SalesmanModel.fromJson(e)).toList();
        }
      }
      return <SalesmanModel>[];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<RegionModel>> fetchRegions() async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/GetCodeTypeList";
      final tokenDetails = await StorageUtils.readJson('session_token');
      final token = tokenDetails?['token']?['value'] ?? '';
      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: {"codeType": "SR", "codeValue": "GEN", "token": token},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => RegionModel.fromJson(e)).toList();
        }
      }
      return <RegionModel>[];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SalesItemModel>> searchSalesItems(String query) async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/GetSalesItemList";
      final response = await _dio.post(
        '$baseUrl$endpoint',
        queryParameters: {"flag": "L"},
        data: {
          "pageSize": 10,
          "pageNumber": 1,
          "sortField": "",
          "sortDirection": "",
          "searchValue": query,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((e) => SalesItemModel.fromJson(e)).toList();
        }
      }
      return <SalesItemModel>[];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDateRange(int siteId) async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Login/GetCompanyCurrentYearDatesData";
      final url = await StorageUtils.readValue('url');
      if (url == null || url.isEmpty) throw Exception("Base URL not set");
      final companyDetails = await StorageUtils.readJson('selected_company');
      final companyId = companyDetails['id'];
      final response = await _dio.get(
        'http://$url$endpoint',
        queryParameters: {"companyid": companyId},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        final periods = response.data['data']['financePeriodSetting'];
        final period = periods?.firstWhere(
          (e) => e['siteId'] == siteId,
          orElse: () => null,
        );
        if (period != null) {
          await StorageUtils.writeJson("current_financial_period", period);
          return period;
        }
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDefaultDocDetail({
    required String year,
    required int locationId,
  }) async {
    await _setupHeaders();
    final baseUrl = await _getBaseUrl();
    const endpoint = "/api/Lead/GetDefaultDocumentDetail";
    final response = await _dio.get(
      '$baseUrl$endpoint',
      queryParameters: {
        "year": year,
        "type": "IQ",
        "subType": "IQ",
        "locationId": locationId,
      },
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'];
      if (data is List && data.isNotEmpty) {
        return data.first as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<bool> verifyLeadNumber({
    required String year,
    required String group,
    required int site,
    required String number,
  }) async {
    await _setupHeaders();
    final baseUrl = await _getBaseUrl();
    const endpoint = "/api/Lead/VerifyLeadNumber";
    final response = await _dio.get(
      '$baseUrl$endpoint',
      queryParameters: {
        "year": year,
        "group": group,
        "site": site,
        "number": number,
      },
    );
    return response.data['success'] == false &&
        response.data['errorMessage'] == "Lead_Number_already_exists";
  }

  Future<Map<String, String>> createLeadEntryAndGetDoc({
    required CustomerModel customer,
    required SourceModel source,
    required SalesmanModel salesman,
    required RegionModel region,
    required DateTime leadDate,
    required List<LeadItemEntry> items,
    required int siteId,
    required String year,
    required int userId,
    required String locationCode,
    required bool isAutorisationRequired,
    required bool isAutoNumberGenerated,
    required bool isLocationRequired,
    required String groupCode,
    required String groupFullName,
    required String locationFullName,
    String? leadNumber,
  }) async {
    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");

      final tokenDetails = await StorageUtils.readJson('session_token');
      if (tokenDetails == null) throw Exception("Session token not found");
      final apiLeadDate = leadDate.toIso8601String();
      final InquiryNumber = isAutoNumberGenerated ? 0 : leadNumber;
      final autoNumber = isAutoNumberGenerated ? "Y" : "N";
      final isLocRequired = isLocationRequired ? "Y" : "N";
      final locationId = companyDetails['locationId'] ?? '';
      final companyId = companyDetails['id'] ?? '';

      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/CreateLeadEntry";

      final body = {
        "InquiryId": 0,
        "InquiryFMSiteId": siteId,
        "UserID": userId,
        "IsAutoNumberGenerated": autoNumber,
        "SiteReq": isLocRequired,
        "IsAutorisationRequired": isAutorisationRequired,
        "XININQSTAT": null,
        "CompanyID": companyId,
        "LocationID": locationId,
        "InqEntryModel": {
          "InquiryID": 0,
          "CustomerCode": customer.customerCode,
          "CustomerName": customer.customerName,
          "InquirySiteId": siteId,
          "InquiryYear": year,
          "InquiryGroup": groupCode,
          "InquiryNumber": InquiryNumber,
          "InquiryDate": apiLeadDate,
          "SalesmanCode": salesman.salesmanCode,
          "SalesRegionCode": region.code,
          "InquirySource": source.code,
          "Remarks": null,
          "NextFollowup": null,
          "TenderNumber": null,
          "EMDRequiredDate": null,
          "EMDAmount": 0,
          "EMDEndDate": null,
          "InquiryRefNumber": null,
          "InquiryStatus": "O",
          "SalesmanName": salesman.salesManFullName,
          "LocationCode": locationCode,
          "SalesRegionCodeDesc": region.codeFullName,
          "SourceName": null,
          "CustomerContactID": 0,
          "ProjectItemID": 0,
          "InquiryType": null,
          "ItemCode": null,
          "ItemName": null,
          "ConsultantCode": null,
          "ConsultantName": null,
          "InqEntryItemModel":
              items
                  .map(
                    (e) => {
                      "ModelNo": null,
                      "SalesItemCode": e.item.itemCode,
                      "UOM": e.item.salesUOM,
                      "ItemQty": e.qty,
                      "BasicPrice": e.rate,
                      "Application": null,
                      "PDO": null,
                      "InquiryStatus": "O",
                      "XIMFUGID": null,
                      "CurrencyCode": null,
                      "ItemName": e.item.itemName,
                      "SalesItemType": null,
                      "Precision": null,
                      "CustomerPoItemSrNo": null,
                      "CustomerItemCode": null,
                      "CustomerItemName": null,
                      "LnNumber": 0,
                      "ApplicationCode": null,
                      "ProductSize": null,
                      "InvoiceType": null,
                      "AllowChange": false,
                      "DispatchWithoutMfg": false,
                    },
                  )
                  .toList(),
          "EquipmentAttributeDetails": [],
          "inqkndattControl": null,
        },
      };
      debugPrint("Creating Lead Entry with body: ${body.toString()}");

      final response = await _dio.post('$baseUrl$endpoint', data: body);
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint("Create Lead Entry response: ${response.data}");
        // Parse document number and id from response
        final message = response.data['message'] ?? '';
        final parts = message.split('#');
        if (parts.length >= 3) {
          return {'documentNo': parts[1], 'documentId': parts[2]};
        }
        final data = response.data['data'] as String? ?? '';
        final dataParts = data.split('#');
        if (dataParts.length == 2) {
          return {
            'documentNo': "${dataParts[0]}/LEADENTRY",
            'documentId': dataParts[1],
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint("Error in createLeadEntryAndGetDoc: $e");
      return {};
    }
  }

  // Future<bool> submitLocation({
  //   required String functionId,
  //   required double longitude,
  //   required double latitude,
  // }) async {
  //   try {
  //     await _setupHeaders();
  //     final baseUrl = await _getBaseUrl();
  //     const endpoint = "/api/Quotation/InsertLocation";

  //     final body = {};

  //     debugPrint("Submitting location with body: ${body.toString()}");

  //     final response = await _dio.get(
  //       '$baseUrl$endpoint',
  //       queryParameters: {
  //         "strFunction": "LD",
  //         "intFunctionID": functionId,
  //         "LocLONGITUDE": longitude,
  //         "LocLATITUDE": latitude,
  //       },
  //     );

  //     debugPrint("Location submission response: ${response.data}");
  //     return response.statusCode == 200 && response.data['success'] == true;
  //   } catch (e) {
  //     debugPrint("Error in submitLocation: $e");
  //     return false;
  //   }
  // }
  Future<bool> submitLocation({
    required String functionId,
    required double longitude,
    required double latitude,
  }) async {
    try {
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Quotation/InsertLocation";

      final body = {
        "strFunction": "LD",
        "intFunctionID": functionId,
        "LocLONGITUDE": longitude,
        "LocLATITUDE": latitude,
      };

      debugPrint("Submitting location with body: ${body.toString()}");

      final response = await _dio.get(
        '$baseUrl$endpoint',
        queryParameters: body,
      );

      debugPrint("Location submission response: ${response.data}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        final success = data['success'];
        if (success == true || success == 'true') {
          debugPrint("Location submission successful");
          return true;
        } else {
          debugPrint(
            "Location submission failed: ${data['message'] ?? 'Unknown error'}",
          );
          return false;
        }
      }

      debugPrint(
        "Location submission failed with status: ${response.statusCode}",
      );
      return false;
    } catch (e) {
      debugPrint("Error in submitLocation: $e");
      return false;
    }
  }

  // Future<bool> uploadAttachments({
  //   required List<String> filePaths,
  //   required String documentNo,
  //   required String documentId,
  //   required String docYear,
  //   required String formId,
  //   required String locationCode,
  //   required String companyCode,
  //   required int locationId,
  //   required int companyId,
  //   required int userId,
  // }) async {
  //   try {
  //     await _setupHeaders();
  //     final baseUrl = await _getBaseUrl();
  //     const endpoint = "/api/Lead/uploadAttachment";
  //     final locationid = locationId.toString();
  //     final companyid = companyId.toString();

  //     final formData = FormData();
  //     for (final path in filePaths) {
  //       formData.files.add(
  //         MapEntry("AttachmentsFile", await MultipartFile.fromFile(path)),
  //       );
  //     }

  //     formData.fields
  //       ..add(MapEntry("DocumentNo", documentNo))
  //       ..add(MapEntry("DocumentID", documentId))
  //       ..add(MapEntry("DocYear", docYear))
  //       ..add(MapEntry("FormID", formId))
  //       ..add(MapEntry("LocationCode", locationCode))
  //       ..add(MapEntry("CompanyCode", companyCode))
  //       ..add(MapEntry("LocationID", locationid))
  //       ..add(MapEntry("CompanyID", companyid));

  //     final response = await _dio.post('$baseUrl$endpoint', data: formData);
  //     return response.statusCode == 200 && response.data['success'] == true;
  //   } catch (e) {
  //     debugPrint("Error in uploadAttachments: $e");
  //     return false;
  //   }
  // }

  // Future<bool> uploadAttachments({
  //   required List<String> filePaths,
  //   required String documentNo,
  //   required String documentId,
  //   required String docYear,
  //   required String formId,
  //   required String locationCode,
  //   required String companyCode,
  //   required int locationId,
  //   required int companyId,
  //   required int userId,
  // }) async {
  //   try {
  //     await _setupHeaders();
  //     final baseUrl = await _getBaseUrl();
  //     const endpoint = "/api/Lead/uploadAttachment";

  //     final formData = FormData();

  //     // Add all metadata fields as fields
  //     formData.fields
  //       ..add(MapEntry("LocationID", locationId.toString()))
  //       ..add(MapEntry("CompanyID", companyId.toString()))
  //       ..add(MapEntry("CompanyCode", companyCode))
  //       ..add(MapEntry("LocationCode", locationCode))
  //       ..add(MapEntry("DocYear", docYear))
  //       ..add(MapEntry("FormID", formId))
  //       ..add(MapEntry("DocumentNo", documentNo))
  //       ..add(MapEntry("DocumentID", documentId))
  //       ..add(MapEntry("CreatedBy", userId.toString()));

  //     // Add files
  //     for (final path in filePaths) {
  //       formData.files.add(
  //         MapEntry("AttachmentsFile", await MultipartFile.fromFile(path)),
  //       );
  //     }

  //     // Only set companyid and Authorization as headers
  //     final headers = Map<String, dynamic>.from(_dio.options.headers);
  //     debugPrint(formData.fields.toString());
  //     debugPrint(formData.files.toString());
  //     debugPrint(headers.toString());
  //     final response = await _dio.post(
  //       '$baseUrl$endpoint',
  //       data: formData,
  //       options: Options(
  //         headers: headers,
  //         // Do NOT set content-type here, let Dio set it automatically
  //       ),
  //     );
  //     return response.statusCode == 200 && response.data['success'] == true;
  //   } catch (e) {
  //     debugPrint("Error in uploadAttachments: $e");
  //     return false;
  //   }
  // }

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
      await _setupHeaders();
      final baseUrl = await _getBaseUrl();
      const endpoint = "/api/Lead/uploadAttachmentnew2";
      final documentNumber = "$documentNo/LEADENTRY";

      // Create FormData for the multipart request
      final formData = FormData();

      // Add ALL fields from FileAttachmentModel as form fields
      formData.fields.addAll([
        MapEntry("LocationID", locationId.toString()),
        MapEntry("CompanyID", companyId.toString()),
        MapEntry("CompanyCode", companyCode),
        MapEntry("LocationCode", locationCode),
        MapEntry("DocYear", docYear),
        MapEntry("FormID", formId),
        MapEntry("DocumentNo", documentNumber),
        MapEntry("DocumentID", documentId),
      ]);

      // Add files correctly
      for (final path in filePaths) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            "AttachmentsFile",
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

      final headers = Map<String, dynamic>.from(_dio.options.headers);
      headers.remove('Content-Type');

      debugPrint("Form fields: ${formData.fields}");
      debugPrint("Form files count: ${formData.files.length}");

      final response = await _dio.post(
        '$baseUrl$endpoint',
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data', // Explicitly set this
          followRedirects: false,
        ),
      );

      debugPrint("Upload response: ${response.statusCode}");
      debugPrint("Response data: ${response.data}");
      return response.statusCode == 200 && response.data['Success'] == true;
    } catch (e) {
      debugPrint("Error in uploadAttachments: $e");
      if (e is DioException) {
        debugPrint("Status code: ${e.response?.statusCode}");
        debugPrint("Error response: ${e.response?.data}");
        debugPrint("Request: ${e.requestOptions.uri}");
        debugPrint("Headers sent: ${e.requestOptions.headers}");
      }
      return false;
    }
  }

  // Add this method to your LeadFormService class
  Future<List<LeadData>?> fetchLeadByNumber({
    required String leadNumber,
    required int userId,
  }) async {
    try {
      final baseUrl = await StorageUtils.readValue('url');
      final url = 'http://$baseUrl/api/Lead/inquiryEntryList';

      final response = await _dio.post(
        url,
        data: {
          "restcoresalestrans": "false",
          "userId": userId,
          "pageSize": 100,
          "pageNumber": 1,
          "sortField": "",
          "sortDirection": "",
          "searchValue": leadNumber,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        if (data.isNotEmpty) {
          return data.map((item) => LeadData.fromJson(item)).toList();
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching lead by number: $e');
      return null;
    }
  }
}
