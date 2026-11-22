import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/usecases/validate_expense.dart';

void main() {
  // "Hoy" fijo, a media mañana, para que el test no dependa del reloj.
  final now = DateTime(2026, 11, 22, 8, 30);

  Expense build({
    String concept = 'Café',
    int cents = 5000,
    DateTime? date,
  }) {
    return Expense(
      id: '1',
      concept: concept,
      amountInCents: cents,
      category: ExpenseCategory.alimentacion,
      date: date ?? DateTime(2026, 11, 20),
    );
  }

  group('validateExpense', () {
    test('acepta un gasto válido', () {
      expect(() => validateExpense(build(), now: now), returnsNormally);
    });

    test('rechaza una fecha futura con FutureDateException', () {
      final tomorrow = DateTime(2026, 11, 23);
      expect(
        () => validateExpense(build(date: tomorrow), now: now),
        throwsA(isA<FutureDateException>()),
      );
    });

    test('acepta hoy aunque la hora del gasto sea posterior a la actual', () {
      // Se compara solo la fecha: hoy a las 23:59 sigue siendo hoy.
      final laterToday = DateTime(2026, 11, 22, 23, 59);
      expect(
        () => validateExpense(build(date: laterToday), now: now),
        returnsNormally,
      );
    });

    test('acepta ayer', () {
      expect(
        () => validateExpense(build(date: DateTime(2026, 11, 21)), now: now),
        returnsNormally,
      );
    });

    test('rechaza un concepto vacío o con solo espacios', () {
      expect(
        () => validateExpense(build(concept: '   '), now: now),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rechaza un monto de 0 o negativo', () {
      expect(
        () => validateExpense(build(cents: 0), now: now),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => validateExpense(build(cents: -100), now: now),
        throwsA(isA<ValidationException>()),
      );
    });

    test('el mensaje de fecha futura es claro', () {
      const error = FutureDateException();
      expect(error.message, contains('fecha futura'));
    });
  });
}
