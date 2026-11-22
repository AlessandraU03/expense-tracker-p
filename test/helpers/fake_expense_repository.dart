import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/repositories/expense_repository.dart';

/// Repositorio en memoria para los tests. Se inyecta con
/// `expenseRepositoryProvider.overrideWithValue(...)`.
class FakeExpenseRepository implements ExpenseRepository {
  FakeExpenseRepository([List<Expense> initial = const []])
      : items = [...initial];

  final List<Expense> items;

  /// Si es true, `getAll` lanza una [StorageException] (para probar el estado de error).
  bool failOnGetAll = false;

  @override
  Future<List<Expense>> getAll() async {
    if (failOnGetAll) {
      throw const StorageException('No se pudieron cargar los gastos.');
    }
    return [...items];
  }

  @override
  Future<void> add(Expense expense) async => items.add(expense);

  @override
  Future<void> update(Expense expense) async {
    final index = items.indexWhere((item) => item.id == expense.id);
    if (index == -1) throw const ExpenseNotFoundException();
    items[index] = expense;
  }

  @override
  Future<void> delete(String id) async {
    items.removeWhere((item) => item.id == id);
  }
}

/// Fecha segura (siempre en el pasado) para no depender del día en que corre el test.
DateTime pastDate(int daysAgo) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).subtract(Duration(days: daysAgo));
}

/// Datos de ejemplo con montos distintos para probar filtros, orden y resumen.
List<Expense> sampleExpenses() => [
      Expense(
        id: 'a',
        concept: 'Supermercado',
        amountInCents: 85050,
        category: ExpenseCategory.alimentacion,
        date: pastDate(10),
      ),
      Expense(
        id: 'b',
        concept: 'Gasolina',
        amountInCents: 60000,
        category: ExpenseCategory.transporte,
        date: pastDate(6),
      ),
      Expense(
        id: 'c',
        concept: 'Taxi',
        amountInCents: 18500,
        category: ExpenseCategory.transporte,
        date: pastDate(2),
      ),
      Expense(
        id: 'd',
        concept: 'Cine',
        amountInCents: 24000,
        category: ExpenseCategory.entretenimiento,
        date: pastDate(1),
      ),
    ];
