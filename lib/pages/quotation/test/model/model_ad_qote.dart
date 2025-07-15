import 'package:flutter/material.dart';
import 'package:nhapp/utils/storage_utils.dart';

late String currencyCode;

// Function to initialize the global currency code
Future<void> initializeCurrencyCode() async {
  try {
    final domCurrency = await StorageUtils.readJson('domestic_currency');
    currencyCode = domCurrency?['domCurCode'] ?? 'INR';
  } catch (e) {
    currencyCode = 'INR'; // Fallback to default if an error occurs
  }
}

class Customer {
  final String customerCode;
  final String customerName;
  final String gstNumber;
  final String telephoneNo;
  final String customerFullName;

  Customer({
    required this.customerCode,
    required this.customerName,
    required this.gstNumber,
    required this.telephoneNo,
    required this.customerFullName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      gstNumber: json['gstno'] ?? json['gstNumber'] ?? '',
      telephoneNo: json['telephoneNo'] ?? '',
      customerFullName: json['customerFullName'] ?? '',
    );
  }
}

class QuotationBase {
  final String code;
  final String name;

  QuotationBase({required this.code, required this.name});

  factory QuotationBase.fromJson(Map<String, dynamic> json) {
    return QuotationBase(code: json['Code'] ?? '', name: json['Name'] ?? '');
  }
}

class Salesman {
  final String salesmanCode;
  final String salesmanName;
  final String salesManFullName;

