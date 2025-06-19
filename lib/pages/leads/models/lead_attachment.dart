class LeadAttachment {
  final int id;
  final String originalName;
  final String sysFileName;
  final String extension;
  final String mimeType;
  final String? dirPath;
  final int size;
  final String formID;
  final String createdBy;
  final String createdDate;
  final String name;
  final String type;
  final String docYear;
  final String documentNo;

  LeadAttachment({
    required this.id,
    required this.originalName,
    required this.sysFileName,
    required this.extension,
    required this.mimeType,
    required this.dirPath,
    required this.size,
    required this.formID,
    required this.createdBy,
    required this.createdDate,
    required this.name,
    required this.type,
    required this.docYear,
    required this.documentNo,
  });

  factory LeadAttachment.fromJson(Map<String, dynamic> json) => LeadAttachment(
    id: json['id'],
    originalName: json['originalName'],
    sysFileName: json['sysFileName'],
    extension: json['extension'],
    mimeType: json['mimeType'],
    dirPath: json['dirPath'],
    size: json['size'],
    formID: json['formID'],
    createdBy: json['createdBy'],
    createdDate: json['createdDate'],
    name: json['name'],
    type: json['type'],
    docYear: json['docYear'] ?? '',
    documentNo: json['documentNo'] ?? '',
  );
}
