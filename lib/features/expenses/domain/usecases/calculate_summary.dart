import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/entities/expense_summary.dart';

ExpenseSummary calculateSummary(List<Expense> expenses) {
  var total = 0;
  final byCategory = <ExpenseCategory, int>{};

  for (final expense in expenses) {
    total += expense.amountInCents;
    byCategory[expense.category] =
        (byCategory[expense.category] ?? 0) + expense.amountInCents;
  }

  ExpenseCategory? top;
  var topAmount = 0;
  for (final category in ExpenseCategory.values) {
    final amount = byCategory[category] ?? 0;
    if (amount > topAmount) {
      top = category;
      topAmount = amount;
    }
  }

  return ExpenseSummary(
    totalInCents: total,
    count: expenses.length,
    topCategory: top,
    topCategoryInCents: topAmount,
    byCategory: byCategory,
  );
}
