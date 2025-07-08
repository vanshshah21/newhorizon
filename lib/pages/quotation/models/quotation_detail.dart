// class QuotationDetail {
//   final Map<String, dynamic> quotationDetails;
//   final List<Map<String, dynamic>> modelDetails;

//   QuotationDetail({required this.quotationDetails, required this.modelDetails});

//   factory QuotationDetail.fromJson(Map<String, dynamic> json) {
//     return QuotationDetail(
//       quotationDetails:
//           (json['quotationDetails'] as List).isNotEmpty
//               ? json['quotationDetails'][0] as Map<String, dynamic>
//               : {},
//       modelDetails:
//           (json['modelDetails'] as List<dynamic>? ?? [])
//               .map((e) => e as Map<String, dynamic>)
//               .toList(),
//     );
//   }
// }

class QuotationDetail {
  final Map<String, dynamic> quotationDetails;
  final List<Map<String, dynamic>> modelDetails;
  final List<Map<String, dynamic>> rateStructureDetails;

  QuotationDetail({
    required this.quotationDetails,
    required this.modelDetails,
    required this.rateStructureDetails,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) {
    return QuotationDetail(
      quotationDetails:
          (json['quotationDetails'] as List).isNotEmpty
              ? json['quotationDetails'][0] as Map<String, dynamic>
              : {},
      modelDetails:
          (json['modelDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      rateStructureDetails:
          (json['rateStructureDetails'] as List<dynamic>? ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList(),
    );
  }
}
