class FollowupListItem {
  final int totalRows;
  final int autoId;
  final String custCode;
  final String baseOn;
  final String baseOnDesc;
  final int maxFollowUp;
  final String year;
  final String groupCode;
  final String number;
  final String date;
  final String siteCode;
  final String siteFullName;
  final String customerFullName;
  final String docId;
  final String docDate;
  final String siteId;
  final String mobileNo;
  final String emailAddress;
  final String salesmanCode;
  final String salesmanName;
  final String nextsalesmanCode;
  final String nextsalesmanName;

  FollowupListItem({
    required this.totalRows,
    required this.autoId,
    required this.custCode,
    required this.baseOn,
    required this.baseOnDesc,
    required this.maxFollowUp,
    required this.year,
    required this.groupCode,
    required this.number,
    required this.date,
    required this.siteCode,
    required this.siteFullName,
    required this.customerFullName,
    required this.docId,
    required this.docDate,
    required this.siteId,
    required this.mobileNo,
    required this.emailAddress,
    required this.salesmanCode,
    required this.salesmanName,
    required this.nextsalesmanCode,
    required this.nextsalesmanName,
  });

  factory FollowupListItem.fromJson(Map<String, dynamic> json) {
    return FollowupListItem(
      totalRows: json['totalRows'] ?? 0,
      autoId: json['autoId'] ?? 0,
      custCode: json['custCode'] ?? '',
      baseOn: json['baseOn'] ?? '',
      baseOnDesc: json['baseOnDesc'] ?? '',
      maxFollowUp: json['maxFollowUp'] ?? 0,
      year: json['year'] ?? '',
      groupCode: json['groupCode'] ?? '',
      number: json['number'] ?? '',
      date: json['date'] ?? '',
      siteCode: json['siteCode'] ?? '',
      siteFullName: json['siteFullName'] ?? '',
      customerFullName: json['customerFullName'] ?? '',
      docId: json['docId']?.toString() ?? '',
      docDate: json['docDate'] ?? '',
      siteId: json['siteId']?.toString() ?? '',
      mobileNo: json['mobileNo'] ?? '',
      emailAddress: json['emailAddress'] ?? '',
      salesmanCode: json['salesmanCode'] ?? '',
      salesmanName: json['salesmanName'] ?? '',
      nextsalesmanCode: json['nextsalesmanCode'] ?? '',
      nextsalesmanName: json['nextsalesmanName'] ?? '',
    );
  }
}
