class SalesOrderItem {
  final String itemCode;
  final String itemDesc;
  final double qty;
  final String uom;
  final double rate;
  final double amount;

  SalesOrderItem({
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
    qty: (json['qty'] ?? 0).toDouble(),
    uom: json['uom'] ?? '',
    rate: (json['rate'] ?? 0).toDouble(),
    amount: (json['amount'] ?? 0).toDouble(),
  );
}
