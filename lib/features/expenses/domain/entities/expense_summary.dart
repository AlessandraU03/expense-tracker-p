import 'package:tracker/features/expenses/domain/entities/expense_category.dart';

class ExpenseSummary {
  const ExpenseSummary({
    required this.totalInCents,
    required this.count,
    this.topCategory,
    this.topCategoryInCents = 0,
    this.byCategory = const {},
  });

  final int totalInCents;
  final int count;
  final ExpenseCategory? topCategory;
  final int topCategoryInCents;

  final Map<ExpenseCategory, int> byCategory;
}
