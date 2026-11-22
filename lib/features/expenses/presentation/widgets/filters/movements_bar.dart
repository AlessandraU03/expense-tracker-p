import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/features/expenses/presentation/widgets/filters/filters_sheet.dart';

class MovementsBar extends ConsumerWidget {
  const MovementsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filters = ref.watch(filtersProvider);
    final activeCount =
        (filters.category != null ? 1 : 0) + (filters.from != null ? 1 : 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Movimientos',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
              backgroundColor:
                  activeCount > 0 ? scheme.tertiary : scheme.surfaceContainerLowest,
              foregroundColor:
                  activeCount > 0 ? scheme.onTertiary : scheme.onSurface,
              textStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            onPressed: () => showFiltersSheet(context),
            icon: const Icon(Icons.tune, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filtros'),
                if (activeCount > 0) ...[
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: scheme.onTertiary,
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
