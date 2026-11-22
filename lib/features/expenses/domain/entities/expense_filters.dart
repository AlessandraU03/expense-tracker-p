import 'package:tracker/features/expenses/domain/entities/expense_category.dart';

enum ExpenseSort {
  dateDesc('Fecha: más recientes'),
  dateAsc('Fecha: más antiguos'),
  amountDesc('Monto: mayor a menor'),
  amountAsc('Monto: menor a mayor');

  const ExpenseSort(this.label);

  final String label;
}

class ExpenseFilters {
  const ExpenseFilters({
    this.category,
    this.from,
    this.to,
    this.query = '',
    this.sort = ExpenseSort.dateDesc,
  });

  final ExpenseCategory? category;
  final DateTime? from;
  final DateTime? to;
  final String query;
  final ExpenseSort sort;

  bool get hasActiveFilters =>
      category != null ||
      from != null ||
      to != null ||
      query.trim().isNotEmpty;

  ExpenseFilters copyWith({
    ExpenseCategory? category,
    bool clearCategory = false,
    DateTime? from,
    DateTime? to,
    bool clearRange = false,
    String? query,
    ExpenseSort? sort,
  }) {
    return ExpenseFilters(
      category: clearCategory ? null : (category ?? this.category),
      from: clearRange ? null : (from ?? this.from),
      to: clearRange ? null : (to ?? this.to),
      query: query ?? this.query,
      sort: sort ?? this.sort,
    );
  }
}
