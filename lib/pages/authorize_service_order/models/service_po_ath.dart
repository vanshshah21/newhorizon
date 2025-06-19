class ServicePOAth {
  final int id;
  final String year;
  final String grp;
  final String number;
  final int siteid;
  final String sitecode;
  final String vendorcode;
  final String vendorname;
  final int loginsiteid;
  final String loginsitecode;
  final String loginsitename;
  final String formid;

  ServicePOAth({
    required this.id,
    required this.year,
    required this.grp,
    required this.number,
    required this.siteid,
    required this.sitecode,
    required this.vendorcode,
    required this.vendorname,
    required this.loginsiteid,
    required this.loginsitecode,
    required this.loginsitename,
    required this.formid,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "year": year,
    "grp": grp,
    "number": number,
    "siteid": siteid,
    "sitecode": sitecode,
    "vendorcode": vendorcode,
    "vendorname": vendorname,
    "loginsiteid": loginsiteid,
    "loginsitecode": loginsitecode,
    "loginsitename": loginsitename,
    "formid": formid,
  };
}
