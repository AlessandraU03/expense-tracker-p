import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/entities/expense_filters.dart';

class FiltersNotifier extends Notifier<ExpenseFilters> {
  @override
  ExpenseFilters build() => const ExpenseFilters();

  void setCategory(ExpenseCategory? category) {
    state = category == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: category);
  }

  void setRange(DateTime from, DateTime to) {
    state = state.copyWith(from: from, to: to);
  }

  void clearRange() => state = state.copyWith(clearRange: true);

  void setQuery(String query) => state = state.copyWith(query: query);

  void setSort(ExpenseSort sort) => state = state.copyWith(sort: sort);

  void clearAll() => state = ExpenseFilters(sort: state.sort);
}

final filtersProvider =
    NotifierProvider<FiltersNotifier, ExpenseFilters>(FiltersNotifier.new);
