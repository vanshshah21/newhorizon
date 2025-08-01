import 'package:nhapp/utils/storage_utils.dart';

Future<String> getDomesticCurrency() async {
  final domCurrency = await StorageUtils.readJson('domestic_currency');
  if (domCurrency == null) throw Exception("Domestic currency not set");

  return domCurrency['domCurCode'] ?? 'INR';
}

// class Customer {
//   final int totalRows;
//   final String custCode;
//   final String custName;
//   final String cityCode;
//   final String cityName;

//   Customer({
//     required this.totalRows,
//     required this.custCode,
//     required this.custName,
//     required this.cityCode,
//     required this.cityName,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       totalRows: json['totalRows'] ?? 0,
//       custCode: json['custCode'] ?? '',
//       custName: json['custName'] ?? '',
//       cityCode: json['cityCode'] ?? '',
//       cityName: json['cityName'] ?? '',
//     );
//   }
// }
class Customer {
  final int totalRows;
  final String custCode;
  final String custName;
  final String custFullName;
  final String currencyCode;

  Customer({
    required this.totalRows,
    required this.custCode,
    required this.custName,
    required this.custFullName,
    required this.currencyCode,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      totalRows: json['totalRows'] ?? 0,
      custCode: json['customerCode'] ?? '',
      custName: json['customerName'] ?? '',
      custFullName: json['customerFullName'] ?? '',
      currencyCode: json['currencycode'] ?? 'INR',
    );
  }
}

// class QuotationNumber {
//   final String number;
//   final DateTime orderDate;
//   final int srNo;

//   QuotationNumber({
//     required this.number,
//     required this.orderDate,
//     required this.srNo,
//   });

//   factory QuotationNumber.fromJson(Map<String, dynamic> json) {
//     return QuotationNumber(
//       number: json['number'] ?? '',
//       orderDate: DateTime.parse(json['orderDate']),
//       srNo: json['srNo'] ?? 0,
//     );
//   }
// }
class QuotationNumber {
  final String number;
  final DateTime orderDate;
  final int srNo;
  final String discType;
  final double discAmount;
  final String ordGroup;
  final String ordNo;
  final String curCode;
  final String consultantCode;
  final String consultantName;
  final String kindAttention;
  final String attencontactno;
  final int id;

  QuotationNumber({
    required this.number,
    required this.orderDate,
    required this.srNo,
    required this.discType,
    required this.discAmount,
    required this.ordGroup,
    required this.ordNo,
    required this.curCode,
    required this.consultantCode,
    required this.consultantName,
    required this.kindAttention,
    required this.attencontactno,
    required this.id,
  });

