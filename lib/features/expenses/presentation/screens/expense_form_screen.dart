import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/features/expenses/presentation/widgets/form/amount_field.dart';
import 'package:tracker/features/expenses/presentation/widgets/form/category_field.dart';
import 'package:tracker/features/expenses/presentation/widgets/form/date_field.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';
import 'package:tracker/shared/utils/date_formatter.dart';
import 'package:tracker/shared/widgets/hero_header.dart';


class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.expenseId});

  final String? expenseId;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conceptController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory? _category;
  late DateTime _date;
  Expense? _original;
  bool _saving = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _date = dateOnly(DateTime.now());

    final id = widget.expenseId;
    if (id != null) {
      _original = ref.read(expenseByIdProvider(id));
      final original = _original;
      if (original != null) {
        _conceptController.text = original.concept;
        _amountController.text = centsToInput(original.amountInCents);
        _category = original.category;
        _date = dateOnly(original.date);
      }
    }
  }

  @override
  void dispose() {
    _conceptController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: dateOnly(DateTime.now()),
      helpText: 'Fecha del gasto',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cents = parseAmountToCents(_amountController.text)!;
    final notifier = ref.read(expensesProvider.notifier);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final original = _original;
    final expense = original != null
        ? original.copyWith(
            concept: _conceptController.text.trim(),
            amountInCents: cents,
            category: _category,
            date: _date,
          )
        : Expense(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            concept: _conceptController.text.trim(),
            amountInCents: cents,
            category: _category!,
            date: _date,
            createdAtMs: DateTime.now().millisecondsSinceEpoch,
          );

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await notifier.edit(expense);
      } else {
        await notifier.add(expense);
      }
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Gasto actualizado' : 'Gasto guardado'),
        ),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && _original == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar gasto')),
        body: const Center(child: Text('Este gasto ya no existe.')),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onInverseSurface;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            HeroHeader(
              padding: const EdgeInsets.fromLTRB(12, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BackButton(color: onHero),
                      const SizedBox(width: 4),
                      Text(
                        _isEditing ? 'Editar gasto' : 'Nuevo gasto',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: AmountField(
                      controller: _amountController,
                      color: onHero,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _conceptController,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        maxLength: 60,
                        decoration: const InputDecoration(
                          labelText: 'Concepto',
                          counterText: '',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Escribe un concepto.'
                                : null,
                      ),
                      const SizedBox(height: 24),
                      CategoryField(
                        value: _category,
                        onChanged: (category) =>
                            setState(() => _category = category),
                      ),
                      const SizedBox(height: 24),
                      DateField(date: _date, onTap: _pickDate),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: scheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  _isEditing ? 'Guardar cambios' : 'Guardar',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
