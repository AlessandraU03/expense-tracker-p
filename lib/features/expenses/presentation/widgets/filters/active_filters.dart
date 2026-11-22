import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

class ActiveFilters extends ConsumerWidget {
  const ActiveFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    final notifier = ref.read(filtersProvider.notifier);

    final category = filters.category;
    final from = filters.from;

    if (category == null && from == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (category != null)
            InputChip(
              label: Text(category.label),
              onDeleted: () => notifier.setCategory(null),
              deleteButtonTooltipMessage: 'Quitar categoría',
            ),
          if (from != null)
            InputChip(
              label: Text(
                '${formatDate(from)} – ${formatDate(filters.to ?? from)}',
              ),
              onDeleted: notifier.clearRange,
              deleteButtonTooltipMessage: 'Quitar fechas',
            ),
        ],
      ),
    );
  }
}
