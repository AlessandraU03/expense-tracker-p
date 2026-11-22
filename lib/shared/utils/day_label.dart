const _months = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String formatShortDate(DateTime date) {
  final base = '${date.day} ${_months[date.month - 1]}';
  return date.year == DateTime.now().year ? base : '$base ${date.year}';
}
