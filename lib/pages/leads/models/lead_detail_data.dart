class LeadDetailItem {
  final String modelNo;
  final String salesItemCode;
  final String uom;
  final double itemQty;
  final double basicPrice;
  final String application;
  final String pdo;
  final String inquiryStatus;
  final String ximfugid;
  final String currencyCode;
  final String itemName;
  final String salesItemType;
  final String precision;
  final String customerPoItemSrNo;
  final String customerItemCode;
  final String customerItemName;
  final int lnNumber;
  final int lineNo;
  final String applicationCode;
  final String productSize;
  final String invoiceType;
  final bool allowChange;
  final bool dispatchWithoutMfg;

  LeadDetailItem({
    required this.modelNo,
    required this.salesItemCode,
    required this.uom,
    required this.itemQty,
    required this.basicPrice,
    required this.application,
    required this.pdo,
    required this.inquiryStatus,
    required this.ximfugid,
    required this.currencyCode,
    required this.itemName,
    required this.salesItemType,
    required this.precision,
    required this.customerPoItemSrNo,
    required this.customerItemCode,
    required this.customerItemName,
    required this.lnNumber,
    required this.lineNo,
    required this.applicationCode,
    required this.productSize,
    required this.invoiceType,
    required this.allowChange,
    required this.dispatchWithoutMfg,
  });

  factory LeadDetailItem.fromJson(Map<String, dynamic> json) => LeadDetailItem(
    modelNo: json['modelNo'] ?? '',
    salesItemCode: json['salesItemCode'] ?? '',
    uom: json['uom'] ?? '',
    itemQty: (json['itemQty'] ?? 0).toDouble(),
    basicPrice: (json['basicPrice'] ?? 0).toDouble(),
    application: json['application'] ?? '',
    pdo: json['pdo'] ?? '',
    inquiryStatus: json['inquiryStatus'] ?? '',
    ximfugid: json['ximfugid'] ?? '',
    currencyCode: json['currencyCode'] ?? '',
    itemName: json['itemName'] ?? '',
    salesItemType: json['salesItemType'] ?? '',
    precision: json['precision'] ?? '',
    customerPoItemSrNo: json['customerPoItemSrNo'] ?? '',
    customerItemCode: json['customerItemCode'] ?? '',
    customerItemName: json['customerItemName'] ?? '',
    lnNumber: json['lnNumber'] ?? 0,
    lineNo: json['lineNo'] ?? 0,
    applicationCode: json['applicationCode'] ?? '',
    productSize: json['productSize'] ?? '',
    invoiceType: json['invoiceType'] ?? '',
    allowChange: json['allowChange'] ?? false,
    dispatchWithoutMfg: json['dispatchWithoutMfg'] ?? false,
  );
}

class LeadDetailData {
  final int inquiryID;
  final String customerCode;
  final String customerName;
  final int inquirySiteId;
  final String inquiryYear;
  final String inquiryGroup;
  final String inquiryNumber;
  final String inquiryDate;
  final String salesmanCode;
  final String salesRegionCode;
  final String inquirySource;
  final String inquirySourceDesc;
  final String remarks;
  final String nextFollowup;
  final String tenderNumber;
  final String emdRequiredDate;
  final double emdAmount;
  final String emdEndDate;
  final String inquiryRefNumber;
  final String inquiryStatus;
  final String salesmanName;
  final String locationCode;
  final String salesRegionCodeDesc;
  final String sourceName;
  final int customerContactID;
  final int projectItemID;
  final String inquiryType;
  final String itemCode;
  final String itemName;
  final String consultantCode;
  final String consultantName;
  final String customerFullName;
  final String salesmanFullName;
  final String regionFullName;
  final String consultantFullName;
  final String itemFullName;
  final List<LeadDetailItem> inqEntryItemModel;

  LeadDetailData({
    required this.inquiryID,
    required this.customerCode,
    required this.customerName,
    required this.inquirySiteId,
    required this.inquiryYear,
    required this.inquiryGroup,
    required this.inquiryNumber,
    required this.inquiryDate,
    required this.salesmanCode,
    required this.salesRegionCode,
    required this.inquirySource,
    required this.inquirySourceDesc,
    required this.remarks,
    required this.nextFollowup,
    required this.tenderNumber,
    required this.emdRequiredDate,
    required this.emdAmount,
    required this.emdEndDate,
    required this.inquiryRefNumber,
    required this.inquiryStatus,
    required this.salesmanName,
    required this.locationCode,
    required this.salesRegionCodeDesc,
    required this.sourceName,
    required this.customerContactID,
    required this.projectItemID,
    required this.inquiryType,
    required this.itemCode,
    required this.itemName,
    required this.consultantCode,
    required this.consultantName,
    required this.customerFullName,
    required this.salesmanFullName,
    required this.regionFullName,
    required this.consultantFullName,
    required this.itemFullName,
    required this.inqEntryItemModel,
  });

  factory LeadDetailData.fromJson(Map<String, dynamic> json) => LeadDetailData(
    inquiryID: json['inquiryID'] ?? 0,
    customerCode: json['customerCode'] ?? '',
    customerName: json['customerName'] ?? '',
    inquirySiteId: json['inquirySiteId'] ?? 0,
    inquiryYear: json['inquiryYear'] ?? '',
    inquiryGroup: json['inquiryGroup'] ?? '',
    inquiryNumber: json['inquiryNumber'] ?? '',
    inquiryDate: json['inquiryDate'] ?? '',
    salesmanCode: json['salesmanCode'] ?? '',
    salesRegionCode: json['salesRegionCode'] ?? '',
    inquirySource: json['inquirySource'] ?? '',
    inquirySourceDesc: json['inquirySourceDesc'] ?? '',
    remarks: json['remarks'] ?? '',
    nextFollowup: json['nextFollowup'] ?? '',
    tenderNumber: json['tenderNumber'] ?? '',
    emdRequiredDate: json['emdRequiredDate'] ?? '',
    emdAmount: (json['emdAmount'] ?? 0).toDouble(),
    emdEndDate: json['emdEndDate'] ?? '',
    inquiryRefNumber: json['inquiryRefNumber'] ?? '',
    inquiryStatus: json['inquiryStatus'] ?? '',
    salesmanName: json['salesmanName'] ?? '',
    locationCode: json['locationCode'] ?? '',
    salesRegionCodeDesc: json['salesRegionCodeDesc'] ?? '',
    sourceName: json['sourceName'] ?? '',
    customerContactID: json['customerContactID'] ?? 0,
    projectItemID: json['projectItemID'] ?? 0,
    inquiryType: json['inquiryType'] ?? '',
    itemCode: json['itemCode'] ?? '',
    itemName: json['itemName'] ?? '',
    consultantCode: json['consultantCode'] ?? '',
    consultantName: json['consultantName'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
    salesmanFullName: json['salesmanFullName'] ?? '',
    regionFullName: json['regionFullName'] ?? '',
    consultantFullName: json['consultantFullName'] ?? '',
    itemFullName: json['itemFullName'] ?? '',
    inqEntryItemModel:
        (json['inqEntryItemModel'] as List<dynamic>? ?? [])
            .map((e) => LeadDetailItem.fromJson(e))
            .toList(),
  );
}
