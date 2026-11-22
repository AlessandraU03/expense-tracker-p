import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/domain/entities/expense_summary.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/features/expenses/presentation/widgets/summary/category_bar.dart';
import 'package:tracker/features/expenses/presentation/widgets/summary/header_menu.dart';
import 'package:tracker/features/expenses/presentation/widgets/summary/summary_stat.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';
import 'package:tracker/shared/widgets/hero_header.dart';

class SummaryHeader extends ConsumerStatefulWidget {
  const SummaryHeader({
    super.key,
    required this.summary,
    required this.isFiltered,
  });

  final ExpenseSummary summary;

  final bool isFiltered;

  @override
  ConsumerState<SummaryHeader> createState() => _SummaryHeaderState();
}

class _SummaryHeaderState extends ConsumerState<SummaryHeader> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(filtersProvider).query;
    _searching = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(filtersProvider.notifier).setQuery(value);
    });
  }

  void _closeSearch() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(filtersProvider.notifier).setQuery('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onInverseSurface;
    final mutedOnHero = onHero.withValues(alpha: 0.7);
    final summary = widget.summary;

    // Si los filtros se limpian desde fuera ("Limpiar filtros"), el campo de
    // búsqueda se vacía también.
    ref.listen<String>(filtersProvider.select((f) => f.query), (_, next) {
      if (_controller.text != next) _controller.text = next;
    });

    return HeroHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 48,
            child: _searching
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          onChanged: _onQueryChanged,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: onHero),
                          cursorColor: onHero,
                          decoration: InputDecoration(
                            hintText: 'Buscar por concepto',
                            hintStyle: TextStyle(color: mutedOnHero),
                            fillColor: onHero.withValues(alpha: 0.12),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar búsqueda',
                        color: onHero,
                        icon: const Icon(Icons.close),
                        onPressed: _closeSearch,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        'Gastos',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Buscar',
                        color: onHero,
                        icon: const Icon(Icons.search),
                        onPressed: () => setState(() => _searching = true),
                      ),
                      HeaderMenu(color: onHero),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isFiltered ? 'Total filtrado' : 'Total gastado',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedOnHero),
          ),
          const SizedBox(height: 2),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: summary.totalInCents.toDouble()),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) => Text(
              formatCents(value.round()),
              style: theme.textTheme.displayMedium?.copyWith(
                color: onHero,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryStat(
                label: 'Movimientos',
                value: '${summary.count}',
                color: onHero,
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: onHero.withValues(alpha: 0.2),
              ),
              Expanded(
                child: SummaryStat(
                  label: 'Mayor gasto',
                  value: summary.topCategory == null
                      ? '—'
                      : '${summary.topCategory!.label} · '
                          '${formatCents(summary.topCategoryInCents)}',
                  color: onHero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CategoryBar(summary: summary, trackColor: onHero),
        ],
      ),
    );
  }
}
