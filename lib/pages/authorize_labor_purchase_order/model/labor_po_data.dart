class LaborPOData {
  final int totalRows;
  final String poBasis;
  final String poType;
  final String year;
  final String grp;
  final int siteid;
  final String site;
  final String sitename;
  final String nmbr;
  final String date;
  final String vendor;
  final String buyer;
  final int id;
  final String rowstatus;
  final String? type;
  final String subType;
  final bool isEdit;
  final bool isDelete;
  final bool isAuthorize;
  final bool pendingforauth;
  final String doctype;
  final String docsubtype;
  final dynamic poamtsrno;
  final double pototalamt;
  final String pOStatus;
  final String pohremark;
  final String pohremark1;
  final bool isPOAmended;
  final bool pendingforauth1;
  final String? creatorName;
  final String? authorizerName;
  final String? mobile;
  final bool isAmendment;

  LaborPOData({
    required this.totalRows,
    required this.poBasis,
    required this.poType,
    required this.year,
    required this.grp,
    required this.siteid,
    required this.site,
    required this.sitename,
    required this.nmbr,
    required this.date,
    required this.vendor,
    required this.buyer,
    required this.id,
    required this.rowstatus,
    required this.type,
    required this.subType,
    required this.isEdit,
    required this.isDelete,
    required this.isAuthorize,
    required this.pendingforauth,
    required this.doctype,
    required this.docsubtype,
    required this.poamtsrno,
    required this.pototalamt,
    required this.pOStatus,
    required this.pohremark,
    required this.pohremark1,
    required this.isPOAmended,
    required this.pendingforauth1,
    required this.creatorName,
    required this.authorizerName,
    required this.mobile,
    required this.isAmendment,
  });

  factory LaborPOData.fromJson(Map<String, dynamic> json) => LaborPOData(
    totalRows: json['totalRows'] ?? 0,
    poBasis: json['poBasis'] ?? '',
    poType: json['poType'] ?? '',
    year: json['year'] ?? '',
    grp: json['grp'] ?? '',
    siteid: json['siteid'] ?? 0,
    site: json['site'] ?? '',
    sitename: json['sitename'] ?? '',
    nmbr: json['nmbr'] ?? '',
    date: json['date'] ?? '',
    vendor: json['vendor'] ?? '',
    buyer: json['buyer'] ?? '',
    id: json['id'] ?? 0,
    rowstatus: json['rowstatus'] ?? '',
    type: json['type'],
    subType: json['subType'] ?? '',
    isEdit: json['isEdit'] == true || json['isEdit'] == 1,
    isDelete: json['isDelete'] == true || json['isDelete'] == 1,
    isAuthorize: json['isAuthorize'] == true || json['isAuthorize'] == 1,
    pendingforauth:
        json['pendingforauth'] == true || json['pendingforauth'] == 1,
    doctype: json['doctype'] ?? '',
    docsubtype: json['docsubtype'] ?? '',
    poamtsrno: json['poamtsrno'],
    pototalamt: (json['pototalamt'] ?? 0).toDouble(),
    pOStatus: json['pOStatus'] ?? '',
    pohremark: json['pohremark'] ?? '',
    pohremark1: json['pohremark1'] ?? '',
    isPOAmended: json['isPOAmended'] == true || json['isPOAmended'] == 1,
    pendingforauth1:
        json['pendingforauth1'] == true || json['pendingforauth1'] == 1,
    creatorName: json['creatorName'],
    authorizerName: json['authorizerName'],
    mobile: json['mobile'],
    isAmendment: json['isAmendment'] == true || json['isAmendment'] == 1,
  );

  Map<String, dynamic> pdfPOBody() => {
    'poBasis': poBasis,
    'poType': poType,
    'year': year,
    'grp': grp,
    'site': site,
    'nmbr': nmbr,
    'date': date,
    'id': id,
    'isEdit': isEdit,
    'isDelete': isDelete,
    'isAuthorize': isAuthorize,
    'rowstatus': rowstatus,
    'pendingforauth': pendingforauth,
    'siteid': siteid,
    'sitename': sitename,
    'docsubtype': docsubtype,
    'doctype': doctype,
    'pOStatus': pOStatus,
    'vendor': vendor,
    'pohremark': pohremark,
    'pohremark1': pohremark1,
    'poAmdSrNo': 0,
    'uid': 0,
    'boundindex': 0,
    'uniqueid': "",
    'visibleindex': 0,
    'autoId': id,
  };

  Map<String, dynamic> authPOBody() => {
    'intAutoId': id,
    'poType': poType,
    'year': year,
    'grp': grp,
    'site': site,
    'nmbr': nmbr,
    'siteid': siteid,
    'sitename': sitename,
    'poBasis': poBasis,
    'vendor': vendor.split("-")[1].trim(),
    'vndCode': vendor.split("-")[0].trim(),
    'doctype': doctype,
    'docsubtype': docsubtype,
    'companyId': 0,
  };
}
