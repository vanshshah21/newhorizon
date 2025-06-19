class CustomerModel {
  final String customerCode;
  final String customerName;
  final String customerFullName;

  CustomerModel({
    required this.customerCode,
    required this.customerName,
    required this.customerFullName,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    customerCode: json['customerCode'] ?? '',
    customerName: json['customerName'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
  );
}

class SourceModel {
  final String code;
  final String description;
  final String codeFullName;

  SourceModel({
    required this.code,
    required this.description,
    required this.codeFullName,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    codeFullName: json['codeFullName'] ?? '',
  );
}

class SalesmanModel {
  final String salesmanCode;
  final String salesmanName;
  final String salesManFullName;

  SalesmanModel({
    required this.salesmanCode,
    required this.salesmanName,
    required this.salesManFullName,
  });

  factory SalesmanModel.fromJson(Map<String, dynamic> json) => SalesmanModel(
    salesmanCode: json['salesmanCode'] ?? '',
    salesmanName: json['salesmanName'] ?? '',
    salesManFullName: json['salesManFullName'] ?? '',
  );
}

class RegionModel {
  final String code;
  final String description;
  final String codeFullName;

  RegionModel({
    required this.code,
    required this.description,
    required this.codeFullName,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    codeFullName: json['codeFullName'] ?? '',
  );
}

class SalesItemModel {
  final String itemCode;
  final String itemName;
  final String salesUOM;
  final String salesItemFullName;

  SalesItemModel({
    required this.itemCode,
    required this.itemName,
    required this.salesUOM,
    required this.salesItemFullName,
  });

  factory SalesItemModel.fromJson(Map<String, dynamic> json) => SalesItemModel(
    itemCode: json['itemCode'] ?? '',
    itemName: json['itemName'] ?? '',
    salesUOM: json['salesUOM'] ?? '',
    salesItemFullName: json['salesItemFullName'] ?? '',
  );
}

class LeadItemEntry {
  final SalesItemModel item;
  double qty;
  double rate;

  LeadItemEntry({required this.item, required this.qty, required this.rate});
}
