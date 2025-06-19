import 'sales_order_item.dart';

class SalesOrder {
  final int totalRows;
  final int orderId;
  final String ioYear;
  final String ioGroup;
  final int siteId;
  final String siteCode;
  final String siteFullName;
  final String ioNumber;
  final String date;
  final String customerCode;
  final String customerFullName;
  final String custPONo;
  final String custPODate;
  final int revisionNo;
  final bool isAuthorized;
  final bool isEdit;
  final bool isDelete;
  final String status;
  final String orderStatus;
  final String? pendingBy;
  final double totalAmount;
  final int techDocAttachCount;
  final String? creatorName;
  final String? authorizerName;
  final int amdSrNo;
  final bool directRedirectSOAmendment;
  final List<SalesOrderItem> itemDetail;

  SalesOrder({
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
    required this.pendingBy,
    required this.totalAmount,
    required this.techDocAttachCount,
    required this.creatorName,
    required this.authorizerName,
    required this.amdSrNo,
    required this.directRedirectSOAmendment,
    required this.itemDetail,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) => SalesOrder(
    totalRows: json['totalRows'] ?? 0,
    orderId: json['orderId'] ?? 0,
    ioYear: json['ioYear'] ?? '',
    ioGroup: json['ioGroup'] ?? '',
    siteId: json['siteId'] ?? 0,
    siteCode: json['siteCode'] ?? '',
    siteFullName: json['siteFullName'] ?? '',
    ioNumber: json['ioNumber'] ?? '',
    date: json['date'] ?? '',
    customerCode: json['customerCode'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
    custPONo: json['custPONo'] ?? '',
    custPODate: json['custPODate'] ?? '',
    revisionNo: json['revisionNo'] ?? 0,
    isAuthorized: json['isAuthorized'] ?? false,
    isEdit: json['isEdit'] ?? false,
    isDelete: json['isDelete'] ?? false,
    status: json['status'] ?? '',
    orderStatus: json['orderStatus'] ?? '',
    pendingBy: json['pendingBy'],
    totalAmount: (json['totalAmount'] ?? 0).toDouble(),
    techDocAttachCount: json['techDocAttachCount'] ?? 0,
    creatorName: json['creatorName'],
    authorizerName: json['authorizerName'],
    amdSrNo: json['amdSrNo'] ?? 0,
    directRedirectSOAmendment: json['directRedirectSOAmendment'] ?? false,
    itemDetail:
        (json['itemDetail'] as List<dynamic>? ?? [])
            .map((e) => SalesOrderItem.fromJson(e))
            .toList(),
  );
}
