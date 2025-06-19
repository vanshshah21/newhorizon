class DiscountDetail {
  final int amendSrNo;
  final String currencyCode;
  final String discountCode;
  final String discountType;
  final double discountValue;
  final String salesItemCode;

  DiscountDetail({
    required this.amendSrNo,
    required this.currencyCode,
    required this.discountCode,
    required this.discountType,
    required this.discountValue,
    required this.salesItemCode,
  });

  Map<String, dynamic> toJson() => {
    "AmendSrNo": amendSrNo,
    "CurrencyCode": currencyCode,
    "DiscountCode": discountCode,
    "DiscountType": discountType,
    "DiscountValue": discountValue,
    "SalesItemCode": salesItemCode,
  };
}

class ModelDetail {
  final String salesItemCode;
  final String salesItemDesc;
  final String invoiceType;
  final String invoiceTypeShortText;
  final String discountType;
  final String discountTypeText;
  final double discountValue;
  final double discountAmt;
  final double qtyIUOM;
  final double qtySUOM;
  final int itemLineNo;
  final double basicPriceIUOM;
  final double basicPriceSUOM;

  ModelDetail({
    required this.salesItemCode,
    required this.salesItemDesc,
    required this.invoiceType,
    required this.invoiceTypeShortText,
    required this.discountType,
    required this.discountTypeText,
    required this.discountValue,
    required this.discountAmt,
    required this.qtyIUOM,
    required this.qtySUOM,
    required this.itemLineNo,
    required this.basicPriceIUOM,
    required this.basicPriceSUOM,
  });

  Map<String, dynamic> toJson() => {
    "SalesItemCode": salesItemCode,
    "SalesItemDesc": salesItemDesc,
    "InvoiceType": invoiceType,
    "InvoiceTypeShortText": invoiceTypeShortText,
    "DiscountType": discountType,
    "DiscountTypeText": discountTypeText,
    "DiscountValue": discountValue,
    "DiscountAmt": discountAmt,
    "QtyIUOM": qtyIUOM,
    "QtySUOM": qtySUOM,
    "ItemLineNo": itemLineNo,
    "BasicPriceIUOM": basicPriceIUOM,
    "BasicPriceSUOM": basicPriceSUOM,
  };
}

class QuotationDetails {
  final String billToCustomerCode;
  final String customerCode;
  final String customerName;
  final double discountAmount;
  final String discountType;
  final double exchangeRate;
  final bool isAgentAssociated;
  final bool isBudgetaryQuotation;
  final String qtnStatus;
  final String quotationDate;
  final String quotationGroup;
  final int quotationId;
  final String quotationNumber;
  final String quotationSiteCode;
  final int quotationSiteId;
  final String quotationStatus;
  final String quotationTypeConfig;
  final String quotationTypeSalesOrder;
  final String quotationYear;
  final String salesPersonCode;
  final String subject;
  final double totalAmountAfterDiscountCustomerCurrency;
  final double totalAmountAfterTaxCustomerCurrency;
  final double totalAmounttAfterTaxDomesticCurrency;
  final int validity;

  QuotationDetails({
    required this.billToCustomerCode,
    required this.customerCode,
    required this.customerName,
    required this.discountAmount,
    required this.discountType,
    required this.exchangeRate,
    required this.isAgentAssociated,
    required this.isBudgetaryQuotation,
    required this.qtnStatus,
    required this.quotationDate,
    required this.quotationGroup,
    required this.quotationId,
    required this.quotationNumber,
    required this.quotationSiteCode,
    required this.quotationSiteId,
    required this.quotationStatus,
    required this.quotationTypeConfig,
    required this.quotationTypeSalesOrder,
    required this.quotationYear,
    required this.salesPersonCode,
    required this.subject,
    required this.totalAmountAfterDiscountCustomerCurrency,
    required this.totalAmountAfterTaxCustomerCurrency,
    required this.totalAmounttAfterTaxDomesticCurrency,
    required this.validity,
  });

  Map<String, dynamic> toJson() => {
    "BillToCustomerCode": billToCustomerCode,
    "CustomerCode": customerCode,
    "CustomerName": customerName,
    "DiscountAmount": discountAmount,
    "DiscountType": discountType,
    "ExchangeRate": exchangeRate,
    "IsAgentAssociated": isAgentAssociated,
    "IsBudgetaryQuotation": isBudgetaryQuotation,
    "QtnStatus": qtnStatus,
    "QuotationDate": quotationDate,
    "QuotationGroup": quotationGroup,
    "QuotationId": quotationId,
    "QuotationNumber": quotationNumber,
    "QuotationSiteCode": quotationSiteCode,
    "QuotationSiteId": quotationSiteId,
    "QuotationStatus": quotationStatus,
    "QuotationTypeConfig": quotationTypeConfig,
    "QuotationTypeSalesOrder": quotationTypeSalesOrder,
    "QuotationYear": quotationYear,
    "SalesPersonCode": salesPersonCode,
    "Subject": subject,
    "TotalAmountAfterDiscountCustomerCurrency":
        totalAmountAfterDiscountCustomerCurrency,
    "TotalAmountAfterTaxCustomerCurrency": totalAmountAfterTaxCustomerCurrency,
    "TotalAmounttAfterTaxDomesticCurrency":
        totalAmounttAfterTaxDomesticCurrency,
    "Validity": validity,
  };
}

