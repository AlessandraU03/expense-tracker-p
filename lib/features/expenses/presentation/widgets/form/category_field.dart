import 'package:flutter/material.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_avatar.dart';

class CategoryField extends StatelessWidget {
  const CategoryField({super.key, required this.value, required this.onChanged});

  final ExpenseCategory? value;
  final ValueChanged<ExpenseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FormField<ExpenseCategory>(
      initialValue: value,
      validator: (selected) => selected == null ? 'Elige una categoría.' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoría',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in ExpenseCategory.values)
                ChoiceChip(
                  avatar: CategoryAvatar(category: category, size: 28),
                  label: Text(category.label),
                  selected: field.value == category,
                  onSelected: (_) {
                    field.didChange(category);
                    onChanged(category);
                  },
                ),
            ],
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                field.errorText!,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
