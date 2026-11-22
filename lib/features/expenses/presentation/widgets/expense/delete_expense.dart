import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';

Future<bool> confirmAndDeleteExpense(
  BuildContext context,
  WidgetRef ref,
  Expense expense,
) async {

  final messenger = ScaffoldMessenger.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return AlertDialog(
        title: const Text('Eliminar gasto'),
        content: Text(
          '¿Eliminar "${expense.concept}" por '
          '${formatCents(expense.amountInCents)}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return false;

  try {
    await ref.read(expensesProvider.notifier).remove(expense.id);
    messenger.showSnackBar(const SnackBar(content: Text('Gasto eliminado')));
    return true;
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text(userMessage(error))));
    return false;
  }
}
