import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

void validateExpense(Expense expense, {DateTime? now}) {
  if (expense.concept.trim().isEmpty) {
    throw const ValidationException('El concepto es obligatorio.');
  }
  if (expense.amountInCents <= 0) {
    throw const ValidationException('El monto debe ser mayor a 0.');
  }

  final today = dateOnly(now ?? DateTime.now());
  if (dateOnly(expense.date).isAfter(today)) {
    throw const FutureDateException();
  }
}
