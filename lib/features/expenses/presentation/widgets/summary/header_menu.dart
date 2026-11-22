import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense_filters.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/shared/theme/theme_provider.dart';

class HeaderMenu extends ConsumerWidget {
  const HeaderMenu({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(filtersProvider.select((f) => f.sort));
    final mode = ref.watch(themeModeProvider);

    return PopupMenuButton<Object>(
      tooltip: 'Más opciones',
      icon: Icon(Icons.more_vert, color: color),
      onSelected: (value) {
        if (value is ExpenseSort) {
          ref.read(filtersProvider.notifier).setSort(value);
        } else if (value is ThemeMode) {
          ref.read(themeModeProvider.notifier).setMode(value);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<Object>(enabled: false, child: Text('Ordenar por')),
        for (final option in ExpenseSort.values)
          CheckedPopupMenuItem<Object>(
            value: option,
            checked: option == sort,
            child: Text(option.label),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<Object>(enabled: false, child: Text('Tema')),
        CheckedPopupMenuItem<Object>(
          value: ThemeMode.system,
          checked: mode == ThemeMode.system,
          child: const Text('Automático'),
        ),
        CheckedPopupMenuItem<Object>(
          value: ThemeMode.light,
          checked: mode == ThemeMode.light,
          child: const Text('Claro'),
        ),
        CheckedPopupMenuItem<Object>(
          value: ThemeMode.dark,
          checked: mode == ThemeMode.dark,
          child: const Text('Oscuro'),
        ),
      ],
    );
  }
}
