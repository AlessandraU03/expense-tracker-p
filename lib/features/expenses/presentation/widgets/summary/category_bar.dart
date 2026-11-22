import 'package:flutter/material.dart';
import 'package:tracker/features/expenses/domain/entities/expense_summary.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_style.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key, required this.summary, required this.trackColor});

  final ExpenseSummary summary;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    final entries = summary.byCategory.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Semantics(
      label: 'Proporción del gasto por categoría',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          height: 8,
          child: entries.isEmpty
              ? ColoredBox(color: trackColor.withValues(alpha: 0.15))
              : Row(
                  children: [
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: entries[i].value,
                        child: ColoredBox(color: entries[i].key.color),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
