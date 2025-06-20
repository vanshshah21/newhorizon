class SalesOrderDetailsResponse {
  final SalesOrderDetailsData data;
  final bool success;
  final String? message;

  SalesOrderDetailsResponse({
    required this.data,
    required this.success,
    this.message,
  });

  factory SalesOrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailsResponse(
      data: SalesOrderDetailsData.fromJson(json['data']),
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

class SalesOrderDetailsData {
  final List<SalesOrderDetail> salesOrderDetails;
  final List<ModelDetail> modelDetails;
  final List<RateStructureDetail> rateStructureDetails;
  final List<DeliveryDetail> deliveryDetails;
  final List<TermDetail> termDetails;
  final List<ContactPerson> contactPersonList;
  final List<ShipmentLocation> shipmentList;

  SalesOrderDetailsData({
    required this.salesOrderDetails,
    required this.modelDetails,
    required this.rateStructureDetails,
    required this.deliveryDetails,
    required this.termDetails,
    required this.contactPersonList,
    required this.shipmentList,
  });

  factory SalesOrderDetailsData.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetailsData(
      salesOrderDetails:
          (json['salesOrderDetails'] as List)
              .map((e) => SalesOrderDetail.fromJson(e))
              .toList(),
      modelDetails:
          (json['modelDetails'] as List)
              .map((e) => ModelDetail.fromJson(e))
              .toList(),
      rateStructureDetails:
          (json['rateStructureDetails'] as List)
              .map((e) => RateStructureDetail.fromJson(e))
              .toList(),
      deliveryDetails:
          (json['deliveryDetails'] as List)
              .map((e) => DeliveryDetail.fromJson(e))
              .toList(),
      termDetails:
          (json['termDetails'] as List)
              .map((e) => TermDetail.fromJson(e))
              .toList(),
      contactPersonList:
          (json['contactPersonList'] as List)
              .map((e) => ContactPerson.fromJson(e))
              .toList(),
      shipmentList:
          (json['shipmentList'] as List)
              .map((e) => ShipmentLocation.fromJson(e))
              .toList(),
    );
  }
}

class SalesOrderDetail {
  final String customerCode;
  final String customerPONumber;
  final DateTime? customerPODate;
  final String quotationNumber;
  final String orderStatus;
  final double totalAmountAfterTaxCustomerCurrency;
  final String ioYear;
  final String ioNumber;
  final DateTime ioDate;
  final String customerName;
  final String customerFullName;
  final String salesmanName;
  final String gstNo;
  final String fullAddress;
  final String currencyFullName;

  SalesOrderDetail({
    required this.customerCode,
    required this.customerPONumber,
    this.customerPODate,
    required this.quotationNumber,
    required this.orderStatus,
    required this.totalAmountAfterTaxCustomerCurrency,
    required this.ioYear,
    required this.ioNumber,
    required this.ioDate,
    required this.customerName,
    required this.customerFullName,
    required this.salesmanName,
    required this.gstNo,
    required this.fullAddress,
    required this.currencyFullName,
  });

  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    return SalesOrderDetail(
      customerCode: json['customerCode'] ?? '',
      customerPONumber: json['customerPONumber'] ?? '',
      customerPODate:
          json['customerPODate'] != null
              ? DateTime.parse(json['customerPODate'])
              : null,
      quotationNumber: json['quotationNumber'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      totalAmountAfterTaxCustomerCurrency:
          (json['totalAmountAfterTaxCustomerCurrency'] ?? 0).toDouble(),
      ioYear: json['ioYear'] ?? '',
      ioNumber: json['ioNumber'] ?? '',
      ioDate: DateTime.parse(json['ioDate']),
      customerName: json['customerName'] ?? '',
      customerFullName: json['customerFullName'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      gstNo: json['gstNo'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      currencyFullName: json['currencyFullName'] ?? '',
    );
  }
}

class ModelDetail {
  final String salesItemCode;
  final String salesItemDesc;
  final double qtyIUOM;
  final double basicPriceIUOM;
  final double discountAmt;
  final String status;
  final String uom;
  final String rateStructureCode;
  final String ratestructdesc;
  final String currencyCode;
  final String hsnCode;
  final double basicPrice;
  final int itemLineNo;

  ModelDetail({
    required this.salesItemCode,
    required this.salesItemDesc,
    required this.qtyIUOM,
    required this.basicPriceIUOM,
    required this.discountAmt,
    required this.status,
    required this.uom,
    required this.rateStructureCode,
    required this.ratestructdesc,
    required this.currencyCode,
    required this.hsnCode,
    required this.basicPrice,
    required this.itemLineNo,
  });

  factory ModelDetail.fromJson(Map<String, dynamic> json) {
    return ModelDetail(
      salesItemCode: json['salesItemCode'] ?? '',
      salesItemDesc: json['salesItemDesc'] ?? '',
      qtyIUOM: (json['qtyIUOM'] ?? 0).toDouble(),
      basicPriceIUOM: (json['basicPriceIUOM'] ?? 0).toDouble(),
      discountAmt: (json['discountAmt'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      uom: json['uom'] ?? '',
      rateStructureCode: json['rateStructureCode'] ?? '',
      ratestructdesc: json['ratestructdesc'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
      hsnCode: json['hsnCode'] ?? '',
      basicPrice: (json['basicPrice'] ?? 0).toDouble(),
      itemLineNo: json['itemLineNo'] ?? 0,
    );
  }
}

class RateStructureDetail {
  final String rateCode;
  final String rateDesc;
  final String incOrExc;
  final String perOrVal;
  final double taxValue;
  final double rateAmount;
  final String customerItemCode;
  final String taxType;

  RateStructureDetail({
    required this.rateCode,
    required this.rateDesc,
    required this.incOrExc,
    required this.perOrVal,
    required this.taxValue,
    required this.rateAmount,
    required this.customerItemCode,
    required this.taxType,
  });

  factory RateStructureDetail.fromJson(Map<String, dynamic> json) {
    return RateStructureDetail(
      rateCode: json['rateCode'] ?? '',
      rateDesc: json['rateDesc'] ?? '',
      incOrExc: json['incOrExc'] ?? '',
      perOrVal: json['perOrVal'] ?? '',
      taxValue: (json['taxValue'] ?? 0).toDouble(),
      rateAmount: (json['rateAmount'] ?? 0).toDouble(),
      customerItemCode: json['customerItemCode'] ?? '',
      taxType: json['taxType'] ?? '',
    );
  }
}

class DeliveryDetail {
  final String itemCode;
  final double itemOrderQty;
  final double qtySUOM;
  final DateTime deliveryDate;
  final DateTime? expectedInstallationDate;
  final String shipmentCode;
  final String shipmentDesc;
  final String address1;
  final String address2;
  final String address3;
  final String cityName;
  final String stateName;
  final String countryName;
  final String pincode;

  DeliveryDetail({
    required this.itemCode,
    required this.itemOrderQty,
    required this.qtySUOM,
    required this.deliveryDate,
    this.expectedInstallationDate,
    required this.shipmentCode,
    required this.shipmentDesc,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.cityName,
    required this.stateName,
    required this.countryName,
    required this.pincode,
  });

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    return DeliveryDetail(
      itemCode: json['itemCode'] ?? '',
      itemOrderQty: (json['itemOrderQty'] ?? 0).toDouble(),
      qtySUOM: (json['qtySUOM'] ?? 0).toDouble(),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      expectedInstallationDate:
          json['expectedInstallationDate'] != null
              ? DateTime.parse(json['expectedInstallationDate'])
              : null,
      shipmentCode: json['shipmentCode'] ?? '',
      shipmentDesc: json['shipmentDesc'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      address3: json['address3'] ?? '',
      cityName: json['cityName'] ?? '',
      stateName: json['stateName'] ?? '',
      countryName: json['countryName'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class TermDetail {
  final String subType;
  final String termCode;
  final String termDesc;
  final String subTermOrChargeCode;
  final String chargeDesc;
  final String subTermDescOrChargeValue;

  TermDetail({
    required this.subType,
    required this.termCode,
    required this.termDesc,
    required this.subTermOrChargeCode,
    required this.chargeDesc,
    required this.subTermDescOrChargeValue,
  });

  factory TermDetail.fromJson(Map<String, dynamic> json) {
    return TermDetail(
      subType: json['subType'] ?? '',
      termCode: json['termCode'] ?? '',
      termDesc: json['termDesc'] ?? '',
      subTermOrChargeCode: json['subTermOrChargeCode'] ?? '',
      chargeDesc: json['chargeDesc'] ?? '',
      subTermDescOrChargeValue: json['subTermDescOrChargeValue'] ?? '',
    );
  }
}

class ContactPerson {
  final String mcustmcontper;
  final String destination;
  final String department;
  final String email;
  final String mobileNo;
  final String landLineNo;

  ContactPerson({
    required this.mcustmcontper,
    required this.destination,
    required this.department,
    required this.email,
    required this.mobileNo,
    required this.landLineNo,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      mcustmcontper: json['mcustmcontper'] ?? '',
      destination: json['destination'] ?? '',
      department: json['department'] ?? '',
      email: json['email'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      landLineNo: json['landLineNo'] ?? '',
    );
  }
}

class ShipmentLocation {
  final String shipmentCode;
  final String shipmentDescription;
  final String address1;
  final String address2;
  final String address3;
  final String cityName;
  final String stateName;
  final String countryName;
  final String pinCode;

  ShipmentLocation({
    required this.shipmentCode,
    required this.shipmentDescription,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.cityName,
    required this.stateName,
    required this.countryName,
    required this.pinCode,
  });

  factory ShipmentLocation.fromJson(Map<String, dynamic> json) {
    return ShipmentLocation(
      shipmentCode: json['shipmentCode'] ?? '',
      shipmentDescription: json['shipmentDescription'] ?? '',
      address1: json['address1'] ?? '',
      address2: json['address2'] ?? '',
      address3: json['address3'] ?? '',
      cityName: json['cityName'] ?? '',
      stateName: json['stateName'] ?? '',
      countryName: json['countryName'] ?? '',
      pinCode: json['pinCode'] ?? '',
    );
  }
}
