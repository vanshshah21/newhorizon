class CustomerModel {
  final String customerCode;
  final String customerName;
  final String customerFullName;
  final String currency;

  CustomerModel({
    required this.customerCode,
    required this.customerName,
    required this.customerFullName,
    required this.currency,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    customerCode: json['customerCode'] ?? '',
    customerName: json['customerName'] ?? '',
    customerFullName: json['customerFullName'] ?? '',
    currency: json['currency'] ?? 'INR',
  );
}

class SourceModel {
  final String code;
  final String description;
  final String codeFullName;
  final String currency;

  SourceModel({
    required this.code,
    required this.description,
    required this.codeFullName,
    required this.currency,
  });

  factory SourceModel.fromJson(Map<String, dynamic> json) => SourceModel(
    code: json['code'] ?? '',
    description: json['description'] ?? '',
    codeFullName: json['codeFullName'] ?? '',
    currency: json['currency'] ?? 'INR',
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

// class SalesItemModel {
//   final String itemCode;
//   final String itemName;
//   final String salesUOM;
//   final String salesItemFullName;

//   SalesItemModel({
//     required this.itemCode,
//     required this.itemName,
//     required this.salesUOM,
//     required this.salesItemFullName,
//   });

//   factory SalesItemModel.fromJson(Map<String, dynamic> json) => SalesItemModel(
//     itemCode: json['itemCode'] ?? '',
//     itemName: json['itemName'] ?? '',
//     salesUOM: json['salesUOM'] ?? '',
//     salesItemFullName: json['salesItemFullName'] ?? '',
//   );
// }
class SalesItemModel {
  final String itemCode;
  final String itemName;
  final String salesUOM;
  final String salesItemFullName;
  final String salesItemType;
  final String productSpareSize;
  final String ximinvtyp;
  final bool allowchng;
  final int mimdispwomfg;
  final String msimodelno;

  SalesItemModel({
    required this.itemCode,
    required this.itemName,
    required this.salesUOM,
    required this.salesItemFullName,
    required this.salesItemType,
    required this.productSpareSize,
    required this.ximinvtyp,
    required this.allowchng,
    required this.mimdispwomfg,
    required this.msimodelno,
  });

  factory SalesItemModel.fromJson(Map<String, dynamic> json) => SalesItemModel(
    itemCode: json['itemCode'] ?? '',
    itemName: json['itemName'] ?? '',
    salesUOM: json['salesUOM'] ?? '',
    salesItemFullName: json['salesItemFullName'] ?? '',
    salesItemType: json['salesItemType'] ?? '',
    productSpareSize: json['productSpareSize'] ?? '',
    ximinvtyp: json['ximinvtyp'] ?? 'Regular',
    allowchng: json['allowchng'] ?? false,
    mimdispwomfg: json['mimdispwomfg'] ?? 0,
    msimodelno: json['msimodelno'] ?? '',
  );
}

class LeadItemEntry {
  final SalesItemModel item;
  double qty;
  double rate;

  LeadItemEntry({required this.item, required this.qty, required this.rate});
}
