import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/features/expenses/presentation/providers/summary_provider.dart';
import 'package:tracker/features/expenses/presentation/widgets/expense/expense_card.dart';
import 'package:tracker/shared/widgets/empty_view.dart';
import 'package:tracker/shared/widgets/error_view.dart';

class ExpensesBody extends ConsumerWidget {
  const ExpensesBody({super.key, required this.shrinkWrap});

  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleAsync = ref.watch(filteredExpensesProvider);
    final hasFilters = ref.watch(filtersProvider).hasActiveFilters;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (visibleAsync) {
        AsyncValue(isLoading: true, hasValue: false) => _Sized(
            key: const ValueKey('loading'),
            shrinkWrap: shrinkWrap,
            child: const Center(child: CircularProgressIndicator()),
          ),
        AsyncError(:final error) => _Sized(
            key: const ValueKey('error'),
            shrinkWrap: shrinkWrap,
            child: ErrorView(
              message: userMessage(error),
              onRetry: () => ref.invalidate(expensesProvider),
            ),
          ),
        AsyncValue(:final value?) when value.isEmpty => _Sized(
            key: ValueKey(hasFilters ? 'empty-filtered' : 'empty'),
            shrinkWrap: shrinkWrap,
            child: hasFilters
                ? EmptyView(
                    icon: Icons.search_off,
                    title: 'Sin resultados',
                    message: 'Ningún gasto coincide con los filtros actuales.',
                    actionLabel: 'Limpiar filtros',
                    onAction: ref.read(filtersProvider.notifier).clearAll,
                  )
                : const EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aún no hay gastos',
                    message: 'Registra tu primer gasto con el botón de abajo.',
                  ),
          ),
        AsyncValue(:final value?) => _ExpenseList(
            key: const ValueKey('list'),
            expenses: value,
            shrinkWrap: shrinkWrap,
          ),
        _ => const SizedBox.shrink(key: ValueKey('none')),
      },
    );
  }
}

class _Sized extends StatelessWidget {
  const _Sized({super.key, required this.shrinkWrap, required this.child});

  final bool shrinkWrap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!shrinkWrap) return child;
    return SizedBox(height: 320, child: child);
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    super.key,
    required this.expenses,
    required this.shrinkWrap,
  });

  final List<Expense> expenses;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final card = Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ExpenseCard(expenses: expenses, showDate: true),
    );

    if (shrinkWrap) return card;

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 100),
      children: [card],
    );
  }
}
