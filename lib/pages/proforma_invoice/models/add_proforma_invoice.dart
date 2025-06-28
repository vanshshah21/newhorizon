// class Customer {
//   final String customerCode;
//   final String customerName;
//   final String gstNumber;
//   final String telephoneNo;
//   final String customerFullName;

//   Customer({
//     required this.customerCode,
//     required this.customerName,
//     required this.gstNumber,
//     required this.telephoneNo,
//     required this.customerFullName,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       customerCode: json['customerCode'] ?? '',
//       customerName: json['customerName'] ?? '',
//       gstNumber: json['gstNumber'] ?? '',
//       telephoneNo: json['telephoneNo'] ?? '',
//       customerFullName: json['customerFullName'] ?? '',
//     );
//   }
// }

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

// class SalesItem {
//   final String itemCode;
//   final String itemName;
//   final String salesUOM;
//   final String hsnCode;

//   SalesItem({
//     required this.itemCode,
//     required this.itemName,
//     required this.salesUOM,
//     required this.hsnCode,
//   });

//   factory SalesItem.fromJson(Map<String, dynamic> json) {
//     return SalesItem(
//       itemCode: json['itemCode'] ?? '',
//       itemName: json['itemName'] ?? '',
//       salesUOM: json['salesUOM'] ?? 'NOS',
//       hsnCode: json['hsnCode'] ?? '',
//     );
//   }
// }

// class RateStructure {
//   final String rateStructCode;
//   final String rateStructDesc;
//   final String rateStructFullName;

//   RateStructure({
//     required this.rateStructCode,
//     required this.rateStructDesc,
//     required this.rateStructFullName,
//   });

//   factory RateStructure.fromJson(Map<String, dynamic> json) {
//     return RateStructure(
//       rateStructCode: json['rateStructCode'] ?? '',
//       rateStructDesc: json['rateStructDesc'] ?? '',
//       rateStructFullName: json['rateStructFullName'] ?? '',
//     );
//   }
// }

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
//   });

//   factory ProformaItem.fromQuotationItem(Map<String, dynamic> json) {
//     return ProformaItem(
//       itemName: json['itemName'] ?? '',
//       itemCode: json['itemCode'] ?? '',
//       qty: (json['qty'] ?? 0).toDouble(),
//       basicRate: (json['itemRate'] ?? 0).toDouble(),
//       uom: json['suom'] ?? 'NOS',
//       discountType: json['discountAmount'] > 0 ? 'Value' : 'None',
//       discountAmount: json['discountAmount']?.toDouble(),
//       rateStructure: json['rateStructureCode'] ?? '',
//       taxAmount: (json['totalTax'] ?? 0).toDouble(),
//       totalAmount: (json['totalValue'] ?? 0).toDouble(),
//     );
//   }

//   factory ProformaItem.fromSalesOrderItem(Map<String, dynamic> json) {
//     return ProformaItem(
//       itemName: json['itemName'] ?? '',
//       itemCode: json['itemCode'] ?? '',
//       qty: (json['qty'] ?? 0).toDouble(),
//       basicRate: (json['itemRate'] ?? 0).toDouble(),
//       uom: json['suom'] ?? 'NOS',
//       discountType: json['discountAmount'] > 0 ? 'Value' : 'None',
//       discountAmount: json['discountAmount']?.toDouble(),
//       rateStructure: json['rateStructureCode'] ?? '',
//       taxAmount: (json['totalTax'] ?? 0).toDouble(),
//       totalAmount: (json['totalValue'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toSubmissionJson() {
//     return {
//       "CreatedBy": 0,
//       "CurrCd": "INR",
//       "PIAdv": 0,
//       "RcvAdv": 0,
//       "RtnAmt": qty,
//       "detaildescription": "",
//       "discAmount": discountAmount ?? 0,
//       "discOrdRate": basicRate,
//       "discountedAmount": totalAmount,
//       "discountedRate": basicRate - (discountAmount ?? 0),
//       "fromLocationId": 8,
//       "invId": 0,
//       "invItemCode": itemCode,
//       "invQty": qty,
//       "itemUOM": uom,
//       "lineNo": 0,
//       "loadRate": 0,
//       "mainitemcode": "",
//       "maxAllowedQty": 0,
//       "netDiscountRate": 0,
//       "ordGroup": "",
//       "ordNumber": "",
//       "ordYear": "24-25",
//       "printseq": "",
//       "salesItemCode": itemCode,
//       "taxStructure": rateStructure,
//     };
//   }
// }

