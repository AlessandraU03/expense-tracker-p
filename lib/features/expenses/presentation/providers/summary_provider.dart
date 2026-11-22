import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_summary.dart';
import 'package:tracker/features/expenses/domain/usecases/calculate_summary.dart';
import 'package:tracker/features/expenses/domain/usecases/apply_filters.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';

final filteredExpensesProvider = Provider<AsyncValue<List<Expense>>>((ref) {
  final filters = ref.watch(filtersProvider);
  return ref
      .watch(expensesProvider)
      .whenData((expenses) => applyFilters(expenses, filters));
});

final summaryProvider = Provider<ExpenseSummary>((ref) {
  final visible =
      ref.watch(filteredExpensesProvider).valueOrNull ?? const <Expense>[];
  return calculateSummary(visible);
});
