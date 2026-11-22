import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/presentation/screens/expense_detail_screen.dart';
import 'package:tracker/features/expenses/presentation/widgets/expense/delete_expense.dart';
import 'package:tracker/features/expenses/presentation/widgets/expense/expense_tile.dart';

class ExpenseCard extends ConsumerWidget {
  const ExpenseCard({super.key, required this.expenses, required this.showDate});

  final List<Expense> expenses;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < expenses.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 74, endIndent: 16),
              _SwipeToDeleteRow(expense: expenses[i], showDate: showDate),
            ],
          ],
        ),
      ),
    );
  }
}

class _SwipeToDeleteRow extends ConsumerWidget {
  const _SwipeToDeleteRow({required this.expense, required this.showDate});

  final Expense expense;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: const _DeleteBackground(),
      confirmDismiss: (_) async {
        await confirmAndDeleteExpense(context, ref, expense);
        return false;
      },
      child: ExpenseTile(
        expense: expense,
        showDate: showDate,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ExpenseDetailScreen(expenseId: expense.id),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}
