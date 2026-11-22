import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/domain/entities/expense_filters.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/core/di/injection_container.dart';
import 'package:tracker/features/expenses/presentation/providers/summary_provider.dart';

import '../../helpers/fake_expense_repository.dart';

void main() {
  late FakeExpenseRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeExpenseRepository(sampleExpenses());
    container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  Expense newExpense({DateTime? date, int cents = 10000}) => Expense(
        id: 'new',
        concept: 'Nuevo',
        amountInCents: cents,
        category: ExpenseCategory.compras,
        date: date ?? pastDate(0),
      );

  test('carga los gastos del repositorio', () async {
    final expenses = await container.read(expensesProvider.future);
    expect(expenses, hasLength(4));
  });

  test('una fecha futura se rechaza y la lista no cambia', () async {
    await container.read(expensesProvider.future);
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    await expectLater(
      container.read(expensesProvider.notifier).add(newExpense(date: tomorrow)),
      throwsA(isA<FutureDateException>()),
    );

    expect(container.read(expensesProvider).value, hasLength(4));
    expect(repository.items, hasLength(4));
  });

  test('editar a una fecha futura también se rechaza', () async {
    final expenses = await container.read(expensesProvider.future);
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    await expectLater(
      container
          .read(expensesProvider.notifier)
          .edit(expenses.first.copyWith(date: tomorrow)),
      throwsA(isA<FutureDateException>()),
    );
  });

  test('crear, editar y eliminar actualizan la lista y el resumen', () async {
    await container.read(expensesProvider.future);
    final notifier = container.read(expensesProvider.notifier);
    final totalBefore = container.read(summaryProvider).totalInCents;

    await notifier.add(newExpense(cents: 10000));
    expect(container.read(expensesProvider).value, hasLength(5));
    expect(container.read(summaryProvider).totalInCents, totalBefore + 10000);

    await notifier.edit(newExpense(cents: 25000));
    expect(container.read(summaryProvider).totalInCents, totalBefore + 25000);
    expect(container.read(expenseByIdProvider('new'))?.amountInCents, 25000);

    await notifier.remove('new');
    expect(container.read(expensesProvider).value, hasLength(4));
    expect(container.read(summaryProvider).totalInCents, totalBefore);
    expect(container.read(expenseByIdProvider('new')), isNull);
  });

  test('el resumen refleja la lista filtrada', () async {
    await container.read(expensesProvider.future);

    container
        .read(filtersProvider.notifier)
        .setCategory(ExpenseCategory.transporte);

    final summary = container.read(summaryProvider);
    expect(summary.count, 2);
    expect(summary.totalInCents, 60000 + 18500);
    expect(summary.topCategory, ExpenseCategory.transporte);
  });

  test('cambiar el orden no altera el resumen', () async {
    await container.read(expensesProvider.future);
    final before = container.read(summaryProvider).totalInCents;

    container.read(filtersProvider.notifier).setSort(ExpenseSort.amountAsc);

    expect(container.read(summaryProvider).totalInCents, before);
  });

  test('un fallo de lectura deja el estado en error', () async {
    repository.failOnGetAll = true;

    await expectLater(
      container.read(expensesProvider.future),
      throwsA(isA<StorageException>()),
    );
    expect(container.read(expensesProvider).hasError, isTrue);
  });

  test('un gasto eliminado no se encuentra por id', () async {
    await container.read(expensesProvider.future);
    await container.read(expensesProvider.notifier).remove('a');
    expect(container.read(expenseByIdProvider('a')), isNull);
  });
}
