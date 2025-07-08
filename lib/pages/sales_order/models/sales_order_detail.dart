class SalesOrderDetail {
  final Map<String, dynamic> salesOrderDetails;
  final List<Map<String, dynamic>> modelDetails;
  final List<Map<String, dynamic>> rateStructureDetails;
  final List<Map<String, dynamic>> deliveryDetails;
  final List<Map<String, dynamic>> termDetails;
  final List<Map<String, dynamic>> discountDetails;

  SalesOrderDetail({
    required this.salesOrderDetails,
    required this.modelDetails,
    required this.rateStructureDetails,
    required this.deliveryDetails,
    required this.termDetails,
    required this.discountDetails,
  });

  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetail(
      salesOrderDetails:
          (json['salesOrderDetails'] as List).isNotEmpty
              ? json['salesOrderDetails'][0] as Map<String, dynamic>
              : {},
      modelDetails:
          (json['modelDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      rateStructureDetails:
          (json['rateStructureDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      deliveryDetails:
          (json['deliveryDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      termDetails:
          (json['termDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      discountDetails:
          (json['discountDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
    );
  }
}

class SalesOrderListItem {
  final String ioYear;
  final String ioGroup;
  final String ioNumber;
  final String customerCode;
  final String customerName;
  final DateTime ioDate;
  final String customerPONumber;
  final double totalAmount;
  final String orderStatus;

  SalesOrderListItem({
    required this.ioYear,
    required this.ioGroup,
    required this.ioNumber,
    required this.customerCode,
    required this.customerName,
    required this.ioDate,
    required this.customerPONumber,
    required this.totalAmount,
    required this.orderStatus,
  });

  factory SalesOrderListItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderListItem(
      ioYear: json['ioYear'] ?? '',
      ioGroup: json['ioGroup'] ?? '',
      ioNumber: json['ioNumber'] ?? '',
      customerCode: json['customerCode'] ?? '',
      customerName: json['customerName'] ?? '',
      ioDate: DateTime.parse(json['ioDate']),
      customerPONumber: json['customerPONumber'] ?? '',
      totalAmount:
          (json['totalAmountAfterTaxCustomerCurrency'] ?? 0).toDouble(),
      orderStatus: json['orderStatus'] ?? '',
    );
  }
}
