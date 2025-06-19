class FollowupDetail {
  final int autoId;
  final String custCode;
  final String baseOn;
  final int followUpCount;
  final int docId;
  final String followUpDate;
  final String expeResDate;
  final double followUpCost;
  final String followUpTime;
  final String salesPerCode;
  final String method;
  final String remark;
  final String nxtSalesPersonCode;
  final String? nxtFollowUpDate;
  final String followUpAgenda;
  final String salesmanName1;
  final String salesmanName2;
  final String salesManFullName;
  final String newSalesManFullName;
  final String description;

  FollowupDetail({
    required this.autoId,
    required this.custCode,
    required this.baseOn,
    required this.followUpCount,
    required this.docId,
    required this.followUpDate,
    required this.expeResDate,
    required this.followUpCost,
    required this.followUpTime,
    required this.salesPerCode,
    required this.method,
    required this.remark,
    required this.nxtSalesPersonCode,
    required this.nxtFollowUpDate,
    required this.followUpAgenda,
    required this.salesmanName1,
    required this.salesmanName2,
    required this.salesManFullName,
    required this.newSalesManFullName,
    required this.description,
  });

  factory FollowupDetail.fromJson(Map<String, dynamic> json) {
    return FollowupDetail(
      autoId: json['autoId'] ?? 0,
      custCode: json['custCode'] ?? '',
      baseOn: json['baseOn'] ?? '',
      followUpCount: json['followUpCount'] ?? 0,
      docId: json['docId'] ?? 0,
      followUpDate: json['followUpDate'] ?? '',
      expeResDate: json['expeResDate'] ?? '',
      followUpCost: (json['followUpCost'] ?? 0).toDouble(),
      followUpTime: json['followUpTime'] ?? '',
      salesPerCode: json['salesPerCode'] ?? '',
      method: json['method'] ?? '',
      remark: json['remark'] ?? '',
      nxtSalesPersonCode: json['nxtSalesPersonCode'] ?? '',
      nxtFollowUpDate: json['nxtFollowUpDate'],
      followUpAgenda: json['followUpAgenda'] ?? '',
      salesmanName1: json['salesmanName1'] ?? '',
      salesmanName2: json['salesmanName2'] ?? '',
      salesManFullName: json['salesManFullName'] ?? '',
      newSalesManFullName: json['newSalesManFullName'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoId': autoId,
      'custCode': custCode,
      'baseOn': baseOn,
      'followUpCount': followUpCount,
      'docId': docId,
      'followUpDate': followUpDate,
      'expeResDate': expeResDate,
      'followUpCost': followUpCost,
      'followUpTime': followUpTime,
      'salesPerCode': salesPerCode,
      'method': method,
      'remark': remark,
      'nxtSalesPersonCode': nxtSalesPersonCode,
      'nxtFollowUpDate': nxtFollowUpDate,
      'followUpAgenda': followUpAgenda,
      'salesmanName1': salesmanName1,
      'salesmanName2': salesmanName2,
      'salesManFullName': salesManFullName,
      'newSalesManFullName': newSalesManFullName,
      'description': description,
    };
  }
}
