class SalesOrderData {
  final int totalRows;
  final int orderId;
  final String ioYear;
  final String ioGroup;
  final int siteId;
  final String siteCode;
  final String siteFullName;
  final String ioNumber;
  final DateTime date;
  final String customerCode;
  final String customerFullName;
  final String custPONo;
  final DateTime custPODate;
  final int revisionNo;
  final bool isAuthorized;
  final bool isEdit;
  final bool isDelete;
  final String status;
  final String orderStatus;
  final double totalAmount;
  final List<SalesOrderItem> itemDetail;

  const SalesOrderData({
    required this.totalRows,
    required this.orderId,
    required this.ioYear,
    required this.ioGroup,
    required this.siteId,
    required this.siteCode,
    required this.siteFullName,
    required this.ioNumber,
    required this.date,
    required this.customerCode,
    required this.customerFullName,
    required this.custPONo,
    required this.custPODate,
    required this.revisionNo,
    required this.isAuthorized,
    required this.isEdit,
    required this.isDelete,
    required this.status,
    required this.orderStatus,
    required this.totalAmount,
    required this.itemDetail,
  });

  factory SalesOrderData.fromJson(Map<String, dynamic> json) => SalesOrderData(
    totalRows: json['totalRows'] ?? 0,
    orderId: json['orderId'],
    ioYear: json['ioYear'] ?? '',
    ioGroup: json['ioGroup'] ?? '',
    siteId: json['siteId'],
    siteCode: json['siteCode'] ?? '',
    siteFullName: json['siteFullName'] ?? '',
    ioNumber: json['ioNumber'] ?? '',
    date: DateTime.parse(json['date']),
    customerCode: json['customerCode'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
    custPONo: json['custPONo'] ?? '',
    custPODate: DateTime.parse(json['custPODate']),
    revisionNo: json['revisionNo'] ?? 0,
    isAuthorized: json['isAuthorized'] ?? false,
    isEdit: json['isEdit'] ?? false,
    isDelete: json['isDelete'] ?? false,
    status: json['status'] ?? '',
    orderStatus: json['orderStatus'] ?? '',
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
    itemDetail:
        (json['itemDetail'] as List<dynamic>?)
            ?.map((e) => SalesOrderItem.fromJson(e))
            .toList() ??
        [],
  );
}

class SalesOrderItem {
  final String itemCode;
  final String itemDesc;
  final double qty;
  final String uom;
  final double rate;
  final double amount;

  const SalesOrderItem({
    required this.itemCode,
    required this.itemDesc,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
  });

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) => SalesOrderItem(
    itemCode: json['itemCode'] ?? '',
    itemDesc: json['itemDesc'] ?? '',
    qty: (json['qty'] as num?)?.toDouble() ?? 0,
    uom: json['uom'] ?? '',
    rate: (json['rate'] as num?)?.toDouble() ?? 0,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
  );
}
