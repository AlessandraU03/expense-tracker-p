import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker/core/di/injection_container.dart';
import 'package:tracker/features/expenses/presentation/screens/expense_list_screen.dart';
import 'package:tracker/shared/utils/currency_formatter.dart';

import '../../helpers/fake_expense_repository.dart';

void main() {
  Future<void> pumpList(
    WidgetTester tester,
    FakeExpenseRepository repository,
  ) async {
    // Pantalla de teléfono (< 800 px de ancho) y alta para que todo se construya.
    tester.view.physicalSize = const Size(700, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(repository),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MaterialApp(home: ExpenseListScreen()),
      ),
    );
  }

  /// Desliza una fila hacia la izquierda, como lo haría el usuario para eliminarla.
  Future<void> swipeToDelete(WidgetTester tester, String concept) async {
    await tester.drag(find.text(concept), const Offset(-600, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra el indicador de carga y luego los datos', (tester) async {
    await pumpList(tester, FakeExpenseRepository(sampleExpenses()));

    // Primer frame: el Future del repositorio aún no se resuelve.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Supermercado'), findsOneWidget);
    expect(find.text('Gasolina'), findsOneWidget);
  });

  testWidgets('sin gastos muestra la vista vacía', (tester) async {
    await pumpList(tester, FakeExpenseRepository());
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay gastos'), findsOneWidget);
  });

  testWidgets('si falla la lectura muestra el error y permite reintentar',
      (tester) async {
    final repository = FakeExpenseRepository(sampleExpenses())
      ..failOnGetAll = true;
    await pumpList(tester, repository);
    await tester.pumpAndSettle();

    expect(find.text('Algo salió mal'), findsOneWidget);
    expect(find.text('No se pudieron cargar los gastos.'), findsOneWidget);

    repository.failOnGetAll = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Algo salió mal'), findsNothing);
    expect(find.text('Supermercado'), findsOneWidget);
  });

  testWidgets('el resumen muestra el total de los gastos', (tester) async {
    await pumpList(tester, FakeExpenseRepository(sampleExpenses()));
    await tester.pumpAndSettle();

    const total = 85050 + 60000 + 18500 + 24000;
    expect(find.text(formatCents(total)), findsOneWidget);
    expect(find.text('Total gastado'), findsOneWidget);
  });

  testWidgets('filtrar por categoría actualiza la lista y el resumen',
      (tester) async {
    await pumpList(tester, FakeExpenseRepository(sampleExpenses()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Transporte'));
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Gasolina'), findsOneWidget);
    expect(find.text('Taxi'), findsOneWidget);
    expect(find.text('Supermercado'), findsNothing);
    expect(find.text('Total filtrado'), findsOneWidget);
    expect(find.text(formatCents(60000 + 18500)), findsOneWidget);
  });

  testWidgets('una búsqueda sin coincidencias muestra "Sin resultados"',
      (tester) async {
    await pumpList(tester, FakeExpenseRepository(sampleExpenses()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'zzz');
    // El buscador espera 300 ms antes de aplicar el texto (debounce).
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
    // Distinto del estado "no hay gastos": aquí sí existen, pero no coinciden.
    expect(find.text('Aún no hay gastos'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Limpiar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsNothing);
    expect(find.text('Supermercado'), findsOneWidget);
  });

  testWidgets('deslizar un gasto pide confirmación y lo elimina',
      (tester) async {
    final repository = FakeExpenseRepository([sampleExpenses().first]);
    await pumpList(tester, repository);
    await tester.pumpAndSettle();

    await swipeToDelete(tester, 'Supermercado');
    expect(find.text('Eliminar gasto'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();

    expect(repository.items, isEmpty);
    expect(find.text('Supermercado'), findsNothing);
    // Era el último: aparece la lista vacía.
    expect(find.text('Aún no hay gastos'), findsOneWidget);
    // El aviso se muestra aunque la fila ya no exista.
    expect(find.text('Gasto eliminado'), findsOneWidget);
  });

  testWidgets('cancelar la confirmación no elimina nada', (tester) async {
    final repository = FakeExpenseRepository([sampleExpenses().first]);
    await pumpList(tester, repository);
    await tester.pumpAndSettle();

    await swipeToDelete(tester, 'Supermercado');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(repository.items, hasLength(1));
    expect(find.text('Supermercado'), findsOneWidget);
  });
}
