class QuotationListItem {
  final int totalRows;
  final int qtnID;
  final String qtnYear;
  final String qtnGroup;
  final int siteId;
  final String siteCode;
  final String siteFullName;
  final String qtnNumber;
  final String date;
  final String customerCode;
  final String customerFullName;
  final int revisionNo;
  final bool isAuthorized;
  final bool isEdit;
  final String pendingBy;
  final List<QuotationItemDetail> itemDetailsList;
  final String? quotationStatus;
  final bool directSalesOrderEntry;

  QuotationListItem({
    required this.totalRows,
    required this.qtnID,
    required this.qtnYear,
    required this.qtnGroup,
    required this.siteId,
    required this.siteCode,
    required this.siteFullName,
    required this.qtnNumber,
    required this.date,
    required this.customerCode,
    required this.customerFullName,
    required this.revisionNo,
    required this.isAuthorized,
    required this.isEdit,
    required this.pendingBy,
    required this.itemDetailsList,
    required this.quotationStatus,
    required this.directSalesOrderEntry,
  });

  factory QuotationListItem.fromJson(Map<String, dynamic> json) {
    return QuotationListItem(
      totalRows: json['totalRows'] ?? 0,
      qtnID: json['qtnID'] ?? 0,
      qtnYear: json['qtnYear'] ?? '',
      qtnGroup: json['qtnGroup'] ?? '',
      siteId: json['siteId'] ?? 0,
      siteCode: json['siteCode'] ?? '',
      siteFullName: json['siteFullName'] ?? '',
      qtnNumber: json['qtnNumber'] ?? '',
      date: json['date'] ?? '',
      customerCode: json['customerCode'] ?? '',
      customerFullName: json['customerFullName'] ?? '',
      revisionNo: json['revisionNo'] ?? 0,
      isAuthorized: json['isAuthorized'] ?? false,
      isEdit: json['isEdit'] ?? false,
      pendingBy: json['pendingBy'] ?? '',
      itemDetailsList:
          (json['itemDetailsList'] as List<dynamic>? ?? [])
              .map((e) => QuotationItemDetail.fromJson(e))
              .toList(),
      quotationStatus: json['quotationStatus'],
      directSalesOrderEntry: json['directSalesOrderEntry'] ?? false,
    );
  }
}

class QuotationItemDetail {
  final int qtnID;
  final String itemCode;
  final String itemName;
  final String qty;
  final String uom;
  final String rate;

  QuotationItemDetail({
    required this.qtnID,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.uom,
    required this.rate,
  });

  factory QuotationItemDetail.fromJson(Map<String, dynamic> json) {
    return QuotationItemDetail(
      qtnID: json['qtnID'] ?? 0,
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      qty: json['qty'] ?? '',
      uom: json['uom'] ?? '',
      rate: json['rate'] ?? '',
    );
  }
}