  Salesman({
    required this.salesmanCode,
    required this.salesmanName,
    required this.salesManFullName,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) {
    return Salesman(
      salesmanCode: json['salesmanCode'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      salesManFullName: json['salesManFullName'] ?? '',
    );
  }
}

class Inquiry {
  final String inquiryNumber;
  final int inquiryId;
  final String customerName;

  Inquiry({
    required this.inquiryNumber,
    required this.inquiryId,
    required this.customerName,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      inquiryNumber: json['inquiryNumber'] ?? '',
      inquiryId: json['inquiryId'] ?? 0,
      customerName: json['customerName'] ?? '',
    );
  }
}

class DiscountCode {
  final String code;
  final String description;
  final String codeFullName;

  DiscountCode({
    required this.code,
    required this.description,
    required this.codeFullName,
  });

  factory DiscountCode.fromJson(Map<String, dynamic> json) {
    return DiscountCode(
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      codeFullName: json['codeFullName'] ?? '',
    );
  }
}

class DocumentDetail {
  final String documentString;
  final String lastSrNo;
  final String groupCode;
  final int locationId;
  final String locationCode;
  final String locationName;
  final String isDefault;
  final bool isLocationRequired;
  final bool isAutoNumberGenerated;
  final bool isAutorisationRequired;
  final String groupDescription;
  final String locationFullName;
  final String groupFullName;

  DocumentDetail({
    required this.documentString,
    required this.lastSrNo,
    required this.groupCode,
    required this.locationId,
    required this.locationCode,
    required this.locationName,
    required this.isDefault,
    required this.isLocationRequired,
    required this.isAutoNumberGenerated,
    required this.isAutorisationRequired,
    required this.groupDescription,
    required this.locationFullName,
    required this.groupFullName,
  });

  factory DocumentDetail.fromJson(Map<String, dynamic> json) {
    return DocumentDetail(
      documentString: json['documentString'] ?? '',
      lastSrNo: json['lastSrNo'] ?? '',
      groupCode: json['groupCode'] ?? '',
      locationId: json['locationId'] ?? 0,
      locationCode: json['locationCode'] ?? '',
      locationName: json['locationName'] ?? '',
      isDefault: json['isDefault'] ?? '',
      isLocationRequired: json['isLocationRequired'] ?? false,
      isAutoNumberGenerated: json['isAutoNumberGenerated'] ?? false,
      isAutorisationRequired: json['isAutorisationRequired'] ?? false,
      groupDescription: json['groupDescription'] ?? '',
      locationFullName: json['locationFullName'] ?? '',
      groupFullName: json['groupFullName'] ?? '',
    );
  }
}

class SalesItem {
  final String itemCode;
  final String itemName;
  final String salesUOM;
  final String hsnCode;
  final String salesItemFullName;

  SalesItem({
    required this.itemCode,
    required this.itemName,
    required this.salesUOM,
    required this.hsnCode,
    required this.salesItemFullName,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      salesUOM: json['salesUOM'] ?? 'NOS',
      hsnCode: json['hsnCode'] ?? '',
      salesItemFullName: json['salesItemFullName'] ?? '',
    );
  }
}

class RateStructure {
  final String rateStructCode;
  final String rateStructDesc;
  final String rateStructFullName;

  RateStructure({
    required this.rateStructCode,
    required this.rateStructDesc,
    required this.rateStructFullName,
  });

  factory RateStructure.fromJson(Map<String, dynamic> json) {
    return RateStructure(
      rateStructCode: json['rateStructCode'] ?? '',
      rateStructDesc: json['rateStructDesc'] ?? '',
      rateStructFullName: json['rateStructFullName'] ?? '',
    );
  }
}

Future<String> getCurrencyCode() async {
  final domCurrency = await StorageUtils.readJson('domestic_currency');
  if (domCurrency == null) throw Exception("Domestic currency not set");
  return domCurrency['domCurCode'] ?? 'INR';
}

class QuotationItem {
  final String itemName;
  final String itemCode;
  final double qty;
  final double basicRate;
  final String uom;
  final String discountType;
  final double? discountPercentage;
  final double? discountAmount;
  final String? discountCode; // This field already exists
  final String rateStructure;
  final double? taxAmount;
  final double totalAmount;
  final List<Map<String, dynamic>>? rateStructureRows;
  int lineNo;
  final String? hsnCode;
  final bool isFromInquiry;

  QuotationItem({
    required this.itemName,
    required this.itemCode,
    required this.qty,
    required this.basicRate,
    required this.uom,
    required this.discountType,
    this.discountPercentage,
    this.discountAmount,
    this.discountCode,
    required this.rateStructure,
    this.taxAmount,
    required this.totalAmount,
    this.rateStructureRows,
    required this.lineNo,
    this.hsnCode,
    this.isFromInquiry = false,
  });

  Map<String, dynamic> toModelDetail() {
    return {
      "itemLineNo": lineNo,
      "customerCode": "",
      "quotationOrderNumber": "",
      "modelNo": "",
      "salesItemCode": itemCode,
      "qtyIUOM": qty,
      "basicPriceIUOM": basicRate,
      "discountType": discountType,
      "discountValue": discountPercentage ?? 0,
      "discountAmt": (discountAmount ?? 0).toStringAsFixed(2),
      "qtySUOM": qty,
      "basicPriceSUOM": basicRate,
      "conversionFactor": 1,
      "itemOrderQty": 0,
      "allQty": 0,
      "amendmentSrNo": "0",
      "cancelQty": 0,
      "salesItemType": "M",
      "currencyCode": currencyCode,
      "rateProcess": "N",
      "rateStructureCode": rateStructure,
      "tolerance": 0,
      "amendmentYear": "",
      "amendmentGroup": "",
      "amendmentSiteId": 0,
      "amendmentNo": "",
      "amendmentDate": null,
      "amendmentAuthBy": 0,
      "amendmentAuthDate": null,
      "invoiceMethod": "Q",
      "agentCode": "",
      "subProjectId": 0,
      "sectionId": 0,
      "groupId": 0,
      "subGroupId": 0,
      "customerPOItemSrNo": lineNo,
      "drawingNo": "",
      "quotationLineNo": 0,
      "quotationAmendNo": 0,
      "amendmentChargable": "A",
      "amendmentCBOMChange": "A",
      "oldCustomerPOReference": "",
      "reasonCode": "",
      "salesReasonCode": "",
      "deliveryDay": 0,
      "invoiceType": "Regular",
      "oldSalesItemCode": "",
      "oldInternalItemCode": "",
      "itemAmountAfterDisc": (basicRate * qty) - (discountAmount ?? 0),
      "isGroupSpare": "",
      "hsnCode": hsnCode ?? "",
      "detaildescription": "",
      "loadRate": 0,
      "netRate":
          qty > 0 ? ((basicRate * qty) - (discountAmount ?? 0)) / qty : 0,
    };
  }

  Map<String, dynamic> toDiscountDetail() {
    // Only create discount detail if there's actually a discount
    if (discountType == "None" || (discountAmount ?? 0) <= 0) {
      return {};
    }

    return {
      "salesItemCode": itemCode,
      "currencyCode": currencyCode,
      "discountCode":
          discountCode ??
          (discountType == "Percentage"
              ? "DISC"
              : "01"), // Use selected code or fallback
      "discountType": discountType,
      "discountValue":
          discountType == "Percentage"
              ? (discountPercentage ?? 0) // Use percentage value
              : (discountAmount ?? 0), // Use absolute amount
      "amendSrNo": "0",
      "itmLineNo": lineNo,
    };
  }

  // List<Map<String, dynamic>> toRateStructureDetails() {
  //   if (rateStructureRows == null) return [];
  //   return rateStructureRows!.map((item) {
  //     debugPrint("Rate Structure Item: $item");
  //     return {
  //       "customerItemCode": itemCode,
  //       "rateCode": item['rateCode'] ?? item['msprtcd'],
  //       "incOrExc": item['incExc'] ?? item['mspincexc'],
  //       "perOrVal": item['perValueCode'] ?? item['mspperval'],
  //       "taxValue":
  //           item['taxValue']?.toString() ??
  //           item['msprtval']?.toString() ??
  //           "0.00",
  //       "applicationOn": item['applicableOn'] ?? item['mtrslvlno'] ?? "",
  //       "currencyCode": item['curCode'] ?? item['mprcurcode'] ?? "INR",
  //       "sequenceNo":
  //           item['seqNo']?.toString() ?? item['mspseqno']?.toString() ?? "1",
  //       "postNonPost":
  //           item['pNYN'] ??
  //           item['msppnyn'] == "True" || item['msppnyn'] == true,
  //       "taxType": item['taxType'] ?? item['mprtaxtyp'],
  //       "rateSturctureCode": rateStructure,
  //       "rateAmount": item['rateAmount'] ?? 0,
  //       "amendSrNo": "0",
  //       "refId": 0,
  //       "itmModelRefNo": lineNo,
  //     };
  //   }).toList();
  // }

  List<Map<String, dynamic>> toRateStructureDetails() {
    if (rateStructureRows == null || rateStructureRows!.isEmpty) return [];

    print("Converting rate structure rows: $rateStructureRows"); // Debug log

    return rateStructureRows!
        .map(
          (row) => {
            // Map to the exact C# model properties
            "CustomerItemCode": itemCode, // XDTDTMCD
            "RateCode": row['rateCode'] ?? '', // XDTDRATECD
            "IncOrExc": row['ie'] ?? 'E', // XDTDINCEXC
            "PerOrVal": row['pv'] ?? 'V', // XDTDPERVAL
            "TaxValue": (row['taxValue'] ?? 0.0).toDouble(), // XDTDPERCVAL
            "ApplicationOn": row['applicableOn'] ?? '', // XDTDAPPON
            "CurrencyCode": currencyCode, // XDTDCURCODE, MPRCURCODE
            "SequenceNo": row['sequenceNo'] ?? 0, // XDTDSEQNO
            "PostNonPost": row['postnonpost'] ?? true, // XDTDPNYN
            "TaxType": row['mprtaxtyp'] ?? '', // XDTDTAXTYP, MPRTAXTYP
            "RateSturctureCode": rateStructure, // XDTDRTSTRCD
            "RateAmount":
                (row['rateAmount'] ?? 0.0)
                    .toDouble(), // XDTDRATEAMT - This is the calculated amount
            "AmendSrNo": 0, // XDTDAMDSRNO
            // Additional fields that might be needed for processing
            "itmModelRefNo": lineNo,
            "refId": 0,
          },
        )
        .toList();
  }
}

class QuotationDetails {
  final List<Map<String, dynamic>> itemDetail;
  final List<Map<String, dynamic>>? rateStructDetail;
  final List<Map<String, dynamic>>? discountDetail;

  QuotationDetails({
    required this.itemDetail,
    this.rateStructDetail,
    this.discountDetail,
  });

  factory QuotationDetails.fromJson(Map<String, dynamic> json) {
    return QuotationDetails(
      itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
      rateStructDetail:
          json['rateStructDetail'] != null
              ? List<Map<String, dynamic>>.from(json['rateStructDetail'])
              : null,
      discountDetail:
          json['discountDetail'] != null
              ? List<Map<String, dynamic>>.from(json['discountDetail'])
              : null,
    );
  }
}

class QuotationEditData {
  final List<Map<String, dynamic>>? quotationDetails;
  final List<Map<String, dynamic>>? modelDetails;
  final List<Map<String, dynamic>>? discountDetails;
  final List<Map<String, dynamic>>? rateStructureDetails;
  final List<Map<String, dynamic>>? termDetails;
  final List<Map<String, dynamic>>? subItemDetails;
  final List<Map<String, dynamic>>? attachmentDetails;
  final List<Map<String, dynamic>>? historyDetails;
  final List<Map<String, dynamic>>? addOnDetails;
  final List<Map<String, dynamic>>? standardTerms;
  final List<Map<String, dynamic>>? noteDetails;
  final List<Map<String, dynamic>>? quotationRemarks;
  final List<Map<String, dynamic>>? equipmentAttributeDetails;
  final List<Map<String, dynamic>>? quotationTextDetails;
  final List<Map<String, dynamic>>? technicalspec;
  final List<Map<String, dynamic>>? lastSalesRecords;
  final List<Map<String, dynamic>>? lastPORecords;

  // Computed properties for backward compatibility
  String get quotationNumber =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['quotationNumber']?.toString() ?? ''
          : '';

  int get quotationId =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['quotationId'] ?? 0
          : 0;

  String get customerCode =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['customerCode'] ?? ''
          : '';

  String get customerName =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['customerName'] ?? ''
          : '';

  String get billToCustomerCode =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['billToCustomerCode'] ?? ''
          : '';

  String get billToCustomerName =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['billToCustomerName'] ?? ''
          : '';

  String get salesmanCode =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['salesPersonCode'] ?? ''
          : '';

  String get subject =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['subject'] ?? ''
          : '';

  DateTime get quotationDate =>
      quotationDetails?.isNotEmpty == true
          ? DateTime.tryParse(quotationDetails!.first['quotationDate'] ?? '') ??
              DateTime.now()
          : DateTime.now();

  String get quotationBase =>
      quotationDetails?.isNotEmpty == true
          ? _mapQuotationBase(quotationDetails!.first['quotationGroup'] ?? '')
          : 'R';

  int? get inquiryId =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['inquiryId']
          : null;

  String get inquiryNumber =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['inquiryNumber'] ?? ''
          : '';

  String get quotationYear =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['quotationYear'] ?? ''
          : '';

  String get quotationGroup =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['quotationGroup'] ?? ''
          : '';

  int get quotationSiteId =>
      quotationDetails?.isNotEmpty == true
          ? quotationDetails!.first['quotationSiteId'] ?? 0
          : 0;

  QuotationEditData({
    this.quotationDetails,
    this.modelDetails,
    this.discountDetails,
    this.rateStructureDetails,
    this.termDetails,
    this.subItemDetails,
    this.attachmentDetails,
    this.historyDetails,
    this.addOnDetails,
    this.standardTerms,
    this.noteDetails,
    this.quotationRemarks,
    this.equipmentAttributeDetails,
    this.quotationTextDetails,
    this.technicalspec,
    this.lastSalesRecords,
    this.lastPORecords,
  });

  factory QuotationEditData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return QuotationEditData(
      quotationDetails:
          data['quotationDetails'] != null
              ? List<Map<String, dynamic>>.from(data['quotationDetails'])
              : null,
      modelDetails:
          data['modelDetails'] != null
              ? List<Map<String, dynamic>>.from(data['modelDetails'])
              : null,
      discountDetails:
          data['discountDetails'] != null
              ? List<Map<String, dynamic>>.from(data['discountDetails'])
              : null,
      rateStructureDetails:
          data['rateStructureDetails'] != null
              ? List<Map<String, dynamic>>.from(data['rateStructureDetails'])
              : null,
      termDetails:
          data['termDetails'] != null
              ? List<Map<String, dynamic>>.from(data['termDetails'])
              : null,
      subItemDetails:
          data['subItemDetails'] != null
              ? List<Map<String, dynamic>>.from(data['subItemDetails'])
              : null,
      attachmentDetails:
          data['attachmentDetails'] != null
              ? List<Map<String, dynamic>>.from(data['attachmentDetails'])
              : null,
      historyDetails:
          data['historyDetails'] != null
              ? List<Map<String, dynamic>>.from(data['historyDetails'])
              : null,
      addOnDetails:
          data['addOnDetails'] != null
              ? List<Map<String, dynamic>>.from(data['addOnDetails'])
              : null,
      standardTerms:
          data['standardTerms'] != null
              ? List<Map<String, dynamic>>.from(data['standardTerms'])
              : null,
      noteDetails:
          data['noteDetails'] != null
              ? List<Map<String, dynamic>>.from(data['noteDetails'])
              : null,
      quotationRemarks:
          data['quotationRemarks'] != null
              ? List<Map<String, dynamic>>.from(data['quotationRemarks'])
              : null,
      equipmentAttributeDetails:
          data['equipmentAttributeDetails'] != null
              ? List<Map<String, dynamic>>.from(
                data['equipmentAttributeDetails'],
              )
              : null,
      quotationTextDetails:
          data['quotationTextDetails'] != null
              ? List<Map<String, dynamic>>.from(data['quotationTextDetails'])
              : null,
      technicalspec:
          data['technicalspec'] != null
              ? List<Map<String, dynamic>>.from(data['technicalspec'])
              : null,
      lastSalesRecords:
          data['lastSalesRecords'] != null
              ? List<Map<String, dynamic>>.from(data['lastSalesRecords'])
              : null,
      lastPORecords:
          data['lastPORecords'] != null
              ? List<Map<String, dynamic>>.from(data['lastPORecords'])
              : null,
    );
  }

  // Helper method to map quotation group to quotation base
  String _mapQuotationBase(String quotationGroup) {
    switch (quotationGroup.toUpperCase()) {
      case 'SQ':
        return 'R'; // Regular
      case 'IQ':
        return 'I'; // Inquiry
      default:
        return 'R';
    }
  }

  // Get items as QuotationItem objects
  List<QuotationItem> get items {
    if (modelDetails == null || modelDetails!.isEmpty) return [];

    List<QuotationItem> quotationItems = [];

    for (int i = 0; i < modelDetails!.length; i++) {
      final modelDetail = modelDetails![i];

      // Calculate discount details
      String discountType = "None";
      double? discountPercentage;
      double? discountAmount = modelDetail['discountAmt']?.toDouble() ?? 0.0;
      String? discountCode;

      // Get discount code from discount details if available
      if (discountDetails != null && discountDetails!.isNotEmpty) {
        final itemDiscountDetail = discountDetails!.firstWhere(
          (discount) => discount['itmLineNo'] == modelDetail['itemLineNo'],
          orElse: () => <String, dynamic>{},
        );
        if (itemDiscountDetail.isNotEmpty) {
          discountCode = itemDiscountDetail['discountCode'];
        }
      }

      if (discountAmount! > 0) {
        final basicAmount =
            (modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0) *
            (modelDetail['qtySUOM']?.toDouble() ?? 0.0);
        if (basicAmount > 0) {
          discountType = "Value";
          discountPercentage = (discountAmount! / basicAmount) * 100;
        }
      }

      // Get rate structure details for this item
      final itemRateStructureDetails =
          rateStructureDetails
              ?.where((rs) => rs['lineNo'] == modelDetail['itemLineNo'])
              .toList() ??
          [];

      // Calculate tax amount from rate structure details
      double taxAmount = 0.0;
      for (final rsDetail in itemRateStructureDetails) {
        taxAmount += (rsDetail['rateAmount']?.toDouble() ?? 0.0);
      }

      // Calculate correct total amount using the same logic as ad_qote.dart
      final basicAmount =
          (modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0) *
          (modelDetail['qtySUOM']?.toDouble() ?? 0.0);
      final netAmount = basicAmount - discountAmount;
      final totalAmount = netAmount + taxAmount;

      final item = QuotationItem(
        itemName: modelDetail['salesItemDesc'] ?? '',
        itemCode: modelDetail['salesItemCode'] ?? '',
        qty: modelDetail['qtySUOM']?.toDouble() ?? 0.0,
        basicRate: modelDetail['basicPriceSUOM']?.toDouble() ?? 0.0,
        uom: modelDetail['uom'] ?? 'NOS',
        discountType: discountType,
        discountPercentage: discountPercentage,
        discountAmount: discountAmount > 0 ? discountAmount : null,
        discountCode: discountCode, // Include discount code from API data
        rateStructure: modelDetail['rateStructureCode'] ?? '',
        taxAmount: taxAmount,
        totalAmount: totalAmount, // Use calculated total amount
        rateStructureRows:
            itemRateStructureDetails.isNotEmpty
                ? List<Map<String, dynamic>>.from(itemRateStructureDetails)
                : null,
        lineNo: modelDetail['itemLineNo'] ?? (i + 1),
        hsnCode: modelDetail['hsnCode'] ?? '',
        isFromInquiry: (inquiryId ?? 0) > 0,
      );

      quotationItems.add(item);
    }

    return quotationItems;
  }
}
