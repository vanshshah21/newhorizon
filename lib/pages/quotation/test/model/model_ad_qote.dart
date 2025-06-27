import 'package:flutter/material.dart';

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

class QuotationItem {
  final String itemName;
  final String itemCode;
  final double qty;
  final double basicRate;
  final String uom;
  final String discountType;
  final double? discountPercentage;
  final double? discountAmount;
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
      "currencyCode": "INR",
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
    if (discountType == "None" || (discountAmount ?? 0) == 0)
      return {
        "salesItemCode": itemCode,
        "currencyCode": "INR",
        "discountCode": discountType == "Percentage" ? "001" : "01",
        "discountType": discountType,
        "discountValue": discountPercentage ?? (discountAmount ?? 0),
        "amendSrNo": "0",
        "itmLineNo": lineNo,
      };
    ;

    return {
      "salesItemCode": itemCode,
      "currencyCode": "INR",
      "discountCode": discountType == "Percentage" ? "001" : "01",
      "discountType": discountType,
      "discountValue": discountPercentage ?? (discountAmount ?? 0),
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
            "CurrencyCode": "INR", // XDTDCURCODE, MPRCURCODE
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
