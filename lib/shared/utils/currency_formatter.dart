import 'package:intl/intl.dart';

final NumberFormat _currency =
    NumberFormat.currency(locale: 'es_MX', symbol: r'$', decimalDigits: 2);

String formatCents(int cents) => _currency.format(cents / 100);

int? parseAmountToCents(String input) {
  final text = input.trim().replaceAll(',', '.');
  final match = RegExp(r'^(\d{1,9})(?:\.(\d{1,2}))?$').firstMatch(text);
  if (match == null) return null;

  final whole = int.parse(match.group(1)!);
  final fraction = int.parse((match.group(2) ?? '').padRight(2, '0'));
  return whole * 100 + fraction;
}

String centsToInput(int cents) {
  final whole = cents ~/ 100;
  final fraction = (cents % 100).toString().padLeft(2, '0');
  return '$whole.$fraction';
}
