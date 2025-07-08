import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhapp/pages/quotation/test/model/model_ad_qote.dart';
import 'package:nhapp/utils/storage_utils.dart';

class QuotationService {
  late final Dio _dio;
  late final String _baseUrl;
  late final Map<String, dynamic> companyDetails;
  late final Map<String, dynamic> tokenDetails;
  late final Map<String, dynamic> locationDetails;
  late final Map<String, dynamic> financeDetails;
  late final Map<String, dynamic> currencyDetails;
  late int companyId;

  QuotationService._();

  static Future<QuotationService> create() async {
    final service = QuotationService._();
    await service._initializeService();
    return service;
  }

  Future<void> _initializeService() async {
    _baseUrl = "http://${await StorageUtils.readValue('url') ?? ""}";

    companyDetails = await StorageUtils.readJson('selected_company');
    if (companyDetails.isEmpty) throw Exception("Company not set");
    locationDetails = await StorageUtils.readJson('selected_location');
    if (locationDetails.isEmpty) throw Exception("Location not set");
    tokenDetails = await StorageUtils.readJson('session_token');
    if (tokenDetails.isEmpty) throw Exception("Session token not found");
    financeDetails = await StorageUtils.readJson('finance_period');
    if (financeDetails.isEmpty) throw Exception("Finance details not found");
    currencyDetails = await StorageUtils.readJson('domestic_currency');
    if (currencyDetails.isEmpty) throw Exception("Currency details not found");

    companyId = companyDetails['id'];
    final token = tokenDetails['token']['value'];

    _dio = Dio();
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['companyid'] = companyId.toString();
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // --- API Methods ---

  Future<DocumentDetail> fetchDefaultDocumentDetail(String type) async {
    String endpoint = "/api/Lead/GetDefaultDocumentDetail";
    final year = financeDetails['financialYear'];
    final locationId = locationDetails['id'];

    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          "year": year,
          "type": type,
          "subType": type,
          "locationId": locationId,
        },
      );
      return DocumentDetail.fromJson(response.data['data'][0]);
    } catch (e) {
      throw Exception("Failed to fetch document detail: $e");
    }
  }

  Future getExchangeRate() async {
    const endpoint = "/api/Quotation/GetExchangeRate";
    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {"currencyCode": currencyDetails['domCurCode']},
      );
      if (response.data['success'] == true) {
        return response.data['data'][0]['exchangeRate'];
      } else {
        throw Exception("Failed to fetch exchange rate");
      }
    } catch (e) {
      throw Exception("Failed to fetch exchange rate: $e");
    }
  }

  Future<List<QuotationBase>> fetchQuotationBaseList() async {
    const endpoint = "/api/Quotation/QuotationBaseList";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");
      final data = response.data['data'] as List;
      return data.map((item) => QuotationBase.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch quotation base list: $e");
    }
  }

  Future<List<Customer>> fetchCustomerSuggestions(String pattern) async {
    const endpoint = "/api/Quotation/QuotationGetCustomer";
    final body = {
      "PageSize": 10,
      "PageNumber": 1,
      "SortField": "",
      "SortDirection": "",
      "SearchValue": pattern,
      "UserId": tokenDetails['user']['id'],
    };

    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: body);
      final data = response.data['data'] as List;
      return data.map((item) => Customer.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch customer suggestions: $e");
    }
  }

  Future<List<Salesman>> fetchSalesmanList() async {
    const endpoint = "/api/Lead/LeadSalesManList";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");
      final data = response.data['data'] as List;
      return data.map((item) => Salesman.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch salesman list: $e");
    }
  }

  Future<List<Inquiry>> fetchInquiryList(String customerCode) async {
    const endpoint = "/api/Quotation/QuotationInquirygetOpenInquiryNumberList";
    final locationCode = locationDetails['code'];
    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          "customercode": customerCode,
          "userlocationcodes": "'$locationCode'",
        },
      );
      final data = response.data['data'] as List;
      return data.map((item) => Inquiry.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch inquiry list: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchInquiryDetail(int inquiryId) async {
    const endpoint = "/API/Quotation/QuotationInquirygetInquiryDetail";
    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {"InquiryId": inquiryId},
      );
      return response.data['data'];
    } catch (e) {
      throw Exception("Failed to fetch inquiry detail: $e");
    }
  }

  Future<List<SalesItem>> fetchSalesItemList(String pattern) async {
    const endpoint = "/api/Lead/GetSalesItemList?flag=L";
    final body = {
      "pageSize": 10,
      "pageNumber": 1,
      "sortField": "",
      "sortDirection": "",
      "searchValue": pattern,
    };

    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: body);
      final data = response.data['data'] as List;
      return data.map((item) => SalesItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch sales item list: $e");
    }
  }

  Future<List<RateStructure>> fetchRateStructures() async {
    const endpoint = "/api/Quotation/QuotationGetRateStructureForSales";
    try {
      final response = await _dio.get(
        "$_baseUrl$endpoint",
        queryParameters: {
          'companyID': companyId.toString(),
          'currencyCode': 'INR',
        },
      );
      final data = response.data['data'] as List;
      return data.map((item) => RateStructure.fromJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to fetch rate structures: $e");
    }
  }

  Future<List<DiscountCode>> fetchDiscountCodes() async {
    const endpoint =
        "/api/Quotation/QuotationGetDiscount?codeType=DD&codeValue=GEN";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");

      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        return data.map((item) => DiscountCode.fromJson(item)).toList();
      } else {
        throw Exception(
          "Failed to fetch discount codes: ${response.data['errorMessage']}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch discount codes: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchRateStructureDetails(
    String rateStructureCode,
  ) async {
    final endpoint =
        "/api/Quotation/QuotationSelectOnRateStruCode?rateStructureCode=$rateStructureCode";
    try {
      final response = await _dio.get("$_baseUrl$endpoint");
      return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
    } catch (e) {
      throw Exception("Failed to fetch rate structure details: $e");
    }
  }

  // List<Map<String, dynamic>> buildRateStructureDetails(
  //   List<Map<String, dynamic>> rateStructureRows,
  //   String itemCode,
  //   int itmModelRefNo,
  // ) {
  //   print(
  //     "Building rate structure details for itemCode: $itemCode",
  //   ); // Debug log
  //   print("Input rateStructureRows: $rateStructureRows"); // Debug log

  //   final templist =
  //       rateStructureRows
  //           .where((x) => (x['itmModelRefNo'] ?? 1) == itmModelRefNo)
  //           .toList();

  //   final result =
  //       templist.map((item) {
  //         return {
  //           'rateCode': item['rateCode'] ?? item['msprtcd'] ?? '',
  //           'rateDesc': item['rateDesc'] ?? item['mprrtdesc'] ?? '',
  //           'ie': item['incExc'] ?? item['mspincexc'] ?? 'E',
  //           'pv': item['perValueCode'] ?? item['mspperval'] ?? 'V',
  //           'applicableOn': item['applicableOn'] ?? item['mtrslvlno'] ?? "",
  //           'appOnDisplay': item['appOnDisplay'] ?? item['mspappondesc'] ?? "",
  //           'taxValue':
  //               double.tryParse(
  //                 item['taxValue']?.toString() ??
  //                     item['msprtval']?.toString() ??
  //                     "0.00",
  //               ) ??
  //               0.0,
  //           'prevTaxValue':
  //               double.tryParse(
  //                 item['taxValue']?.toString() ??
  //                     item['msprtval']?.toString() ??
  //                     "0.00",
  //               ) ??
  //               0.0,
  //           'postnonpost':
  //               item['pNYN'] ??
  //               (item['msppnyn'] == "True" || item['msppnyn'] == true),
  //           'rateAmount': 0.0, // Will be calculated by API
  //           'currencyCode': item['curCode'] ?? item['mprcurcode'] ?? "INR",
  //           'itmModelRefNo': itmModelRefNo,
  //           'sequenceNo':
  //               int.tryParse(
  //                 item['seqNo']?.toString() ??
  //                     item['mspseqno']?.toString() ??
  //                     "1",
  //               ) ??
  //               1,
  //           'taxType': item['taxType'] ?? item['mprtaxtyp'] ?? '',
  //           'itemCode': itemCode,
  //           'uniqueno': 0,
  //           // Additional fields for compatibility
  //           'salItemCode': itemCode,
  //           'customerItemCode': itemCode,
  //           'print': item['isPrint'] ?? item['print'] ?? false,
  //           'mprroundoff': item['roundOff'] ?? item['mprroundoff'] ?? false,
  //           'totalAmount': 0.0,
  //         };
  //       }).toList();

  //   print("Built rate structure details: $result"); // Debug log
  //   return result;
  // }

  List<Map<String, dynamic>> buildRateStructureDetails(
    List<Map<String, dynamic>> rateStructureRows,
    String itemCode,
    int itmModelRefNo,
  ) {
    print(
      "Building rate structure details for itemCode: $itemCode",
    ); // Debug log
    print("Input rateStructureRows: $rateStructureRows"); // Debug log

    final templist =
        rateStructureRows
            .where((x) => (x['itmModelRefNo'] ?? 1) == itmModelRefNo)
            .toList();

    final result =
        templist.map((item) {
          return {
            // Fields for API call (different from submission format)
            'rateCode': item['rateCode'] ?? item['msprtcd'] ?? '',
            'rateDesc': item['rateDesc'] ?? item['mprrtdesc'] ?? '',
            'ie': item['incExc'] ?? item['mspincexc'] ?? item['ie'] ?? 'E',
            'pv':
                item['perValueCode'] ?? item['mspperval'] ?? item['pv'] ?? 'V',
            'applicableOn': item['applicableOn'] ?? item['mtrslvlno'] ?? "",
            'appOnDisplay': item['appOnDisplay'] ?? item['mspappondesc'] ?? "",
            'taxValue':
                double.tryParse(
                  item['taxValue']?.toString() ??
                      item['msprtval']?.toString() ??
                      "0.00",
                ) ??
                0.0,
            'prevTaxValue':
                double.tryParse(
                  item['taxValue']?.toString() ??
                      item['msprtval']?.toString() ??
                      "0.00",
                ) ??
                0.0,
            'postnonpost': item['pNYN'] ?? item['msppnyn'] == true,
            'rateAmount': 0.0, // Will be calculated by API
            'currencyCode': item['curCode'] ?? item['mprcurcode'] ?? "INR",
            'itmModelRefNo': itmModelRefNo,
            'sequenceNo':
                int.tryParse(
                  item['seqNo']?.toString() ??
                      item['mspseqno']?.toString() ??
                      "1",
                ) ??
                1,
            'taxType': item['taxType'] ?? item['mprtaxtyp'] ?? '',
            'itemCode': itemCode,
            'uniqueno': 0,
            // Additional fields for compatibility
            'salItemCode': itemCode,
            'customerItemCode': itemCode,
            'print': item['isPrint'] ?? item['print'] ?? false,
            'mprroundoff': item['roundOff'] ?? item['mprroundoff'] ?? false,
            'totalAmount': 0.0,
            'atactual': item['atactual'] ?? false,
            'flagWantCalcAmtTaxChangetaxVal':
                item['flagWantCalcAmtTaxChangetaxVal'] ?? false,
            // 'mprchngtxval': item['mprchngtxval'] ?? 0,
          };
        }).toList();

    print("Built rate structure details: $result"); // Debug log
    return result;
  }

  Future<Map<String, dynamic>> calculateRateStructure(
    double itemAmount,
    String rateStructureCode,
    List<Map<String, dynamic>> rateStructureDetails,
    String itemCode,
  ) async {
    const endpoint = "/api/Quotation/CalcRateStructure";
    final body = {
      "ItemAmount": itemAmount,
      "ExchangeRt": "1",
      "DomCurrency": "INR",
      "CurrencyCode": "INR",
      "DiscType": "",
      "BasicRate": 0,
      "DiscValue": 0,
      "From": "sales",
      "Flag": "",
      "TotalItemAmount": itemAmount,
      "LandedPrice": 0,
      "uniqueno": 0,
      "RateCode": rateStructureCode,
      "RateStructureDetails": rateStructureDetails,
      "rateType": "P",
      "IsView": false,
    };

    try {
      print("Calling calculateRateStructure with body: $body"); // Debug log

      final response = await _dio.post(
        "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
        data: body,
      );

      print("API Response: ${response.data}"); // Debug log

      final responseData = response.data;

      // Process the response to map calculated amounts
      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];

        // Get the calculated rate amounts from listCalcRateReturnDetails
        final listCalcRateReturnDetails =
            data['listCalcRateReturnDetails'] as List?;

        if (listCalcRateReturnDetails != null &&
            listCalcRateReturnDetails.isNotEmpty) {
          // Create updated rate structure details based on original input + calculated amounts
          List<Map<String, dynamic>> updatedRateStructureDetails = [];

          for (final originalDetail in rateStructureDetails) {
            final originalRateCode = originalDetail['rateCode'];

            // Find matching calculated detail
            final calculatedDetail = listCalcRateReturnDetails.firstWhere(
              (calc) => calc['rateCode'] == originalRateCode,
              orElse: () => null,
            );

            // Create updated detail
            final updatedDetail = Map<String, dynamic>.from(originalDetail);

            if (calculatedDetail != null) {
              final calcRateAmount = calculatedDetail['rateAmount'] ?? 0.0;
              final calcRateAmountRounded =
                  calculatedDetail['rateAmountRounded'] ?? 0.0;

              // Use rounded amount if available, otherwise use regular amount
              updatedDetail['rateAmount'] =
                  calcRateAmountRounded > 0
                      ? calcRateAmountRounded
                      : calcRateAmount;

              print(
                "Updated rateCode $originalRateCode with amount: ${updatedDetail['rateAmount']}",
              ); // Debug log
            } else {
              updatedDetail['rateAmount'] = 0.0;
              print(
                "No calculated amount found for rateCode: $originalRateCode",
              ); // Debug log
            }

            updatedRateStructureDetails.add(updatedDetail);
          }

          // Update the response data with processed rate structure details
          data['rateStructureDetails'] = updatedRateStructureDetails;
          data['FinalrateStructureData'] = updatedRateStructureDetails;

          print(
            "Final processed rate structure details: $updatedRateStructureDetails",
          ); // Debug log
        } else {
          // No calculations available, use original structure with zero amounts
          final updatedRateStructureDetails =
              rateStructureDetails.map((detail) {
                final updatedDetail = Map<String, dynamic>.from(detail);
                updatedDetail['rateAmount'] = 0.0;
                return updatedDetail;
              }).toList();

          data['rateStructureDetails'] = updatedRateStructureDetails;
          data['FinalrateStructureData'] = updatedRateStructureDetails;

          print(
            "No listCalcRateReturnDetails found, using zero amounts",
          ); // Debug log
        }
      }

      return responseData;
    } catch (e, stackTrace) {
      print("Error in calculateRateStructure: $e"); // Debug log
      print("Stack trace: $stackTrace");

      // Return a proper error response structure
      return {
        'success': false,
        'errorMessage': 'Failed to calculate rate structure: $e',
        'data': null,
      };
    }
  }

  // Future<Map<String, dynamic>> calculateRateStructure(
  //   double itemAmount,
  //   String rateStructureCode,
  //   List<Map<String, dynamic>> rateStructureDetails,
  //   String itemCode,
  // ) async {
  //   const endpoint = "/api/Quotation/CalcRateStructure";
  //   final body = {
  //     "ItemAmount": itemAmount,
  //     "ExchangeRt": "1",
  //     "DomCurrency": "INR",
  //     "CurrencyCode": "INR",
  //     "DiscType": "",
  //     "BasicRate": 0,
  //     "DiscValue": 0,
  //     "From": "sales",
  //     "Flag": "",
  //     "TotalItemAmount": itemAmount,
  //     "LandedPrice": 0,
  //     "uniqueno": 0,
  //     "RateCode": rateStructureCode,
  //     "RateStructureDetails": rateStructureDetails,
  //     "rateType": "S",
  //     "IsView": false,
  //   };

  //   try {
  //     final response = await _dio.post(
  //       "$_baseUrl$endpoint?RateStructureCode=$rateStructureCode",
  //       data: body,
  //     );

  //     final responseData = response.data;
  //     late Map<String, dynamic> updatedData = {};
  //     // Process the response similar to web implementation
  //     if (responseData['data'] != null) {
  //       final data = responseData['data'];

  //       // Get the calculated rate amounts from listCalcRateReturnDetails
  //       final listCalcRateReturnDetails =
  //           data['listCalcRateReturnDetails'] as List?;
  //       final rateStructureDetailsResponse = rateStructureDetails;

  //       if (listCalcRateReturnDetails != null &&
  //           listCalcRateReturnDetails.isNotEmpty &&
  //           rateStructureDetailsResponse != null) {
  //         // Update rateAmount in rateStructureDetails based on listCalcRateReturnDetails
  //         for (final calcDetail in listCalcRateReturnDetails) {
  //           final calcRateCode = calcDetail['rateCode'];
  //           final calcRateAmount = calcDetail['rateAmount'] ?? 0.0;
  //           final calcRateAmountRounded =
  //               calcDetail['rateAmountRounded'] ?? 0.0;

  //           // Find matching rate structure detail
  //           for (final rateDetail in rateStructureDetailsResponse) {
  //             if (rateDetail['rateCode'] == calcRateCode) {
  //               // Check if rounding is required (mprroundoff flag)
  //               // final shouldRound =
  //               //     rateDetail['mprroundoff'] == true ||
  //               //     rateDetail['mprroundoff'] == 1 ||
  //               //     rateDetail['mprroundoff'] == "1" ||
  //               //     rateDetail['mprroundoff'] == "True";

  //               // if (shouldRound) {
  //               //   rateDetail['rateAmount'] = calcRateAmountRounded;
  //               // } else {
  //               //   rateDetail['rateAmount'] = calcRateAmount;
  //               // }
  //               rateDetail['rateAmount'] =
  //                   calcRateAmount ?? calcRateAmountRounded;
  //               break;
  //             }
  //           }
  //         }

  //         // Update the response data with processed rate structure details
  //         data['rateStructureDetails'] = rateStructureDetailsResponse;
  //         debugPrint(data);
  //         updatedData = data;
  //       }
  //     }

  //     return updatedData;
  //   } catch (e, stackTrace) {
  //     debugPrint("Error occurred: $e");
  //     debugPrint("Stack trace: $stackTrace");
  //     throw Exception("Failed to calculate rate structure: $e");
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
    const endpoint = "/api/Lead/uploadAttachmentnew2";
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry("LocationID", locationId.toString()),
        MapEntry("CompanyID", companyId.toString()),
        MapEntry("CompanyCode", companyCode),
        MapEntry("LocationCode", locationCode),
        MapEntry("DocYear", docYear),
        MapEntry("FormID", formId),
        MapEntry("DocumentNo", "$documentNo/QUOTATION"),
        MapEntry("DocumentID", documentId),
      ]);

      for (final path in filePaths) {
        final fileName = path.split('/').last;
        formData.files.add(
          MapEntry(
            "AttachmentsFile",
            await MultipartFile.fromFile(path, filename: fileName),
          ),
        );
      }

      final response = await _dio.post(
        "$_baseUrl$endpoint",
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          followRedirects: false,
        ),
      );
      return response.statusCode == 200 && response.data['Success'] == true;
    } catch (e) {
      throw Exception("Failed to upload attachments: $e");
    }
  }

  Future<Map<String, dynamic>> submitQuotation(
    Map<String, dynamic> payload,
  ) async {
    const endpoint = "/API/Quotation/QuotationCreate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data;
    } catch (e) {
      throw Exception("Failed to submit quotation: $e");
    }
  }

  Future<QuotationEditData> fetchQuotationForEdit(
    String quotationNumber,
    String quotationYear,
    String? quotationGrp,
    int? quotationSiteId,
  ) async {
    const endpoint = "/api/Quotation/QuotationGetDetails";
    try {
      final response = await _dio.post(
        "$_baseUrl$endpoint",
        queryParameters: {
          "QtnYear": quotationYear,
          "QtnGrp": quotationGrp,
          "QtnNumber": quotationNumber,
          "QtnSiteId": quotationSiteId,
          "UserLocations": "'${locationDetails['code']}'",
        },
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return QuotationEditData.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['errorMessage'] ?? 'Failed to fetch quotation details',
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch quotation for edit: $e");
    }
  }

  Future<Map<String, dynamic>> updateQuotation(
    Map<String, dynamic> payload,
  ) async {
    const endpoint = "/api/Quotation/QuotationUpdate";
    try {
      final response = await _dio.post("$_baseUrl$endpoint", data: payload);
      return response.data;
    } catch (e) {
      throw Exception("Failed to update quotation: $e");
    }
  }

  Future<Map<String, dynamic>> getSalesPolicy() async {
    try {
      final companyDetails = await StorageUtils.readJson('selected_company');
      if (companyDetails == null) throw Exception("Company not set");
      final companyCode = companyDetails['code'];
      const endpoint = "/api/Login/GetSalesPolicyDetails";
      final response = await _dio.get(
        '$_baseUrl$endpoint',
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
}
