class QuotationBase {
  final String code;
  final String name;

  QuotationBase({required this.code, required this.name});

  factory QuotationBase.fromJson(Map<String, dynamic> json) =>
      QuotationBase(code: json['Code'], name: json['Name']);
}

class QuotationCustomer {
  final String customerCode;
  final String customerName;
  final String customerFullName;

  QuotationCustomer({
    required this.customerCode,
    required this.customerName,
    required this.customerFullName,
  });

  factory QuotationCustomer.fromJson(Map<String, dynamic> json) =>
      QuotationCustomer(
        customerCode: json['customerCode'],
        customerName: json['customerName'],
        customerFullName: json['customerFullName'],
      );
}

class Salesman {
  final String salesmanCode;
  final String salesmanName;
  final String salesManFullName;

  Salesman({
    required this.salesmanCode,
    required this.salesmanName,
    required this.salesManFullName,
  });

  factory Salesman.fromJson(Map<String, dynamic> json) => Salesman(
    salesmanCode: json['salesmanCode'],
    salesmanName: json['salesmanName'],
    salesManFullName: json['salesManFullName'],
  );
}

class QuotationSalesItem {
  final String itemCode;
  final String itemName;
  final String salesUOM;
  final String salesItemFullName;

  QuotationSalesItem({
    required this.itemCode,
    required this.itemName,
    required this.salesUOM,
    required this.salesItemFullName,
  });

  factory QuotationSalesItem.fromJson(Map<String, dynamic> json) =>
      QuotationSalesItem(
        itemCode: json['itemCode'] ?? '',
        itemName: json['itemName'] ?? '',
        salesUOM: json['salesUOM'] ?? '',
        salesItemFullName: json['salesItemFullName'] ?? '',
      );
}

class DiscountCode {
  final String code;
  final String codeFullName;

  DiscountCode({required this.code, required this.codeFullName});

  factory DiscountCode.fromJson(Map<String, dynamic> json) => DiscountCode(
    code: json['code'] ?? '',
    codeFullName: json['codeFullName'] ?? '',
  );
}

class RateStructure {
  final String rateStructCode;
  final String rateStructFullName;

  RateStructure({
    required this.rateStructCode,
    required this.rateStructFullName,
  });

  factory RateStructure.fromJson(Map<String, dynamic> json) => RateStructure(
    rateStructCode: json['rateStructCode'] ?? '',
    rateStructFullName: json['rateStructFullName'] ?? '',
  );
}

class QuotationSubmissionData {
  final Map<String, dynamic> docDetail;
  final QuotationCustomer quoteTo;
  final QuotationCustomer billTo;
  final Salesman salesman;
  final String subject;
  final DateTime quotationDate;
  final String quotationYear;
  final int siteId;
  final int userId;
  final List<Map<String, dynamic>> items;

  QuotationSubmissionData({
    required this.docDetail,
    required this.quoteTo,
    required this.billTo,
    required this.salesman,
    required this.subject,
    required this.quotationDate,
    required this.quotationYear,
    required this.siteId,
    required this.userId,
    required this.items,
  });
}
