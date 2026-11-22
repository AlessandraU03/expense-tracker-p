import 'package:tracker/features/expenses/domain/entities/expense.dart';


abstract interface class ExpenseRepository {
  Future<List<Expense>> getAll();
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
}
