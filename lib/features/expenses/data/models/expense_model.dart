import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.concept,
    required this.amountInCents,
    required this.category,
    required this.date,
    this.createdAtMs = 0,
  });

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      concept: expense.concept,
      amountInCents: expense.amountInCents,
      category: expense.category.storageValue,
      date: toIsoDate(expense.date),
      createdAtMs: expense.createdAtMs,
    );
  }

  factory ExpenseModel.fromMap(Map<String, Object?> map) {
    return ExpenseModel(
      id: map['id'] as String,
      concept: map['concept'] as String,
      amountInCents: map['amount_cents'] as int,
      category: map['category'] as String,
      date: map['date'] as String,
      createdAtMs: (map['created_at'] as int?) ?? 0,
    );
  }

  final String id;
  final String concept;
  final int amountInCents;
  final String category;
  final String date;
  final int createdAtMs;

  Map<String, Object?> toMap() => {
        'id': id,
        'concept': concept,
        'amount_cents': amountInCents,
        'category': category,
        'date': date,
        'created_at': createdAtMs,
      };

  Expense toEntity() {
    return Expense(
      id: id,
      concept: concept,
      amountInCents: amountInCents,
      category: ExpenseCategory.fromStorage(category),
      date: fromIsoDate(date),
      createdAtMs: createdAtMs,
    );
  }
}
