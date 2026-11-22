import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_avatar.dart';
import 'package:tracker/features/expenses/presentation/widgets/filters/filter_date_field.dart';
import 'package:tracker/shared/utils/date_formatter.dart';

Future<void> showFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FiltersSheet(),
  );
}

class _FiltersSheet extends ConsumerStatefulWidget {
  const _FiltersSheet();

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  ExpenseCategory? _category;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(filtersProvider);
    _category = filters.category;
    _from = filters.from;
    _to = filters.to;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final today = dateOnly(DateTime.now());
    final initial = (isFrom ? _from : _to) ?? today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: isFrom ? 'Desde' : 'Hasta',
    );

    if (picked == null) return;
    setState(() => isFrom ? _from = picked : _to = picked);
  }

  void _apply() {
    final notifier = ref.read(filtersProvider.notifier);
    notifier.setCategory(_category);

    var from = _from;
    var to = _to;
    if (from == null && to == null) {
      notifier.clearRange();
    } else {
      // Si solo se eligió un extremo, el rango es ese día.
      from ??= to;
      to ??= from;
      if (from!.isAfter(to!)) {
        final swap = from;
        from = to;
        to = swap;
      }
      notifier.setRange(from, to);
    }

    Navigator.pop(context);
  }

  void _clear() {
    final notifier = ref.read(filtersProvider.notifier);
    notifier.setCategory(null);
    notifier.clearRange();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        4,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
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
                FilterChip(
                  avatar: CategoryAvatar(category: category, size: 28),
                  label: Text(category.label),
                  selected: _category == category,
                  onSelected: (selected) =>
                      setState(() => _category = selected ? category : null),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Rango de fechas',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilterDateField(
                  label: 'Desde',
                  value: _from,
                  onTap: () => _pickDate(isFrom: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDateField(
                  label: 'Hasta',
                  value: _to,
                  onTap: () => _pickDate(isFrom: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: _clear,
                  child: const Text(
                    'Limpiar',
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: _apply,
                  child: const Text('Aplicar filtros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
