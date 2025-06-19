class ServiceOrderData {
  final int totalRows;
  final int id;
  final String year;
  final String grp;
  final String number;
  final String date;
  final String sitecode;
  final int siteid;
  final String site;
  final String vend;
  final String buyer;
  final String potype;
  final String vendorcode;
  final String vendorname;
  final double pobasicamount;
  final double totalpovalue;
  final int isedit;
  final int isdelete;
  final int rowstatus;
  final String? pohsremark;
  final String? pohsremark1;
  final int isAuthorize;
  final String creatorName;
  final String authorizerName;
  final String mobile;
  final int isAmendment;
  final int poAmdSrNo;
  final String poStatus;

  ServiceOrderData({
    required this.totalRows,
    required this.id,
    required this.year,
    required this.grp,
    required this.number,
    required this.date,
    required this.sitecode,
    required this.siteid,
    required this.site,
    required this.vend,
    required this.buyer,
    required this.potype,
    required this.vendorcode,
    required this.vendorname,
    required this.pobasicamount,
    required this.totalpovalue,
    required this.isedit,
    required this.isdelete,
    required this.rowstatus,
    required this.pohsremark,
    required this.pohsremark1,
    required this.isAuthorize,
    required this.creatorName,
    required this.authorizerName,
    required this.mobile,
    required this.isAmendment,
    required this.poAmdSrNo,
    required this.poStatus,
  });

  factory ServiceOrderData.fromJson(Map<String, dynamic> json) =>
      ServiceOrderData(
        totalRows: json['totalRows'] ?? 0,
        id: json['id'] ?? 0,
        year: json['year'] ?? '',
        grp: json['grp'] ?? '',
        number: json['number'] ?? '',
        date: json['date'] ?? '',
        sitecode: json['sitecode'] ?? '',
        siteid: json['siteid'] ?? 0,
        site: json['site'] ?? '',
        vend: json['vend'] ?? '',
        buyer: json['buyer'] ?? '',
        potype: json['potype'] ?? '',
        vendorcode: json['vendorcode'] ?? '',
        vendorname: json['vendorname'] ?? '',
        pobasicamount: (json['pobasicamount'] ?? 0).toDouble(),
        totalpovalue: (json['totalpovalue'] ?? 0).toDouble(),
        isedit: json['isedit'] ?? 0,
        isdelete: json['isdelete'] ?? 0,
        rowstatus: json['rowstatus'] ?? 0,
        pohsremark: json['pohsremark'],
        pohsremark1: json['pohsremark1'],
        isAuthorize: json['isAuthorize'] ?? 0,
        creatorName: json['CreatorName'] ?? '',
        authorizerName: json['AuthorizerName'] ?? '',
        mobile: json['mobile'] ?? '',
        isAmendment: json['IsAmendment'] ?? 0,
        poAmdSrNo: json['PoAmdSrNo'] ?? 0,
        poStatus: json['PoStatus'] ?? '',
      );
}
