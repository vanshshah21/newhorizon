import 'dart:convert';

import 'package:nhapp/utils/storage_utils.dart';

late String currencyCode;

// Function to initialize the global currency code
Future<void> initializeCurrencyCode() async {
  try {
    final domCurrencyRaw = await StorageUtils.readJson('domestic_currency');
    if (domCurrencyRaw == null) throw Exception("Domestic currency not set");

    final domCurrency =
        domCurrencyRaw is String
            ? jsonDecode(domCurrencyRaw) as Map<String, dynamic>
            : domCurrencyRaw;

    currencyCode = domCurrency['domCurCode'] ?? 'INR';
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

class DocumentDetail {
  final String documentString;
  final String lastSrNo;
  final String groupCode;
  final int locationId;
  final String locationCode;
  final String locationName;

  DocumentDetail({
    required this.documentString,
    required this.lastSrNo,
    required this.groupCode,
    required this.locationId,
    required this.locationCode,
    required this.locationName,
  });

  factory DocumentDetail.fromJson(Map<String, dynamic> json) {
    return DocumentDetail(
      documentString: json['documentString'] ?? '',
      lastSrNo: json['lastSrNo'] ?? '',
      groupCode: json['groupCode'] ?? '',
      locationId: json['locationId'] ?? 0,
      locationCode: json['locationCode'] ?? '',
      locationName: json['locationName'] ?? '',
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

// class QuotationNumber {
//   final int quotationId;
//   final String quotationNumber;
//   final String quotationYear;
//   final String quotationGroup;
//   final DateTime quotationDate;

//   QuotationNumber({
//     required this.quotationId,
//     required this.quotationNumber,
//     required this.quotationYear,
//     required this.quotationGroup,
//     required this.quotationDate,
//   });

//   factory QuotationNumber.fromJson(Map<String, dynamic> json) {
//     return QuotationNumber(
//       quotationId: json['quotationId'] ?? 0,
//       quotationNumber: json['quotationNumber'] ?? '',
//       quotationYear: json['quotationYear'] ?? '',
//       quotationGroup: json['quotationGroup'] ?? '',
//       quotationDate: DateTime.parse(
//         json['quotationDate'] ?? DateTime.now().toIso8601String(),
//       ),
//     );
//   }
// }
// ...existing code...

class QuotationNumber {
  final bool select;
  final String customerCode;
  final int quotationID;
  final String qtnNumber;
  final DateTime quotationDate;
  final int revisionNo;
  final DateTime? revisionDate;
  final String quotationCurrency;
  final String agentCode;
  final String inquiryNo;
  final DateTime? inquiryDate;
  final String salesmanCode;
  final String salesmanName;
  final String consultantCode;
  final String consultantName;
  final String gstno;
  final String quotationYear;
  final String quotationGroup;
  final String quotationNumber;
  final String quotationSiteCode;
  final int quotationSiteId;

  QuotationNumber({
    required this.select,
    required this.customerCode,
    required this.quotationID,
    required this.qtnNumber,
    required this.quotationDate,
    required this.revisionNo,
    this.revisionDate,
    required this.quotationCurrency,
    required this.agentCode,
    required this.inquiryNo,
    this.inquiryDate,
    required this.salesmanCode,
    required this.salesmanName,
    required this.consultantCode,
    required this.consultantName,
    required this.gstno,
    required this.quotationYear,
    required this.quotationGroup,
    required this.quotationNumber,
    required this.quotationSiteCode,
    required this.quotationSiteId,
  });

  factory QuotationNumber.fromJson(Map<String, dynamic> json) {
    return QuotationNumber(
      select: json['select'] ?? false,
      customerCode: json['customerCode'] ?? '',
      quotationID: json['quotationID'] ?? 0,
      qtnNumber: json['qtnNumber'] ?? '',
      quotationDate: DateTime.parse(json['quotationDate']),
      revisionNo: json['revisionNo'] ?? 0,
      revisionDate:
          json['revisionDate'] != null
              ? DateTime.parse(json['revisionDate'])
              : null,
      quotationCurrency: json['quotationCurrency'] ?? '',
      agentCode: json['agentCode'] ?? '',
      inquiryNo: json['inquiryNo'] ?? '',
      inquiryDate:
          json['inquiryDate'] != null
              ? DateTime.parse(json['inquiryDate'])
              : null,
      salesmanCode: json['salesmanCode'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      consultantCode: json['consultantCode'] ?? '',
      consultantName: json['consultantName'] ?? '',
      gstno: json['gstno'] ?? '',
      quotationYear: json['quotationYear'] ?? '',
      quotationGroup: json['quotationGroup'] ?? '',
      quotationNumber: json['quotationNumber'] ?? '',
      quotationSiteCode: json['quotationSiteCode'] ?? '',
      quotationSiteId: json['quotationSiteId'] ?? 0,
    );
  }
}

class QuotationItemDetail {
  final bool select;
  final String salesItemCode;
  final String salesItemDesc;
  final String uom;
  final double itemQtySUOM;
  final double itemRate;
  final double itemValue;
  final int quotationId;
  final int itemLineNo;
  final String currencyCode;
  final String quotationStatus;
  final double conversionFactor;
  final int amendSrNo;
  final String agentCode;

  QuotationItemDetail({
    required this.select,
    required this.salesItemCode,
    required this.salesItemDesc,
    required this.uom,
    required this.itemQtySUOM,
    required this.itemRate,
    required this.itemValue,
    required this.quotationId,
    required this.itemLineNo,
    required this.currencyCode,
    required this.quotationStatus,
    required this.conversionFactor,
    required this.amendSrNo,
    required this.agentCode,
  });

  factory QuotationItemDetail.fromJson(Map<String, dynamic> json) {
    return QuotationItemDetail(
      select: json['select'] ?? false,
      salesItemCode: json['salesItemCode'] ?? '',
      salesItemDesc: json['salesItemDesc'] ?? '',
      uom: json['uom'] ?? '',
      itemQtySUOM: (json['itemQtySUOM'] ?? 0).toDouble(),
      itemRate: (json['itemRate'] ?? 0).toDouble(),
      itemValue: (json['itemValue'] ?? 0).toDouble(),
      quotationId: json['quotationId'] ?? 0,
      itemLineNo: json['itemLineNo'] ?? 0,
      currencyCode: json['currencyCode'] ?? '',
      quotationStatus: json['quotationStatus'] ?? '',
      conversionFactor: (json['conversionFactor'] ?? 1.0).toDouble(),
      amendSrNo: json['amendSrNo'] ?? 0,
      agentCode: json['agentCode'] ?? '',
    );
  }
}

class QuotationListResponse {
  final List<QuotationNumber> quotationDetails;
  final List<QuotationItemDetail> quotationItemDetails;

  QuotationListResponse({
    required this.quotationDetails,
    required this.quotationItemDetails,
  });

  factory QuotationListResponse.fromJson(Map<String, dynamic> json) {
    return QuotationListResponse(
      quotationDetails:
          (json['quotationDetails'] as List? ?? [])
              .map((item) => QuotationNumber.fromJson(item))
              .toList(),
      quotationItemDetails:
          (json['quotationItemDetails'] as List? ?? [])
              .map((item) => QuotationItemDetail.fromJson(item))
              .toList(),
    );
  }
}

class QuotationDetails {
  final List<Map<String, dynamic>> modelDetails;
  final List<Map<String, dynamic>>? rateStructDetail;
  final List<Map<String, dynamic>>? discountDetail;
  final List<Map<String, dynamic>>? quotationDetails;
  final List<Map<String, dynamic>>? rateStructureDetails;

  QuotationDetails({
    required this.modelDetails,
    this.rateStructDetail,
    this.discountDetail,
    this.quotationDetails,
    this.rateStructureDetails,
  });

  factory QuotationDetails.fromJson(Map<String, dynamic> json) {
    return QuotationDetails(
      modelDetails: List<Map<String, dynamic>>.from(json['modelDetails'] ?? []),
      discountDetail:
          json['discountDetails'] != null
              ? List<Map<String, dynamic>>.from(json['discountDetails'])
              : null,
      quotationDetails:
          json['quotationDetails'] != null
              ? List<Map<String, dynamic>>.from(json['quotationDetails'])
              : null,
      rateStructureDetails:
          json['rateStructureDetails'] != null
              ? List<Map<String, dynamic>>.from(json['rateStructureDetails'])
              : null,
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

class SalesOrderItem {
  final String itemName;
  final String itemCode;
  final double qty;
  final double basicRate;
  final String uom;
  final String discountType;
  final double? discountPercentage;
  final double? discountAmount;
  final String? discountCode; // Add this field
  final String rateStructure;
  final double? taxAmount;
  final double totalAmount;
  final List<Map<String, dynamic>>? rateStructureRows;
  int lineNo;
  final String? hsnCode;

  SalesOrderItem({
    required this.itemName,
    required this.itemCode,
    required this.qty,
    required this.basicRate,
    required this.uom,
    required this.discountType,
    this.discountPercentage,
    this.discountAmount,
    this.discountCode, // Add this parameter
    required this.rateStructure,
    this.taxAmount,
    required this.totalAmount,
    this.rateStructureRows,
    required this.lineNo,
    this.hsnCode,
  });

  Map<String, dynamic> toModelDetail() {
    final DiscountAmt =
        discountType == "P" || discountType == "Percentage"
            ? (discountPercentage! / 100) * (basicRate * qty)
            : discountType == "V" || discountType == "Value"
            ? discountAmount ?? 0.0
            : 0.0;
    return {
      "itemLineNo": lineNo,
      "DocType": "O",
      "Status": "O",
      "custPONumber": "",
      "modelNo": "",
      "salesItemCode": itemCode,
      "qtyIUOM": qty.toStringAsFixed(4),
      "basicPriceIUOM": basicRate,
      "discountType":
          discountType == "P" || discountType == "Percentage"
              ? "Percentage"
              : discountType == "V" || discountType == "Value"
              ? "Value"
              : "None",
      "discountValue":
          discountType == "P" || discountType == "Percentage"
              ? discountPercentage?.toString() ?? 0.0
              : discountType == "V" || discountType == "Value"
              ? discountAmount?.toString() ?? 0.0
              : 0.0,
      "discountAmt": DiscountAmt,
      "qtySUOM": qty,
      "basicPriceSUOM": basicRate,
      "conversionFactor": 1,
      "itemOrderQty": qty,
      "allQty": 0,
      "amendmentSrNo": 0,
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
      "customerPOItemSrNo": lineNo.toString(),
      "customerItemCode": "",
      "drawingNo": "",
      "customerItemName": "",
      "applicationCode": "",
      "tagNo": "",
      "agentCommisionType": "None",
      "agentCommisionValue": 0,
      "quotationId": 0,
      "quotationLineNo": 0,
      "quotationAmendNo": 0,
      "amendmentChargable": "",
      "amendmentCBOMChange": "",
      "isSubItem": false,
      "oldCustomerPOReference": "",
      "reasonCode": "",
      "salesReasonCode": "",
      "invoiceType": "Regular",
      "oldIORef": 0,
      "oldSalesItemCode": "",
      "oldInternalItemCode": "",
      "itemAmountAfterDisc": (basicRate * qty) - (DiscountAmt ?? 0),
      "isGroupSpare": "",
      "subProjectId": 0,
      "sectionId": 0,
      "groupId": 0,
      "subGroupId": 0,
      "HSNCode": hsnCode ?? "",
      "mainitemcode": "",
      "detaildescription": "",
      "printseq": "",
      "loadRate": 0,
      "netRate": qty > 0 ? ((basicRate * qty) - (DiscountAmt ?? 0)) / qty : 0,
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
      "discountCode": discountCode, // Use selected code or fallback
      "discountType":
          discountType == "P" || discountType == "Percentage"
              ? "Percentage"
              : discountType == "V" || discountType == "Value"
              ? "Value"
              : "None",
      "discountValue":
          discountType == "Percentage" || discountType == "P"
              ? (discountPercentage ?? 0) // Use percentage value
              : (discountAmount ?? 0), // Use absolute amount
      "amendYear": "",
      "amendGroup": "",
      "amendSiteId": 0,
      "amendNumber": "",
      "amendDate": null,
      "amendSrNo": 0,
      "amendAuthDate": null,
      "itmLineNo": lineNo,
    };
  }

  List<Map<String, dynamic>> toRateStructureDetails() {
    if (rateStructureRows == null || rateStructureRows!.isEmpty) return [];

    print("Converting rate structure rows: $rateStructureRows"); // Debug log

    return rateStructureRows!
        .map(
          (row) => {
            // Map to the exact C# model properties - same as quotation
            "customerItemCode": itemCode, // XDTDTMCD
            "rateCode": row['rateCode'] ?? '', // XDTDRATECD
            "incOrExc": row['ie'] ?? 'E', // XDTDINCEXC
            "perOrVal": row['pv'] ?? 'V', // XDTDPERVAL
            "taxValue":
                row['taxValue'] is String
                    ? double.parse(row['taxValue'])
                    : (row['taxValue'] ?? 0.0), // XDTDPERCVAL
            "ApplicationOn":
                row['appOnDisplay'] ??
                row['applicationOn'] ??
                row['applicableOn'] ??
                '', // XDTDAPPON
            "currencyCode": "INR", // XDTDCURCODE, MPRCURCODE
            "sequenceNo": row['sequenceNo'] ?? 0, // XDTDSEQNO
            "postNonPost": row['postnonpost'] ?? true, // XDTDPNYN
            "taxType": row['mprtaxtyp'] ?? '', // XDTDTAXTYP, MPRTAXTYP
            "rateSturctureCode": rateStructure, // XDTDRTSTRCD
            "rateAmount":
                row['rateAmount'] is String
                    ? double.parse(row['rateAmount'])
                    : (row['rateAmount'] ?? 0.0)
                        as double, // XDTDRATEAMT - This is the calculated amount
            "amendSrNo": 0, // XDTDAMDSRNO
            // Additional fields that might be needed for processing
            "itmModelRefNo": lineNo,
            "refId": 0,
          },
        )
        .toList();
  }
}