// class DefaultDocumentDetail {
//   final String documentString;
//   final String lastSrNo;
//   final String groupCode;
//   final int locationId;

//   DefaultDocumentDetail({
//     required this.documentString,
//     required this.lastSrNo,
//     required this.groupCode,
//     required this.locationId,
//   });

//   factory DefaultDocumentDetail.fromJson(Map<String, dynamic> json) {
//     return DefaultDocumentDetail(
//       documentString: json['documentString'] ?? '',
//       lastSrNo: json['lastSrNo'] ?? '',
//       groupCode: json['groupCode'] ?? '',
//       locationId: json['locationId'] ?? 0,
//     );
//   }
// }

// class QuotationDetails {
//   final List<Map<String, dynamic>> itemDetail;

//   QuotationDetails({required this.itemDetail});

//   factory QuotationDetails.fromJson(Map<String, dynamic> json) {
//     return QuotationDetails(
//       itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
//     );
//   }
// }

// class SalesOrderDetails {
//   final List<Map<String, dynamic>> itemDetail;

//   SalesOrderDetails({required this.itemDetail});

//   factory SalesOrderDetails.fromJson(Map<String, dynamic> json) {
//     return SalesOrderDetails(
//       itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
//     );
//   }
// }

//------------------------------------------------------------------------------------------------------

// class Customer {
//   final String customerCode;
//   final String customerName;
//   final String gstNumber;
//   final String telephoneNo;
//   final String customerFullName;

//   Customer({
//     required this.customerCode,
//     required this.customerName,
//     required this.gstNumber,
//     required this.telephoneNo,
//     required this.customerFullName,
//   });

//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       customerCode: json['customerCode'] ?? '',
//       customerName: json['customerName'] ?? '',
//       gstNumber: json['gstNumber'] ?? '',
//       telephoneNo: json['telephoneNo'] ?? '',
//       customerFullName: json['customerFullName'] ?? '',
//     );
//   }
// }

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

// class SalesItem {
//   final String itemCode;
//   final String itemName;
//   final String salesUOM;
//   final String hsnCode;

//   SalesItem({
//     required this.itemCode,
//     required this.itemName,
//     required this.salesUOM,
//     required this.hsnCode,
//   });

//   factory SalesItem.fromJson(Map<String, dynamic> json) {
//     return SalesItem(
//       itemCode: json['itemCode'] ?? '',
//       itemName: json['itemName'] ?? '',
//       salesUOM: json['salesUOM'] ?? 'NOS',
//       hsnCode: json['hsnCode'] ?? '',
//     );
//   }
// }

// class RateStructure {
//   final String rateStructCode;
//   final String rateStructDesc;
//   final String rateStructFullName;

//   RateStructure({
//     required this.rateStructCode,
//     required this.rateStructDesc,
//     required this.rateStructFullName,
//   });

//   factory RateStructure.fromJson(Map<String, dynamic> json) {
//     return RateStructure(
//       rateStructCode: json['rateStructCode'] ?? '',
//       rateStructDesc: json['rateStructDesc'] ?? '',
//       rateStructFullName: json['rateStructFullName'] ?? '',
//     );
//   }
// }

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
//   });

//   factory ProformaItem.fromQuotationItem(Map<String, dynamic> json) {
//     return ProformaItem(
//       itemName: json['itemName'] ?? '',
//       itemCode: json['itemCode'] ?? '',
//       qty: (json['qty'] ?? 0).toDouble(),
//       basicRate: (json['itemRate'] ?? 0).toDouble(),
//       uom: json['suom'] ?? 'NOS',
//       discountType: json['discountAmount'] > 0 ? 'Value' : 'None',
//       discountAmount: json['discountAmount']?.toDouble(),
//       rateStructure: json['rateStructureCode'] ?? '',
//       taxAmount: (json['totalTax'] ?? 0).toDouble(),
//       totalAmount: (json['totalValue'] ?? 0).toDouble(),
//     );
//   }

