// lib/helpers/quotation_helper.dart

class QuotationCalculationResult {
  final double itemAmount;
  final double discountValueApplied;
  final double discountedAmount;

  QuotationCalculationResult({
    required this.itemAmount,
    required this.discountValueApplied,
    required this.discountedAmount,
  });
}

QuotationCalculationResult calculateDiscountedTotal({
  required double qty,
  required double rate,
  required String discountType,
  required double discountValue,
}) {
  final itemAmount = qty * rate;
  double discountValueApplied = 0.0;

  if (discountType.toLowerCase() == "percentage" && discountValue > 0) {
    discountValueApplied = itemAmount * (discountValue / 100);
  } else if (discountType.toLowerCase() == "value" && discountValue > 0) {
    discountValueApplied = discountValue;
    if (discountValueApplied > itemAmount) {
      discountValueApplied = itemAmount;
    }
  }
  final discountedAmount = itemAmount - discountValueApplied;
  return QuotationCalculationResult(
    itemAmount: itemAmount,
    discountValueApplied: discountValueApplied,
    discountedAmount: discountedAmount,
  );
}
