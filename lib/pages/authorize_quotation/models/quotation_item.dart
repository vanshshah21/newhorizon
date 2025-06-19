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
