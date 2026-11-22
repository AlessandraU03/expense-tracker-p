import 'package:flutter/material.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_avatar.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';
import 'package:tracker/shared/utils/day_label.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onTap,
    this.showDate = false,
  });

  final Expense expense;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final subtitle = showDate
        ? '${expense.category.label} · ${formatShortDate(expense.date)}'
        : expense.category.label;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Hero(
              tag: 'expense-avatar-${expense.id}',
              child: CategoryAvatar(category: expense.category),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.concept,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatCents(expense.amountInCents),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
