import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/usecases/calculate_summary.dart';

void main() {
  Expense e(String id, int cents, ExpenseCategory category) {
    return Expense(
      id: id,
      concept: 'Gasto $id',
      amountInCents: cents,
      category: category,
      date: DateTime(2026, 11, 1),
    );
  }

  group('ExpenseSummary', () {
    test('lista vacía: total 0, cantidad 0 y sin categoría top', () {
      final summary = calculateSummary(const []);
      expect(summary.totalInCents, 0);
      expect(summary.count, 0);
      expect(summary.topCategory, isNull);
    });

    test('suma exacta en centavos (sin errores de redondeo)', () {
      // Con double, 0.10 + 0.20 da 0.30000000000000004. Con centavos es exacto.
      final summary = calculateSummary([
        e('1', 10, ExpenseCategory.otros),
        e('2', 20, ExpenseCategory.otros),
      ]);
      expect(summary.totalInCents, 30);
    });

    test('la categoría top es la de mayor gasto acumulado, no la más frecuente', () {
      final summary = calculateSummary([
        e('1', 1000, ExpenseCategory.alimentacion),
        e('2', 1000, ExpenseCategory.alimentacion),
        e('3', 5000, ExpenseCategory.transporte),
      ]);
      expect(summary.count, 3);
      expect(summary.topCategory, ExpenseCategory.transporte);
      expect(summary.topCategoryInCents, 5000);
    });

    test('un empate se resuelve siempre igual (orden del enum)', () {
      final summary = calculateSummary([
        e('1', 1000, ExpenseCategory.transporte),
        e('2', 1000, ExpenseCategory.alimentacion),
      ]);
      expect(summary.topCategory, ExpenseCategory.alimentacion);
    });
  });
}