  factory QuotationNumber.fromJson(Map<String, dynamic> json) {
    return QuotationNumber(
      number: json['number'] ?? '',
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      srNo: json['srNo'] ?? 0,
      discType: json['discType'] ?? '',
      discAmount: (json['discAmount'] ?? 0.0).toDouble(),
      ordGroup: json['ordGroup'] ?? '',
      ordNo: json['ordNo'] ?? '',
      curCode: json['curCode'] ?? '',
      consultantCode: json['consultantCode'] ?? '',
      consultantName: json['consultantName'] ?? '',
      kindAttention: json['kindAttention'] ?? '',
      attencontactno: json['attencontactno'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}

// class SalesOrderNumber {
//   final String number;
//   final DateTime orderDate;
//   final int srNo;
//   final String ordNo;

//   SalesOrderNumber({
//     required this.number,
//     required this.orderDate,
//     required this.srNo,
//     required this.ordNo,
//   });

//   factory SalesOrderNumber.fromJson(Map<String, dynamic> json) {
//     return SalesOrderNumber(
//       number: json['number'] ?? '',
//       orderDate: DateTime.parse(json['orderDate']),
//       srNo: json['srNo'] ?? 0,
//       ordNo: json['ordNo'] ?? '',
//     );
//   }
// }
class SalesOrderNumber {
  final String number;
  final DateTime orderDate;
  final int srNo;
  final String discType;
  final double discAmount;
  final String ordGroup;
  final String ordNo;
  final String curCode;
  final String consultantCode;
  final String consultantName;
  final String kindAttention;
  final String attencontactno;
  final int id;

  SalesOrderNumber({
    required this.number,
    required this.orderDate,
    required this.srNo,
    required this.discType,
    required this.discAmount,
    required this.ordGroup,
    required this.ordNo,
    required this.curCode,
    required this.consultantCode,
    required this.consultantName,
    required this.kindAttention,
    required this.attencontactno,
    required this.id,
  });

  factory SalesOrderNumber.fromJson(Map<String, dynamic> json) {
    return SalesOrderNumber(
      number: json['number'] ?? '',
      orderDate: DateTime.parse(
        json['orderDate'] ?? DateTime.now().toIso8601String(),
      ),
      srNo: json['srNo'] ?? 0,
      discType: json['discType'] ?? '',
      discAmount: (json['discAmount'] ?? 0.0).toDouble(),
      ordGroup: json['ordGroup'] ?? '',
      ordNo: json['ordNo'] ?? '',
      curCode: json['curCode'] ?? '',
      consultantCode: json['consultantCode'] ?? '',
      consultantName: json['consultantName'] ?? '',
      kindAttention: json['kindAttention'] ?? '',
      attencontactno: json['attencontactno'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}

class SalesItem {
  final String itemCode;
  final String itemName;
  final String salesUOM;
  final String hsnCode;

  SalesItem({
    required this.itemCode,
    required this.itemName,
    required this.salesUOM,
    required this.hsnCode,
  });

  factory SalesItem.fromJson(Map<String, dynamic> json) {
    return SalesItem(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      salesUOM: json['salesUOM'] ?? 'NOS',
      hsnCode: json['hsnCode'] ?? '',
    );
  }
}

class RateStructure {
  final String rateStructCode;
  final String rateStructDesc;
  final String rateStructFullName;

  RateStructure({
    required this.rateStructCode,
    required this.rateStructDesc,
    required this.rateStructFullName,
  });

  factory RateStructure.fromJson(Map<String, dynamic> json) {
    return RateStructure(
      rateStructCode: json['rateStructCode'] ?? '',
      rateStructDesc: json['rateStructDesc'] ?? '',
      rateStructFullName: json['rateStructFullName'] ?? '',
    );
  }
}

// class ProformaItem {
//   final String itemName;
//   final String itemCode;
//   final double qty;
//   final double basicRate;
//   final String uom;
//   final String discountType;
//   final double? discountPercentage;
//   final double? discountAmount;
//   final String rateStructure;
//   final double? taxAmount;
//   final double totalAmount;
//   final List<Map<String, dynamic>>? rateStructureRows;
//   int lineNo;
//   final String? hsnAccCode;

//   ProformaItem({
//     required this.itemName,
//     required this.itemCode,
//     required this.qty,
//     required this.basicRate,
//     required this.uom,
//     required this.discountType,
//     this.discountPercentage,
//     this.discountAmount,
//     required this.rateStructure,
//     this.taxAmount,
//     required this.totalAmount,
//     this.rateStructureRows,
//     required this.lineNo,
//     this.hsnAccCode,
//   });

//   Map<String, dynamic> toSubmissionJson() {
//     return {
//       "ordYear": "",
//       "rcvAdv": 0,
//       "piAdv": 0,
//       "rtnAmt": 0,
//       "currCd": "INR",
//       "createdBy": 2,
//       "netDiscountRate": basicRate - (discountAmount ?? 0),
//       "discOrdRate": basicRate,
//       "lineNo": lineNo,
//       "salesItemCode": itemCode,
//       "invItemCode": itemCode,
//       "ordGroup": "",
//       "ordNumber": "",
//       "quantitySUOM": qty,
//       "invQty": qty,
//       "maxAllowedQty": qty,
//       "hsnAccCode": hsnAccCode ?? "",
//       "productSize": "",
//       "itemUOM": uom,
//       "discountedRate": basicRate - (discountAmount ?? 0),
//       "discAmount": (discountAmount ?? 0).toStringAsFixed(2),
//       "discountedAmount": totalAmount,
//       "taxStructure": rateStructure,
//       "seqNo": lineNo,
//       "fromLocationId": 8,
//       "curCode": "INR",
//       "headerRemark": "",
//       "invId": 0,
//       "mainitemcode": "",
//       "printseq": "",
//       "detaildescription": "",
//       "loadRate": 0,
//     };
//   }
// }

class ProformaItem {
  final String itemName;
  final String itemCode;
  final double qty;
  final double basicRate;
  final String uom;
  final String discountType;
  final double? discountPercentage;
  final double? discountAmount;
  final String? discountCode;
  final String rateStructure;
  final double? taxAmount;
  final double totalAmount;
  final List<Map<String, dynamic>>? rateStructureRows;
  int lineNo;
  final String? hsnAccCode;

  ProformaItem({
    required this.itemName,
    required this.itemCode,
    required this.qty,
    required this.basicRate,
    required this.uom,
    required this.discountType,
    this.discountPercentage,
    this.discountAmount,
    this.discountCode,
    required this.rateStructure,
    this.taxAmount,
    required this.totalAmount,
    this.rateStructureRows,
    required this.lineNo,
    this.hsnAccCode,
  });

  Map<String, dynamic> toSubmissionJson(int userId, int locationId) {
    // Calculate discountedAmount and discountedRate as per requirements
    final double discount = discountAmount ?? 0.0;
    final double discountedAmount = (basicRate * qty) - discount;
    final double discountedRate = qty > 0 ? discountedAmount / qty : 0.0;

    return {
      "ordYear": "",
      "rcvAdv": 0,
      "piAdv": 0,
      "rtnAmt": 0,
      "currCd": "INR",
      "discountCode": discountCode,
      "createdBy": userId,
      "netDiscountRate": discountedRate, // value per item after discount
      "discOrdRate": basicRate,
      "lineNo": lineNo,
      "salesItemCode": itemCode,
      "invItemCode": itemCode,
      "ordGroup": "",
      "ordNumber": "",
      "quantitySUOM": qty, // maxAllowedQty
      "invQty": qty,
      "maxAllowedQty": qty,
      "hsnAccCode": hsnAccCode ?? "",
      "productSize": "",
      "itemUOM": uom,
      "discountedRate": discountedRate, // value per item after discount
      "discAmount": discount.toStringAsFixed(2), // String
      "discountedAmount": discountedAmount, // totalAmount - discount
      "taxStructure": rateStructure,
      "seqNo": lineNo,
      "fromLocationId": 0,
      "curCode": "INR",
      "headerRemark": "",
      "invId": 0,
      "mainitemcode": "",
      "printseq": "",
      "detaildescription": "",
      "loadRate": 0,
    };
  }
}

class DefaultDocumentDetail {
  final String documentString;
  final String lastSrNo;
  final String groupCode;
  final int locationId;

  DefaultDocumentDetail({
    required this.documentString,
    required this.lastSrNo,
    required this.groupCode,
    required this.locationId,
  });

  factory DefaultDocumentDetail.fromJson(Map<String, dynamic> json) {
    return DefaultDocumentDetail(
      documentString: json['documentString'] ?? '',
      lastSrNo: json['lastSrNo'] ?? '',
      groupCode: json['groupCode'] ?? '',
      locationId: json['locationId'] ?? 0,
    );
  }
}

class QuotationDetails {
  final List<Map<String, dynamic>> itemDetail;
  final List<Map<String, dynamic>>? rateStructDetail;
  final List<Map<String, dynamic>>? discountDetail;

  QuotationDetails({
    required this.itemDetail,
    this.rateStructDetail,
    this.discountDetail,
  });

  factory QuotationDetails.fromJson(Map<String, dynamic> json) {
    return QuotationDetails(
      itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
      rateStructDetail:
          json['rateStructDetail'] != null
              ? List<Map<String, dynamic>>.from(json['rateStructDetail'])
              : null,
      discountDetail:
          json['discountDetail'] != null
              ? List<Map<String, dynamic>>.from(json['discountDetail'])
              : null,
    );
  }
}

class SalesOrderDetails {
  final List<Map<String, dynamic>> itemDetail;
  final List<Map<String, dynamic>>? rateStructDetail;
  final List<Map<String, dynamic>>? discountDetail;

  SalesOrderDetails({
    required this.itemDetail,
    this.rateStructDetail,
    this.discountDetail,
  });

  factory SalesOrderDetails.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetails(
      itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
      rateStructDetail:
          json['rateStructDetail'] != null
              ? List<Map<String, dynamic>>.from(json['rateStructDetail'])
              : null,
      discountDetail:
          json['discountDetail'] != null
              ? List<Map<String, dynamic>>.from(json['discountDetail'])
              : null,
    );
  }
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
