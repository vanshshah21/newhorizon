class NotificationItem {
  final int xntautoid;
  final String? xnummenuname;
  final String xntmsgdesC1;
  final String xntmsgdesC2;
  final String xntmsgdesC3;
  final int userId;
  final String xntdoccrusrcd;
  final String xntdoccrusrdt;
  final String xnumformid;
  final String xntdocid;
  final int totalRows;
  final String fullDate;
  final String time;
  final String docno;
  final bool markasread;

  NotificationItem({
    required this.xntautoid,
    required this.xnummenuname,
    required this.xntmsgdesC1,
    required this.xntmsgdesC2,
    required this.xntmsgdesC3,
    required this.userId,
    required this.xntdoccrusrcd,
    required this.xntdoccrusrdt,
    required this.xnumformid,
    required this.xntdocid,
    required this.totalRows,
    required this.fullDate,
    required this.time,
    required this.docno,
    required this.markasread,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        xntautoid: json['xntautoid'] ?? 0,
        xnummenuname: json['xnummenuname'],
        xntmsgdesC1: json['xntmsgdesC1'] ?? '',
        xntmsgdesC2: json['xntmsgdesC2'] ?? '',
        xntmsgdesC3: json['xntmsgdesC3'] ?? '',
        userId: json['userId'] ?? 0,
        xntdoccrusrcd: json['xntdoccrusrcd'] ?? '',
        xntdoccrusrdt: json['xntdoccrusrdt'] ?? '',
        xnumformid: json['xnumformid'] ?? '',
        xntdocid: json['xntdocid'] ?? '',
        totalRows: json['totalRows'] ?? 0,
        fullDate: json['fullDate'] ?? '',
        time: json['time'] ?? '',
        docno: json['docno'] ?? '',
        markasread: json['markasread'] ?? false,
      );
}
