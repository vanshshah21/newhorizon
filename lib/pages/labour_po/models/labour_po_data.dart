import 'labour_po_item.dart';

class LabourPOData {
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
  final String mobile;
  final bool isAmendment;
  final List<LabourPOItem> itemDetail;

  LabourPOData({
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
    required this.itemDetail,
  });

  factory LabourPOData.fromJson(Map<String, dynamic> json) => LabourPOData(
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
    isEdit: json['isEdit'] ?? false,
    isDelete: json['isDelete'] ?? false,
    isAuthorize: json['isAuthorize'] ?? false,
    pendingforauth: json['pendingforauth'] ?? false,
    doctype: json['doctype'] ?? '',
    docsubtype: json['docsubtype'] ?? '',
    poamtsrno: json['poamtsrno'],
    pototalamt: (json['pototalamt'] ?? 0).toDouble(),
    pOStatus: json['pOStatus'] ?? '',
    pohremark: json['pohremark'] ?? '',
    pohremark1: json['pohremark1'] ?? '',
    isPOAmended: json['isPOAmended'] ?? false,
    pendingforauth1: json['pendingforauth1'] ?? false,
    creatorName: json['creatorName'],
    authorizerName: json['authorizerName'],
    mobile: json['mobile'] ?? '',
    isAmendment: json['isAmendment'] ?? false,
    itemDetail:
        (json['itemDetail'] as List<dynamic>? ?? [])
            .map((e) => LabourPOItem.fromJson(e))
            .toList(),
  );

  Map<String, dynamic> toJson() => {
    'totalRows': totalRows,
    'poBasis': poBasis,
    'poType': poType,
    'year': year,
    'grp': grp,
    'siteid': siteid,
    'site': site,
    'sitename': sitename,
    'nmbr': nmbr,
    'date': date,
    'vendor': vendor,
    'buyer': buyer,
    'id': id,
    'rowstatus': rowstatus,
    'type': type,
    'subType': subType,
    'isEdit': isEdit,
    'isDelete': isDelete,
    'isAuthorize': isAuthorize,
    'pendingforauth': pendingforauth,
    'doctype': doctype,
    'docsubtype': docsubtype,
    'poamtsrno': poamtsrno,
    'pototalamt': pototalamt,
    'pOStatus': pOStatus,
    'pohremark': pohremark,
    'pohremark1': pohremark1,
    'isPOAmended': isPOAmended,
    'pendingforauth1': pendingforauth1,
    'creatorName': creatorName,
    'authorizerName': authorizerName,
    'mobile': mobile,
    'isAmendment': isAmendment,
    'itemDetail': itemDetail.map((e) => e.toJson()).toList(),
  };
}
