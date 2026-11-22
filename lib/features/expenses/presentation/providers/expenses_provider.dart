import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/di/injection_container.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';

class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() {
    return ref.watch(expenseRepositoryProvider).getAll();
  }

  List<Expense> get _current => state.valueOrNull ?? const <Expense>[];

  Future<void> add(Expense expense) async {
    await ref.read(addExpenseProvider)(expense);
    state = AsyncData([..._current, expense]);
  }

  Future<void> edit(Expense expense) async {
    await ref.read(updateExpenseProvider)(expense);
    state = AsyncData([
      for (final item in _current) item.id == expense.id ? expense : item,
    ]);
  }

  Future<void> remove(String id) async {
    await ref.read(expenseRepositoryProvider).delete(id);
    state = AsyncData([
      for (final item in _current)
        if (item.id != id) item,
    ]);
  }
}

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);

final expenseByIdProvider = Provider.family<Expense?, String>((ref, id) {
  final expenses = ref.watch(expensesProvider).valueOrNull ?? const <Expense>[];
  for (final expense in expenses) {
    if (expense.id == id) return expense;
  }
  return null;
});
