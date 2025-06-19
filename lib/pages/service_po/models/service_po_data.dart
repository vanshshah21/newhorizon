class ServicePOItem {
  final String itemCode;
  final String itemDesc;
  final double qty;
  final String uom;
  final double rate;
  final double amount;

  const ServicePOItem({
    required this.itemCode,
    required this.itemDesc,
    required this.qty,
    required this.uom,
    required this.rate,
    required this.amount,
  });

  factory ServicePOItem.fromJson(Map<String, dynamic> json) => ServicePOItem(
    itemCode: json['itemCode'] ?? '',
    itemDesc: json['itemDesc'] ?? '',
    qty: (json['qty'] ?? 0).toDouble(),
    uom: json['uom'] ?? '',
    rate: (json['rate'] ?? 0).toDouble(),
    amount: (json['amount'] ?? 0).toDouble(),
  );
}

class ServicePOData {
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
  final String mobile;
  final List<ServicePOItem> itemDetail;

  const ServicePOData({
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
    required this.mobile,
    required this.itemDetail,
  });

  factory ServicePOData.fromJson(Map<String, dynamic> json) => ServicePOData(
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
    mobile: json['mobile'] ?? '',
    itemDetail:
        (json['itemDetail'] as List<dynamic>? ?? [])
            .map((e) => ServicePOItem.fromJson(e))
            .toList(),
  );
}
