class QuotationData {
  final int totalRows;
  final int qtnID;
  final String qtnYear;
  final String qtnGroup;
  final int siteId;
  final String siteCode;
  final String siteFullName;
  final String qtnNumber;
  final DateTime date;
  final String customerCode;
  final String customerFullName;
  final int revisionNo;
  final bool isAuthorized;
  final bool isEdit;
  final String pendingBy;
  final String? creatorName;
  final String? authorizerName;
  final List<QuotationItem> itemDetailsList;
  final String? quotationStatus;
  final bool directSalesOrderEntry;

  QuotationData({
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
    required this.creatorName,
    required this.authorizerName,
    required this.itemDetailsList,
    required this.quotationStatus,
    required this.directSalesOrderEntry,
  });

  factory QuotationData.fromJson(Map<String, dynamic> json) => QuotationData(
    totalRows: json['totalRows'] ?? 0,
    qtnID: json['qtnID'],
    qtnYear: json['qtnYear'] ?? '',
    qtnGroup: json['qtnGroup'] ?? '',
    siteId: json['siteId'],
    siteCode: json['siteCode'] ?? '',
    siteFullName: json['siteFullName'] ?? '',
    qtnNumber: json['qtnNumber'] ?? '',
    date: DateTime.parse(json['date']),
    customerCode: json['customerCode'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
    revisionNo: json['revisionNo'] ?? 0,
    isAuthorized: json['isAuthorized'] ?? false,
    isEdit: json['isEdit'] ?? false,
    pendingBy: json['pendingBy'] ?? '',
    creatorName: json['creatorName'],
    authorizerName: json['authorizerName'],
    itemDetailsList:
        (json['itemDetailsList'] as List<dynamic>?)
            ?.map((e) => QuotationItem.fromJson(e))
            .toList() ??
        [],
    quotationStatus: json['quotationStatus'],
    directSalesOrderEntry: json['directSalesOrderEntry'] ?? false,
  );
}

class QuotationItem {
  final int qtnID;
  final String itemCode;
  final String itemName;
  final double qty;
  final String uom;
  final double rate;

  QuotationItem({
    required this.qtnID,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.uom,
    required this.rate,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
    qtnID: json['qtnID'],
    itemCode: json['itemCode'] ?? '',
    itemName: json['itemName'] ?? '',
    qty: double.tryParse(json['qty'] ?? '0') ?? 0,
    uom: json['uom'] ?? '',
    rate: double.tryParse(json['rate'] ?? '0') ?? 0,
  );
}
