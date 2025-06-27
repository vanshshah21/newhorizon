import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  // Use static final to avoid recreating formatters (performance)
  static final DateFormat _userDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _apiDateFormat = DateFormat('yyyy/MM/dd');
  static final NumberFormat _amountFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '',
    decimalDigits: 2,
  );
  static final NumberFormat _quantityFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 4,
  );

  /// Formats a [DateTime] for user display as dd/MM/yyyy.
  static String formatDateForUser(DateTime? date) {
    if (date == null) return '';
    try {
      return _userDateFormat.format(date);
    } catch (e, stack) {
      debugPrint('FormatUtils.formatDateForUser error: $e\n$stack');
      return '';
    }
  }

  /// Formats a [DateTime] for API as yyyy/MM/dd.
  static String formatDateForApi(DateTime? date) {
    if (date == null) return '';
    try {
      return _apiDateFormat.format(date);
    } catch (e, stack) {
      debugPrint('FormatUtils.formatDateForApi error: $e\n$stack');
      return '';
    }
  }

  /// Formats an amount as en_IN, no symbol, 2 decimal digits.
  static String formatAmount(dynamic amount) {
    if (amount == null) return '';
    try {
      final num value = _parseNum(amount);
      return _amountFormat.format(value).trim();
    } catch (e, stack) {
      debugPrint('FormatUtils.formatAmount error: $e\n$stack');
      return '';
    }
  }

  /// Formats a quantity as en_IN, 4 decimal digits, no symbol.
  static String formatQuantity(dynamic quantity) {
    if (quantity == null) return '';
    try {
      final num value = _parseNum(quantity);
      return _quantityFormat.format(value).trim();
    } catch (e, stack) {
      debugPrint('FormatUtils.formatQuantity error: $e\n$stack');
      return '';
    }
  }

  /// Helper to parse num from dynamic input (String, int, double, num)
  static num _parseNum(dynamic value) {
    if (value is num) return value;
    if (value is String) {
      final parsed = num.tryParse(value.replaceAll(',', ''));
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid number: $value');
  }

  static String timeOfDayToHHmmss(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }
}
