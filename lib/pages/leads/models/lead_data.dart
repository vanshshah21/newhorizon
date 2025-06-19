// class LeadData {
//   final int totalRows;
//   final int inquiryID;
//   final String inquiryYear;
//   final String inquiryDate;
//   final String inquiryGroup;
//   final String locationCode;
//   final String locationName;
//   final String inquiryNumber;
//   final String customerCode;
//   final String customerName;
//   final String? salesItemCode;
//   final String? salesItemName;
//   final String salesmanCode;
//   final String salesmanName;
//   final String salesRegionCode;
//   final String? mobile;
//   final String? email;
//   final String salesRegionCodeDesc;
//   final String inquiryRef;
//   final String? consultantCode;
//   final String? consultantName;
//   final String inquiryType;
//   final String inquiryTypeText;
//   final int projectItem;
//   final String? itemCode;
//   final String? itemName;
//   final String updatedDate;
//   final String xininqstat;
//   final String inquiryStatus;
//   final bool isEdit;
//   final bool isDelete;
//   final int folloupRefId;
//   final int folloupAutoId;
//   final String customerFullName;
//   final String salesmanFullName;
//   final String regionFullName;
//   final String consultantFullName;
//   final String itemFullName;
//   final double salesItemQty;
//   final double salesItemPrice;
//   final String flwquoremarks;

//   LeadData({
//     required this.totalRows,
//     required this.inquiryID,
//     required this.inquiryYear,
//     required this.inquiryDate,
//     required this.inquiryGroup,
//     required this.locationCode,
//     required this.locationName,
//     required this.inquiryNumber,
//     required this.customerCode,
//     required this.customerName,
//     required this.salesItemCode,
//     required this.salesItemName,
//     required this.salesmanCode,
//     required this.salesmanName,
//     required this.salesRegionCode,
//     required this.mobile,
//     required this.email,
//     required this.salesRegionCodeDesc,
//     required this.inquiryRef,
//     required this.consultantCode,
//     required this.consultantName,
//     required this.inquiryType,
//     required this.inquiryTypeText,
//     required this.projectItem,
//     required this.itemCode,
//     required this.itemName,
//     required this.updatedDate,
//     required this.xininqstat,
//     required this.inquiryStatus,
//     required this.isEdit,
//     required this.isDelete,
//     required this.folloupRefId,
//     required this.folloupAutoId,
//     required this.customerFullName,
//     required this.salesmanFullName,
//     required this.regionFullName,
//     required this.consultantFullName,
//     required this.itemFullName,
//     required this.salesItemQty,
//     required this.salesItemPrice,
//     required this.flwquoremarks,
//   });

//   factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
//     totalRows: json['totalRows'] ?? 0,
//     inquiryID: json['inquiryID'] ?? 0,
//     inquiryYear: json['inquiryYear'] ?? '',
//     inquiryDate: json['inquiryDate'] ?? '',
//     inquiryGroup: json['inquiryGroup'] ?? '',
//     locationCode: json['locationCode'] ?? '',
//     locationName: json['locationName'] ?? '',
//     inquiryNumber: json['inquiryNumber'] ?? '',
//     customerCode: json['customerCode'] ?? '',
//     customerName: json['customerName'] ?? '',
//     salesItemCode: json['salesItemCode'],
//     salesItemName: json['salesItemName'],
//     salesmanCode: json['salesmanCode'] ?? '',
//     salesmanName: json['salesmanName'] ?? '',
//     salesRegionCode: json['salesRegionCode'] ?? '',
//     mobile: json['mobile'],
//     email: json['email'],
//     salesRegionCodeDesc: json['salesRegionCodeDesc'] ?? '',
//     inquiryRef: json['inquiryRef'] ?? '',
//     consultantCode: json['consultantCode'],
//     consultantName: json['consultantName'],
//     inquiryType: json['inquiryType'] ?? '',
//     inquiryTypeText: json['inquiryTypeText'] ?? '',
//     projectItem: json['projectItem'] ?? 0,
//     itemCode: json['itemCode'],
//     itemName: json['itemName'],
//     updatedDate: json['updatedDate'] ?? '',
//     xininqstat: json['xininqstat'] ?? '',
//     inquiryStatus: json['inquiryStatus'] ?? '',
//     isEdit: json['isEdit'] ?? false,
//     isDelete: json['isDelete'] ?? false,
//     folloupRefId: json['folloupRefId'] ?? 0,
//     folloupAutoId: json['folloupAutoId'] ?? 0,
//     customerFullName: json['customerFullName'] ?? '',
//     salesmanFullName: json['salesmanFullName'] ?? '',
//     regionFullName: json['regionFullName'] ?? '',
//     consultantFullName: json['consultantFullName'] ?? '',
//     itemFullName: json['itemFullName'] ?? '',
//     salesItemQty: (json['salesItemQty'] ?? 0).toDouble(),
//     salesItemPrice: (json['salesItemPrice'] ?? 0).toDouble(),
//     flwquoremarks: json['flwquoremarks'] ?? '',
//   );
// }

class LeadEntryItemModel {
  final String modelNo;
  final String salesItemCode;
  final String uom;
  final double itemQty;
  final double basicPrice;
  final String application;
  final String? pdo;
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

