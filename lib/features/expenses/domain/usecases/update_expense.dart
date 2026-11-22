import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:tracker/features/expenses/domain/usecases/validate_expense.dart';

class UpdateExpense {
  const UpdateExpense(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(Expense expense) async {
    validateExpense(expense);
    await _repository.update(expense);
  }
}
