public class PrformaInvoiceInsertModel
    {
        public string Action { get; set; } //Add , Edit
        public string autoNoRequired { get; set; }
        public decimal ExchangeRate { get; set; }
        public string CustomerPoNumber { get; set; }
        public DateTime? CustomerPoDate { get; set; }

        public InvoiceHeaderModel itemHeaderDetial { get; set; }
        public List<ItemDetailInserModel> itemDetail { get; set; }
        public List<ProformaRateStructureDetail> rsGrid { get; set; }
        public List<ProformaDiscountDetail> discountDetail { get; set; }
        public List<TermDetail> termsDetail { get; set; }
        public TransPortDetail transportDetail { get; set; }
        public List<TermDetail> chargesDetail { get; set; }
        public List<Mtxtmast_InsertModel> remark { get; set; }
        public List<StandardTerms> StandardTerms { get; set; }
    }

     public class InvoiceHeaderModel
    {
        //csp_XPROINVHDR_Insert
        public Int64 autoId { get; set; } //XPIHAUTOID
        public string invYear { get; set; } // XPIHINVYR
        public string invGroup { get; set; } //XPIHINVGRP
        public int invSite { get; set; } //XPIHINVSITE
        public string invSiteCode { get; set; } //XPIHINVSITE
        public DateTime invIssueDate { get; set; } //XPIHISSUEDT
        public decimal invValue { get; set; } //XPIHTVAL  // Total Discounted Basic From Other Detail
        public decimal invAmount { get; set; } //XPIHTAAMT  // Total Discounted Basic From Other Detail
        public decimal invTax { get; set; } // XPIHTTX // Total Tax value from Other Detail
        public string invType { get; set; } //XPIHINVTYP  
        public string invCustCode { get; set; } //XPIHCUSTCD
        public string invStatus { get; set; } // XPIHSTATUS
        public string invOn { get; set; } //XPIHON
        public string invDiscountType { get; set; } //XPIHDISCTYP
        public decimal invDiscountValue { get; set; } //XPIHDISCVAL
        public int invFromLocationId { get; set; } //XPIHFMLOCID
        public int invCreatedUserId { get; set; } //CREUSRID
        public string invCurrCode { get; set; } //XPIHCURRCD
        public decimal ExchangeRate { get; set; } //XPIHEXRATE 
        public string CustomerPoNumber { get; set; }
        public DateTime? CustomerPoDate { get; set; }
        public string invNumber { get; set; } //XPIHINVNO
        public decimal invBacAmount { get; set; } //XPIHBSCAMT  // total basic from other detail
        public string invSiteReq { get; set; } // SITEREQ

    }

     public class ItemDetailInserModel : InvoiceItemDetail
    {
        public string ordYear { get; set; } // @XPIDORDGRP
        public decimal RcvAdv { get; set; } // @XPIDRcvAdv // Already receive from Other detail
        public decimal PIAdv { get; set; } // @XPIDAdv   // to be receive amt from other detail
        public decimal RtnAmt { get; set; } // @XPIDRtnAmt  // retain amt from other detial
        public string CurrCd { get; set; } // @XPIDCurrCd //
        public int CreatedBy { get; set; } // @XPIDCurrCd  // item detail currency code
        public decimal netDiscountRate { get; set; } // @XPIDNETDSCRT //net discount rate from item detail
        public decimal discOrdRate { get; set; } // @XPIDORDRT // rate from item grid
        public int lineNo { get; set; } // @XPIDITMLINENO / line no fron detail grid
        public string HSNAccCode { get; set; } // @XPIDGSTHSNSACCD //
        public string Remarks { get; set; } // @XPIDGSTHSNSACCD //
        public string mainitemcode { get; set; }
        public string printseq { get; set; }
        public string detaildescription { get; set; }
        public decimal loadRate { get; set; }   //XPILODRATE
    }

    public class ProformaRateStructureDetail
    {
        public string docType { get; set; } //@XDTDCATTYPE
        public string docSubType { get; set; } //  @XDTDSUBTYPE
        public Int64 docId { get; set; } //  @XDTDDOCID
        public string XDTDTMCD { get; set; } //  @XDTDTMCD
        public string rateCode { get; set; } //  @XDTDRATECD
        public decimal rateAmount { get; set; } //  @XDTDRATEAMT
        public int amdSrNo { get; set; } //  @XDTDAMDSRNO
        public decimal perCValue { get; set; } //  @XDTDPERCVAL
        public string IncExc { get; set; } //  @XDTDINCEXC
        public string PerVal { get; set; } // @XDTDPERVAL
        public string AppliedOn { get; set; } // @XDTDAPPON
        public bool PNYN { get; set; } // @XDTDPNYN
        public string rateStructCode { get; set; } // @XDTDRTSTRCD
        public int seqNo { get; set; } // @XDTDSEQNO
        public int fromLocationId { get; set; } // @XDTFRLOC
        public int py { get; set; } // @XDTFRLOC
        public string curCode { get; set; } // @XDTDCURCODE
        public string TaxTyp { get; set; } // @XDTDTAXTYP
        public Int64 RefId { get; set; } // @XDTDREFID
        public decimal percentage { get; set; } // @XDTDREFID
        public Int64 refLine { get; set; } // @XDTDREFID
    }

    public class ProformaDiscountDetail
    {
        public Int64 invId { get; set; } //@PIDPInvId
        public string itemCode { get; set; } // @PIDItmCd
        public string currCode { get; set; } // @PIDCurrCd
        public string discCode { get; set; } // @PIDDiscCd
        public string discType { get; set; } // @PIDDiscType
        public decimal discVal { get; set; } // @PIDDiscVal
        public int fromLocationId { get; set; } // @PIDPFMLOCID
    }

- SrNo is in proformaInvoiceGetSONumberList