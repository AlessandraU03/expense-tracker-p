import 'package:intl/intl.dart';

final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');

String formatDate(DateTime date) => _displayFormat.format(date);

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String toIsoDate(DateTime date) {
  final d = dateOnly(date);
  final month = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$month-$day';
}

DateTime fromIsoDate(String value) => dateOnly(DateTime.parse(value));
