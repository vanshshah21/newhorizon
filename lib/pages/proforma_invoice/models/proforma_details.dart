// models/proforma_invoice_details.dart
class ProformaInvoiceDetails {
  final Map<String, dynamic> headerDetail;
  final Map<String, dynamic> salesOrderDetail;
  final Map<String, dynamic> gridDetail;
  final List<dynamic> terms;
  final List<dynamic> charges;
  final Map<String, dynamic> transPortDetail;

  ProformaInvoiceDetails({
    required this.headerDetail,
    required this.salesOrderDetail,
    required this.gridDetail,
    required this.terms,
    required this.charges,
    required this.transPortDetail,
  });

  factory ProformaInvoiceDetails.fromJson(Map<String, dynamic> json) {
    return ProformaInvoiceDetails(
      headerDetail: json['headerDetail'] ?? {},
      salesOrderDetail: json['salesOrderDetail'] ?? {},
      gridDetail: json['gridDetail'] ?? {},
      terms: json['terms'] ?? [],
      charges: json['charges'] ?? [],
      transPortDetail: json['transPortDetail'] ?? {},
    );
  }
}
