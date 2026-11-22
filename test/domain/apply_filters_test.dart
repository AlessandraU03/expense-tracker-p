import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/entities/expense_filters.dart';
import 'package:tracker/features/expenses/domain/usecases/apply_filters.dart';

void main() {
  Expense e(String id, String concept, int cents, ExpenseCategory cat, int day) {
    return Expense(
      id: id,
      concept: concept,
      amountInCents: cents,
      category: cat,
      date: DateTime(2026, 11, day),
    );
  }

  final expenses = [
    e('a', 'Supermercado', 85050, ExpenseCategory.alimentacion, 2),
    e('b', 'Gasolina', 60000, ExpenseCategory.transporte, 5),
    e('c', 'Taxi', 18500, ExpenseCategory.transporte, 15),
    e('d', 'Cine', 24000, ExpenseCategory.entretenimiento, 8),
  ];

  List<String> ids(ExpenseFilters filters) =>
      applyFilters(expenses, filters).map((x) => x.id).toList();

  group('applyFilters', () {
    test('sin filtros devuelve todo, más recientes primero', () {
      expect(ids(const ExpenseFilters()), ['c', 'd', 'b', 'a']);
    });

    test('filtra por categoría', () {
      const filters = ExpenseFilters(category: ExpenseCategory.transporte);
      expect(ids(filters), ['c', 'b']);
    });

    test('filtra por rango de fechas, inclusivo en ambos extremos', () {
      final filters = ExpenseFilters(
        from: DateTime(2026, 11, 5),
        to: DateTime(2026, 11, 8),
      );
      expect(ids(filters), ['d', 'b']);
    });

    test('busca por concepto sin distinguir mayúsculas', () {
      expect(ids(const ExpenseFilters(query: 'TAX')), ['c']);
      expect(ids(const ExpenseFilters(query: '  gas  ')), ['b']);
    });

    test('combina categoría, fechas y búsqueda', () {
      final filters = ExpenseFilters(
        category: ExpenseCategory.transporte,
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 10),
        query: 'gas',
      );
      expect(ids(filters), ['b']);
    });

    test('si nada coincide devuelve una lista vacía', () {
      expect(ids(const ExpenseFilters(query: 'zzz')), isEmpty);
    });

    test('ordena por monto', () {
      expect(
        ids(const ExpenseFilters(sort: ExpenseSort.amountDesc)),
        ['a', 'b', 'd', 'c'],
      );
      expect(
        ids(const ExpenseFilters(sort: ExpenseSort.amountAsc)),
        ['c', 'd', 'b', 'a'],
      );
    });

    test('ordena por fecha ascendente', () {
      expect(
        ids(const ExpenseFilters(sort: ExpenseSort.dateAsc)),
        ['a', 'b', 'd', 'c'],
      );
    });

    test('hasActiveFilters ignora el orden', () {
      expect(const ExpenseFilters().hasActiveFilters, isFalse);
      expect(
        const ExpenseFilters(sort: ExpenseSort.amountAsc).hasActiveFilters,
        isFalse,
      );
      expect(const ExpenseFilters(query: 'a').hasActiveFilters, isTrue);
    });

    test('en un mismo día, el registrado más tarde va primero', () {
      final sameDay = [
        Expense(
          id: 'x1',
          concept: 'Comida',
          amountInCents: 100,
          category: ExpenseCategory.alimentacion,
          date: DateTime(2026, 11, 22),
          createdAtMs: 1000,
        ),
        Expense(
          id: 'x2',
          concept: 'Netflix',
          amountInCents: 100,
          category: ExpenseCategory.servicios,
          date: DateTime(2026, 11, 22),
          createdAtMs: 3000,
        ),
        Expense(
          id: 'x3',
          concept: 'Didi',
          amountInCents: 100,
          category: ExpenseCategory.transporte,
          date: DateTime(2026, 11, 22),
          createdAtMs: 2000,
        ),
      ];

      final result = applyFilters(sameDay, const ExpenseFilters());

      expect(result.map((x) => x.id), ['x2', 'x3', 'x1']);
    });
  });
}