//   factory ProformaItem.fromSalesOrderItem(Map<String, dynamic> json) {
//     return ProformaItem(
//       itemName: json['itemName'] ?? '',
//       itemCode: json['itemCode'] ?? '',
//       qty: (json['qty'] ?? 0).toDouble(),
//       basicRate: (json['itemRate'] ?? 0).toDouble(),
//       uom: json['suom'] ?? 'NOS',
//       discountType: json['discountAmount'] > 0 ? 'Value' : 'None',
//       discountAmount: json['discountAmount']?.toDouble(),
//       rateStructure: json['rateStructureCode'] ?? '',
//       taxAmount: (json['totalTax'] ?? 0).toDouble(),
//       totalAmount: (json['totalValue'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toSubmissionJson() {
//     return {
//       "CreatedBy": 0,
//       "CurrCd": "INR",
//       "PIAdv": 0,
//       "RcvAdv": 0,
//       "RtnAmt": qty,
//       "detaildescription": "",
//       "discAmount": discountAmount ?? 0,
//       "discOrdRate": basicRate,
//       "discountedAmount": totalAmount,
//       "discountedRate": basicRate - (discountAmount ?? 0),
//       "fromLocationId": 8,
//       "invId": 0,
//       "invItemCode": itemCode,
//       "invQty": qty,
//       "itemUOM": uom,
//       "lineNo": 0,
//       "loadRate": 0,
//       "mainitemcode": "",
//       "maxAllowedQty": 0,
//       "netDiscountRate": 0,
//       "ordGroup": "",
//       "ordNumber": "",
//       "ordYear": "24-25",
//       "printseq": "",
//       "salesItemCode": itemCode,
//       "taxStructure": rateStructure,
//     };
//   }
// }

// class DefaultDocumentDetail {
//   final String documentString;
//   final String lastSrNo;
//   final String groupCode;
//   final int locationId;

//   DefaultDocumentDetail({
//     required this.documentString,
//     required this.lastSrNo,
//     required this.groupCode,
//     required this.locationId,
//   });

//   factory DefaultDocumentDetail.fromJson(Map<String, dynamic> json) {
//     return DefaultDocumentDetail(
//       documentString: json['documentString'] ?? '',
//       lastSrNo: json['lastSrNo'] ?? '',
//       groupCode: json['groupCode'] ?? '',
//       locationId: json['locationId'] ?? 0,
//     );
//   }
// }

// class QuotationDetails {
//   final List<Map<String, dynamic>> itemDetail;

//   QuotationDetails({required this.itemDetail});

//   factory QuotationDetails.fromJson(Map<String, dynamic> json) {
//     return QuotationDetails(
//       itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
//     );
//   }
// }

// class SalesOrderDetails {
//   final List<Map<String, dynamic>> itemDetail;

//   SalesOrderDetails({required this.itemDetail});

//   factory SalesOrderDetails.fromJson(Map<String, dynamic> json) {
//     return SalesOrderDetails(
//       itemDetail: List<Map<String, dynamic>>.from(json['itemDetail'] ?? []),
//     );
//   }
// }

//---------------------------------------------------------------------------------------------------------

class Customer {
  final int totalRows;
  final String custCode;
  final String custName;
  final String cityCode;
  final String cityName;

  Customer({
    required this.totalRows,
    required this.custCode,
    required this.custName,
    required this.cityCode,
    required this.cityName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      totalRows: json['totalRows'] ?? 0,
      custCode: json['custCode'] ?? '',
      custName: json['custName'] ?? '',
      cityCode: json['cityCode'] ?? '',
      cityName: json['cityName'] ?? '',
    );
  }
}

class QuotationNumber {
  final String number;
  final DateTime orderDate;
  final int srNo;

  QuotationNumber({
    required this.number,
    required this.orderDate,
    required this.srNo,
  });

  factory QuotationNumber.fromJson(Map<String, dynamic> json) {
    return QuotationNumber(
      number: json['number'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      srNo: json['srNo'] ?? 0,
    );
  }
}

class SalesOrderNumber {
  final String number;
  final DateTime orderDate;
  final int srNo;
  final String ordNo;

  SalesOrderNumber({
    required this.number,
    required this.orderDate,
    required this.srNo,
    required this.ordNo,
  });

  factory SalesOrderNumber.fromJson(Map<String, dynamic> json) {
    return SalesOrderNumber(
      number: json['number'] ?? '',
      orderDate: DateTime.parse(json['orderDate']),
      srNo: json['srNo'] ?? 0,
      ordNo: json['ordNo'] ?? '',
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
      "createdBy": 2,
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
      "fromLocationId": 8,
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
