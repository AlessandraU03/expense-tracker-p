import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:tracker/core/di/injection_container.dart';
import 'package:tracker/features/expenses/presentation/screens/expense_form_screen.dart';

import '../../helpers/fake_expense_repository.dart';

void main() {
  /// Abre el formulario con `Navigator.push` desde una pantalla de inicio,
  /// igual que en la app real, para que `Navigator.pop` tenga a dónde volver.
  Future<ProviderContainer> openForm(
    WidgetTester tester,
    FakeExpenseRepository repository, {
    String? expenseId,
  }) async {
    tester.view.physicalSize = const Size(700, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // El formulario de edición lee el gasto del provider, así que se precarga.
    await container.read(expensesProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExpenseFormScreen(expenseId: expenseId),
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Concepto'),
      'Café con amigos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Monto'),
      '125.50',
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Alimentación'));
    await tester.pumpAndSettle();
  }

  testWidgets('con los campos vacíos muestra los errores de validación',
      (tester) async {
    final repository = FakeExpenseRepository();
    await openForm(tester, repository);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un concepto.'), findsOneWidget);
    expect(find.text('Escribe un monto válido (ej. 125.50).'), findsOneWidget);
    expect(find.text('Elige una categoría.'), findsOneWidget);
    expect(repository.items, isEmpty);
  });

  testWidgets('un monto de 0 se rechaza', (tester) async {
    final repository = FakeExpenseRepository();
    await openForm(tester, repository);

    await fillValidForm(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '0');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('El monto debe ser mayor a 0.'), findsOneWidget);
    expect(repository.items, isEmpty);
  });

  testWidgets('un monto con texto se rechaza', (tester) async {
    final repository = FakeExpenseRepository();
    await openForm(tester, repository);

    await fillValidForm(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), 'abc');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Escribe un monto válido (ej. 125.50).'), findsOneWidget);
    expect(repository.items, isEmpty);
  });

  testWidgets('un formulario válido guarda el gasto en centavos y cierra',
      (tester) async {
    final repository = FakeExpenseRepository();
    final container = await openForm(tester, repository);

    await fillValidForm(tester);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(repository.items, hasLength(1));
    final saved = repository.items.single;
    expect(saved.concept, 'Café con amigos');
    expect(saved.amountInCents, 12550);
    expect(saved.category, ExpenseCategory.alimentacion);
    expect(container.read(expensesProvider).value, hasLength(1));

    // Volvió a la pantalla anterior y avisó con un SnackBar.
    expect(find.byType(ExpenseFormScreen), findsNothing);
    expect(find.text('Gasto guardado'), findsOneWidget);
  });

  testWidgets('editar precarga los datos y guarda los cambios', (tester) async {
    final repository = FakeExpenseRepository(sampleExpenses());
    final container = await openForm(tester, repository, expenseId: 'a');

    expect(find.text('Editar gasto'), findsOneWidget);
    expect(find.text('Supermercado'), findsOneWidget);
    expect(find.text('850.50'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Monto'), '900');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repository.items.firstWhere((e) => e.id == 'a').amountInCents, 90000);
    expect(container.read(expenseByIdProvider('a'))?.amountInCents, 90000);
    expect(find.text('Gasto actualizado'), findsOneWidget);
  });

  testWidgets('el selector de fecha no permite elegir días futuros',
      (tester) async {
    await openForm(tester, FakeExpenseRepository());

    await tester.tap(find.byIcon(Icons.event_outlined));
    await tester.pumpAndSettle();

    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(picker.lastDate, today);
  });
}