class RateStructureDetail {
  final int amendSrNo;
  final String applicationOn;
  final String currencyCode;
  final String customerItemCode;
  final String incOrExc;
  final String perOrVal;
  final bool postNonPost;
  final double rateAmount;
  final String rateCode;
  final String rateSturctureCode;
  final int sequenceNo;

  RateStructureDetail({
    required this.amendSrNo,
    required this.applicationOn,
    required this.currencyCode,
    required this.customerItemCode,
    required this.incOrExc,
    required this.perOrVal,
    required this.postNonPost,
    required this.rateAmount,
    required this.rateCode,
    required this.rateSturctureCode,
    required this.sequenceNo,
  });

  Map<String, dynamic> toJson() => {
    "AmendSrNo": amendSrNo,
    "ApplicationOn": applicationOn,
    "CurrencyCode": currencyCode,
    "CustomerItemCode": customerItemCode,
    "IncOrExc": incOrExc,
    "PerOrVal": perOrVal,
    "PostNonPost": postNonPost,
    "RateAmount": rateAmount,
    "RateCode": rateCode,
    "RateSturctureCode": rateSturctureCode,
    "SequenceNo": sequenceNo,
  };
}

class QuotationPayload {
  final String authorizationDate;
  final String authorizationRequired;
  final String autoNumberRequired;
  final int companyId;
  final List<DiscountDetail> discountDetails;
  final String docSubType;
  final String docType;
  final String domesticCurrencyCode;
  final String fromLocationCode;
  final int fromLocationId;
  final String fromLocationName;
  final String ip;
  final String mac;
  final List<ModelDetail> modelDetails;
  final List noteDetails;
  final QuotationDetails quotationDetails;
  final List quotationRemarks;
  final List quotationTextDetails;
  final List<RateStructureDetail> rateStructureDetails;
  final Map rawView;
  final String siteRequired;
  final List standardTerms;
  final List subItemDetails;
  final List termDetails;
  final int userId;
  final bool msctechspecifications;
  final List technicalspec;

  QuotationPayload({
    required this.authorizationDate,
    required this.authorizationRequired,
    required this.autoNumberRequired,
    required this.companyId,
    required this.discountDetails,
    required this.docSubType,
    required this.docType,
    required this.domesticCurrencyCode,
    required this.fromLocationCode,
    required this.fromLocationId,
    required this.fromLocationName,
    this.ip = "",
    this.mac = "",
    required this.modelDetails,
    this.noteDetails = const [],
    required this.quotationDetails,
    this.quotationRemarks = const [],
    this.quotationTextDetails = const [],
    required this.rateStructureDetails,
    this.rawView = const {},
    required this.siteRequired,
    this.standardTerms = const [],
    this.subItemDetails = const [],
    this.termDetails = const [],
    required this.userId,
    required this.msctechspecifications,
    this.technicalspec = const [],
  });

  Map<String, dynamic> toJson() => {
    "AuthorizationDate": authorizationDate,
    "AuthorizationRequired": authorizationRequired,
    "AutoNumberRequired": autoNumberRequired,
    "CompanyId": companyId,
    "DiscountDetails": discountDetails.map((e) => e.toJson()).toList(),
    "DocSubType": docSubType,
    "DocType": docType,
    "DomesticCurrencyCode": domesticCurrencyCode,
    "FromLocationCode": fromLocationCode,
    "FromLocationId": fromLocationId,
    "FromLocationName": fromLocationName,
    "IP": ip,
    "MAC": mac,
    "ModelDetails": modelDetails.map((e) => e.toJson()).toList(),
    "NoteDetails": noteDetails,
    "QuotationDetails": quotationDetails.toJson(),
    "QuotationRemarks": quotationRemarks,
    "QuotationTextDetails": quotationTextDetails,
    "RateStructureDetails":
        rateStructureDetails.map((e) => e.toJson()).toList(),
    "Raw View": rawView,
    "SiteRequired": siteRequired,
    "StandardTerms": standardTerms,
    "SubItemDetails": subItemDetails,
    "TermDetails": termDetails,
    "UserId": userId,
    "msctechspecifications": msctechspecifications,
    "technicalspec": technicalspec,
  };
}