  LeadEntryItemModel({
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

  factory LeadEntryItemModel.fromJson(Map<String, dynamic> json) =>
      LeadEntryItemModel(
        modelNo: json['modelNo'] ?? '',
        salesItemCode: json['salesItemCode'] ?? '',
        uom: json['uom'] ?? '',
        itemQty: (json['itemQty'] ?? 0).toDouble(),
        basicPrice: (json['basicPrice'] ?? 0).toDouble(),
        application: json['application'] ?? '',
        pdo: json['pdo'],
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

class LeadData {
  final int totalRows;
  final int inquiryID;
  final String inquiryYear;
  final String inquiryDate;
  final String inquiryGroup;
  final String locationCode;
  final String locationName;
  final String inquiryNumber;
  final String customerCode;
  final String customerName;
  final String? salesItemCode;
  final String? salesItemName;
  final String salesmanCode;
  final String salesmanName;
  final String salesRegionCode;
  final String? mobile;
  final String? email;
  final String salesRegionCodeDesc;
  final String? inquiryRef;
  final String? consultantCode;
  final String? consultantName;
  final String? inquiryType;
  final String inquiryTypeText;
  final int projectItem;
  final String? itemCode;
  final String? itemName;
  final String updatedDate;
  final String xininqstat;
  final String inquiryStatus;
  final bool isEdit;
  final bool isDelete;
  final int folloupRefId;
  final int folloupAutoId;
  final String customerFullName;
  final String salesmanFullName;
  final String regionFullName;
  final String consultantFullName;
  final String itemFullName;
  final double salesItemQty;
  final double salesItemPrice;
  final String? flwquoremarks;
  final List<LeadEntryItemModel> inqEntryItemModel;

  LeadData({
    required this.totalRows,
    required this.inquiryID,
    required this.inquiryYear,
    required this.inquiryDate,
    required this.inquiryGroup,
    required this.locationCode,
    required this.locationName,
    required this.inquiryNumber,
    required this.customerCode,
    required this.customerName,
    required this.salesItemCode,
    required this.salesItemName,
    required this.salesmanCode,
    required this.salesmanName,
    required this.salesRegionCode,
    required this.mobile,
    required this.email,
    required this.salesRegionCodeDesc,
    required this.inquiryRef,
    required this.consultantCode,
    required this.consultantName,
    required this.inquiryType,
    required this.inquiryTypeText,
    required this.projectItem,
    required this.itemCode,
    required this.itemName,
    required this.updatedDate,
    required this.xininqstat,
    required this.inquiryStatus,
    required this.isEdit,
    required this.isDelete,
    required this.folloupRefId,
    required this.folloupAutoId,
    required this.customerFullName,
    required this.salesmanFullName,
    required this.regionFullName,
    required this.consultantFullName,
    required this.itemFullName,
    required this.salesItemQty,
    required this.salesItemPrice,
    required this.flwquoremarks,
    required this.inqEntryItemModel,
  });

  factory LeadData.fromJson(Map<String, dynamic> json) => LeadData(
    totalRows: json['totalRows'] ?? 0,
    inquiryID: json['inquiryID'] ?? 0,
    inquiryYear: json['inquiryYear'] ?? '',
    inquiryDate: json['inquiryDate'] ?? '',
    inquiryGroup: json['inquiryGroup'] ?? '',
    locationCode: json['locationCode'] ?? '',
    locationName: json['locationName'] ?? '',
    inquiryNumber: json['inquiryNumber'] ?? '',
    customerCode: json['customerCode'] ?? '',
    customerName: json['customerName'] ?? '',
    salesItemCode: json['salesItemCode'],
    salesItemName: json['salesItemName'],
    salesmanCode: json['salesmanCode'] ?? '',
    salesmanName: json['salesmanName'] ?? '',
    salesRegionCode: json['salesRegionCode'] ?? '',
    mobile: json['mobile'],
    email: json['email'],
    salesRegionCodeDesc: json['salesRegionCodeDesc'] ?? '',
    inquiryRef: json['inquiryRef'],
    consultantCode: json['consultantCode'],
    consultantName: json['consultantName'],
    inquiryType: json['inquiryType'],
    inquiryTypeText: json['inquiryTypeText'] ?? '',
    projectItem: json['projectItem'] ?? 0,
    itemCode: json['itemCode'],
    itemName: json['itemName'],
    updatedDate: json['updatedDate'] ?? '',
    xininqstat: json['xininqstat'] ?? '',
    inquiryStatus: json['inquiryStatus'] ?? '',
    isEdit: json['isEdit'] == true || json['isEdit'] == 1,
    isDelete: json['isDelete'] == true || json['isDelete'] == 1,
    folloupRefId: json['folloupRefId'] ?? 0,
    folloupAutoId: json['folloupAutoId'] ?? 0,
    customerFullName: json['customerFullName'] ?? '',
    salesmanFullName: json['salesmanFullName'] ?? '',
    regionFullName: json['regionFullName'] ?? '',
    consultantFullName: json['consultantFullName'] ?? '',
    itemFullName: json['itemFullName'] ?? '',
    salesItemQty: (json['salesItemQty'] ?? 0).toDouble(),
    salesItemPrice: (json['salesItemPrice'] ?? 0).toDouble(),
    flwquoremarks: json['flwquoremarks'],
    inqEntryItemModel:
        (json['inqEntryItemModel'] as List<dynamic>?)
            ?.map((e) => LeadEntryItemModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}
