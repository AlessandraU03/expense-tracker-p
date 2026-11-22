import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_filters.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

List<Expense> applyFilters(List<Expense> expenses, ExpenseFilters filters) {
  final query = filters.query.trim().toLowerCase();
  final from = filters.from == null ? null : dateOnly(filters.from!);
  final to = filters.to == null ? null : dateOnly(filters.to!);

  final result = expenses.where((expense) {
    if (filters.category != null && expense.category != filters.category) {
      return false;
    }

    final day = dateOnly(expense.date);
    if (from != null && day.isBefore(from)) return false;
    if (to != null && day.isAfter(to)) return false;

    if (query.isNotEmpty && !expense.concept.toLowerCase().contains(query)) {
      return false;
    }
    return true;
  }).toList();

  result.sort(_comparatorFor(filters.sort));
  return result;
}

int _newestFirst(Expense a, Expense b) {
  final byDate = b.date.compareTo(a.date);
  if (byDate != 0) return byDate;
  final byCreated = b.createdAtMs.compareTo(a.createdAtMs);
  return byCreated != 0 ? byCreated : b.id.compareTo(a.id);
}

Comparator<Expense> _comparatorFor(ExpenseSort sort) {
  switch (sort) {
    case ExpenseSort.dateDesc:
      return _newestFirst;
    case ExpenseSort.dateAsc:
      return (a, b) => _newestFirst(b, a);
    case ExpenseSort.amountDesc:
      return (a, b) {
        final byAmount = b.amountInCents.compareTo(a.amountInCents);
        return byAmount != 0 ? byAmount : _newestFirst(a, b);
      };
    case ExpenseSort.amountAsc:
      return (a, b) {
        final byAmount = a.amountInCents.compareTo(b.amountInCents);
        return byAmount != 0 ? byAmount : _newestFirst(a, b);
      };
  }
}
