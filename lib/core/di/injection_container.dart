import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/features/expenses/di/expense_di.dart';
import 'package:tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:tracker/features/expenses/domain/usecases/add_expense.dart';
import 'package:tracker/features/expenses/domain/usecases/update_expense.dart';


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider debe sobrescribirse en ProviderScope.',
  );
});

// ---- Feature: gastos ----

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseDI.provideRepository(),
);

final addExpenseProvider = Provider<AddExpense>(
  (ref) => ExpenseDI.provideAddExpense(ref.watch(expenseRepositoryProvider)),
);

final updateExpenseProvider = Provider<UpdateExpense>(
  (ref) => ExpenseDI.provideUpdateExpense(ref.watch(expenseRepositoryProvider)),
);
