import 'package:tracker/features/expenses/domain/entities/expense_category.dart';

class Expense {
  const Expense({
    required this.id,
    required this.concept,
    required this.amountInCents,
    required this.category,
    required this.date,
    this.createdAtMs = 0,
  });

  final String id;
  final String concept;
  final int amountInCents;
  final ExpenseCategory category;
  final DateTime date;
  final int createdAtMs;

  Expense copyWith({
    String? id,
    String? concept,
    int? amountInCents,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      concept: concept ?? this.concept,
      amountInCents: amountInCents ?? this.amountInCents,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAtMs: createdAtMs,
    );
  }
}
