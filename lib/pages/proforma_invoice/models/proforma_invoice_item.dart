// models/proforma_invoice_item.dart
class ProformaInvoiceItem {
  final String itemCode;
  final String itemDesc;
  final double qty;
  final String uom;
  final double rate;
  final double amount;

  ProformaInvoiceItem({
    required this.itemCode,
    required this.itemDesc,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
  });

  factory ProformaInvoiceItem.fromJson(Map<String, dynamic> json) =>
      ProformaInvoiceItem(
        itemCode: json['itemCode'] ?? '',
        itemDesc: json['itemDesc'] ?? '',
        qty: (json['qty'] ?? 0).toDouble(),
        uom: json['uom'] ?? '',
        rate: (json['rate'] ?? 0).toDouble(),
        amount: (json['amount'] ?? 0).toDouble(),
      );
}

class ProformaInvoice {
  final int totalRows;
  final int id;
  final String year;
  final String groupCode;
  final String siteCode;
  final String siteFullName;
  final String number;
  final String date;
  final String customerFullName;
  final bool isEdit;
  final bool isDelete;
  final int siteId;
  final String rowStatus;
  final int fromLocationId;
  final String piOn;
  final String custCode;
  final List<ProformaInvoiceItem> itemDetail;

  ProformaInvoice({
    required this.totalRows,
    required this.id,
    required this.year,
    required this.groupCode,
    required this.siteCode,
    required this.siteFullName,
    required this.number,
    required this.date,
    required this.customerFullName,
    required this.isEdit,
    required this.isDelete,
    required this.siteId,
    required this.rowStatus,
    required this.fromLocationId,
    required this.piOn,
    required this.custCode,
    required this.itemDetail,
  });

  factory ProformaInvoice.fromJson(Map<String, dynamic> json) =>
      ProformaInvoice(
        totalRows: json['totalRows'] ?? 0,
        id: json['id'] ?? 0,
        year: json['year'] ?? '',
        groupCode: json['groupCode'] ?? '',
        siteCode: json['siteCode'] ?? '',
        siteFullName: json['siteFullName'] ?? '',
        number: json['number'] ?? '',
        date: json['date'] ?? '',
        customerFullName: json['customerFullName'] ?? '',
        isEdit: json['isEdit'] == "1" || json['isEdit'] == true,
        isDelete: json['isDelete'] == "1" || json['isDelete'] == true,
        siteId: json['siteId'] ?? 0,
        rowStatus: json['rowStatus'] ?? '',
        fromLocationId: json['fromLocationId'] ?? 0,
        piOn: json['piOn'] ?? '',
        custCode: json['custCode'] ?? '',
        itemDetail:
            (json['itemDetail'] as List<dynamic>? ?? [])
                .map((e) => ProformaInvoiceItem.fromJson(e))
                .toList(),
      );
}
