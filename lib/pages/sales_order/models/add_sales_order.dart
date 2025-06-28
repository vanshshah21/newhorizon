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
          json['discountDetail'] != null
              ? List<Map<String, dynamic>>.from(json['discountDetail'])
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

class SalesOrderItem {
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

  SalesOrderItem({
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
  });

  Map<String, dynamic> toModelDetail() {
    return {
      "itemLineNo": lineNo,
      "DocType": "O",
      "custPONumber": "",
      "modelNo": "",
      "salesItemCode": itemCode,
      "qtyIUOM": qty.toStringAsFixed(4),
      "basicPriceIUOM": basicRate,
      "discountType": discountType,
      "discountValue": discountPercentage ?? 0,
      "discountAmt": (discountAmount ?? 0).toStringAsFixed(4),
      "qtySUOM": qty,
      "basicPriceSUOM": basicRate,
      "conversionFactor": 1,
      "itemOrderQty": qty,
      "allQty": 0,
      "amendmentSrNo": 0,
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
      "itemAmountAfterDisc": (basicRate * qty) - (discountAmount ?? 0),
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
      "netRate":
          qty > 0 ? ((basicRate * qty) - (discountAmount ?? 0)) / qty : 0,
    };
  }

  Map<String, dynamic> toDiscountDetail() {
    if (discountType == "None" || (discountAmount ?? 0) == 0) return {};

    return {
      "salesItemCode": itemCode,
      "currencyCode": "INR",
      "discountCode": discountType == "Percentage" ? "001" : "01",
      "discountType": discountType,
      "discountValue": discountPercentage ?? (discountAmount ?? 0),
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
    if (rateStructureRows == null) return [];

    return rateStructureRows!.map((item) {
      return {
        "customerItemCode": itemCode,
        "rateCode": item['rateCode'] ?? item['msprtcd'],
        "incOrExc": item['incOrExc'] ?? item['mspincexc'],
        "perOrVal": item['perOrVal'] ?? item['mspperval'],
        "taxValue":
            item['taxValue']?.toString() ??
            item['msprtval']?.toString() ??
            "0.00",
        "applicationOn": item['applicableOn'] ?? item['mtrslvlno'] ?? "",
        "currencyCode": item['curCode'] ?? item['mprcurcode'] ?? "INR",
        "sequenceNo":
            item['seqNo']?.toString() ?? item['mspseqno']?.toString() ?? "1",
        "postnonpost":
            item['pNYN'] ??
            item['msppnyn'] == "True" || item['msppnyn'] == true,
        "rateSturctureCode": rateStructure,
        "rateAmount": item['rateAmount'] ?? 0,
        "amendSrNo": 0,
        "refId": lineNo - 1,
        "actual": item['atActual'] ?? true,
        "itmModelRefNo": lineNo,
      };
    }).toList();
  }
}
