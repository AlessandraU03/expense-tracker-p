import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_avatar.dart';
import 'package:tracker/features/expenses/presentation/widgets/expense/delete_expense.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';
import 'package:tracker/shared/utils/date_formatter.dart';
import 'package:tracker/shared/widgets/empty_view.dart';
import 'package:tracker/shared/widgets/hero_header.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(expenseByIdProvider(expenseId));

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(
          icon: Icons.search_off,
          title: 'Gasto no encontrado',
          message: 'Es posible que ya haya sido eliminado.',
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onInverseSurface;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          HeroHeader(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: BackButton(color: onHero),
                ),
                const SizedBox(height: 8),
                Hero(
                  tag: 'expense-avatar-${expense.id}',
                  child: CategoryAvatar(category: expense.category, size: 84),
                ),
                const SizedBox(height: 20),
                Text(
                  formatCents(expense.amountInCents),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: onHero,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  expense.concept,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: onHero.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.brightness == Brightness.light
                        ? scheme.onInverseSurface
                        : scheme.tertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    expense.category.label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.brightness == Brightness.light
                          ? scheme.tertiary
                          : scheme.onTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Material(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'Categoría',
                              value: expense.category.label,
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Fecha',
                              value: formatDate(expense.date),
                            ),
                            const Divider(),
                            _InfoRow(
                              label: 'Monto',
                              value: formatCents(expense.amountInCents),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ExpenseFormScreen(expenseId: expense.id),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.error,
                              side: BorderSide(color: scheme.error, width: 1.5),
                            ),
                            onPressed: () async {
                              final deleted = await confirmAndDeleteExpense(
                                context,
                                ref,
                                expense,
                              );
                              if (deleted && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Eliminar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
