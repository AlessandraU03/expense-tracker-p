import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:tracker/features/expenses/presentation/providers/summary_provider.dart';
import 'package:tracker/features/expenses/presentation/screens/expense_form_screen.dart';
import 'package:tracker/features/expenses/presentation/widgets/filters/active_filters.dart';
import 'package:tracker/features/expenses/presentation/widgets/expense/expenses_body.dart';
import 'package:tracker/features/expenses/presentation/widgets/filters/movements_bar.dart';
import 'package:tracker/features/expenses/presentation/widgets/summary/summary_header.dart';


class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  static const double wideBreakpoint = 800;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nuevo gasto',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ExpenseFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= wideBreakpoint;
          return isWide ? const _WideLayout() : const _NarrowLayout();
        },
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filtersProvider);
    final summary = ref.watch(summaryProvider);

    return SummaryHeader(summary: summary, isFiltered: filters.hasActiveFilters);
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: const [
        _Header(),
        MovementsBar(),
        ActiveFilters(),
        ExpensesBody(shrinkWrap: true),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: const [
              _Header(),
              MovementsBar(),
              ActiveFilters(),
            ],
          ),
        ),
        const Expanded(
          child: SafeArea(child: ExpensesBody(shrinkWrap: false)),
        ),
      ],
    );
  }
}
