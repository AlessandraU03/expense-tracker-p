# Expense Tracker

App en Flutter para registrar y consultar gastos personales: se pueden crear, editar y eliminar, clasificarlos por categoría, filtrarlos, buscarlos y ver un resumen. Funciona sin internet; todo se guarda en el teléfono.

## Ejecución

```bash
flutter pub get
flutter run
```

Necesita Flutter estable reciente y un emulador o teléfono. Los datos de ejemplo se cargan solo la primera vez que se abre la app; para verlos de nuevo hay que borrar los datos de la app o reinstalarla.

## Dependencias

| Paquete | Para qué lo uso |
|---|---|
| `flutter_riverpod` | Estado, inyección de dependencias y estados de carga/error |
| `sqflite` + `path` | Base de datos SQLite local |
| `shared_preferences` | Recordar el tema (claro, oscuro o automático) |
| `intl` | Formato de moneda y fechas |
| `device_preview` | Solo desarrollo: probar tamaños de pantalla en escritorio |


## Organización

Separé el código por feature (hoy solo expenses, pensando en que la app crezca), la cual contiene tres capas: domain, data y presentation. Sigo los principios de arquitectura limpia, que ya apliqué en proyectos universitarios, y en presentation uso MVVM, con los notifiers de Riverpod como ViewModel.
```
lib/
├── core/                 # inyección de dependencias (di/), errores, navegación
├── shared/               # tema, utilidades y widgets que no saben nada de gastos
└── features/expenses/
    ├── di/               # cómo se construye cada pieza
    ├── domain/           # entidades, reglas, interfaz del repositorio, casos de uso
    ├── data/             # SQLite, datos iniciales, modelo, repositorio concreto
    └── presentation/     # providers (ViewModel), pantallas y widgets
assets/seed/expenses.json # gastos iniciales
test/                     # pruebas de dominio, de estado y de widgets
```

Las pantallas son cortas a propósito: arman la vista con widgets pequeños agrupados por lo que atienden (`summary/`, `filters/`, `expense/`, `form/`, `category/`), cada uno con una sola responsabilidad. Las reglas de negocio (validar el gasto, filtrar y calcular el resumen) están en domain/usecases/, de esa forma no se mezcla logica de negocio con las vistas.

## Manejo de estado

Usé **Riverpod con `AsyncNotifier`**. La lista de gastos vive en un notifier, y los filtros, el orden y el resumen son providers aparte que se calculan a partir de esa lista. Las pantallas solo leen el estado y le piden cambios (crear, editar, eliminar); nunca modifican los datos directamente.

- **Por qué lo elegí:**
  - `AsyncValue` ya representa los estados de carga, datos y error, así que no necesito banderas manuales como `isLoading` o `hasError`.
  - El resumen y la lista filtrada se recalculan solos cuando cambian los gastos o los filtros.
  - El estado vive separado de las pantallas y no depende de `BuildContext`, por lo que la lógica se puede probar sin la interfaz.
- **Alternativas que consideré:** `Provider` con `ChangeNotifier` (es más simple, pero la carga y el error se manejan a mano) y `setState` (no sirve cuando varias pantallas comparten datos).
- **Limitación:** para una app tan pequeña, Riverpod es un poco más herramienta de la necesaria. La elegí pensando en que la app pueda crecer y porque está pensada para manejar datos asíncronos, como la lectura de la base de datos.

## Persistencia

Guardo los gastos en **SQLite con `sqflite`**, detrás de una interfaz `ExpenseRepository`. La pantalla nunca habla con la base: si cambiara el almacenamiento, no se tocaría la lógica ni la UI. Las fechas se guardan como texto ISO (`2026-11-05`), que se ordena y filtra bien; además cada gasto guarda la hora en que se registró, para ordenar los de un mismo día.

**Datos iniciales:** el JSON de ejemplo se carga solo en el primer arranque. Una bandera en una tabla `meta` indica que ya se cargó, y el seed y la bandera se escriben en una sola transacción. Después, SQLite es la única fuente de verdad. Usé la bandera porque, si solo preguntara "¿la tabla está vacía?", al borrar todos los gastos volverían a aparecer los de ejemplo.

- **Alternativas:** `shared_preferences` con JSON (menos código, pero reescribe todo en cada cambio) y `drift` (consultas tipadas, pero genera código y es mucho para este tamaño).
- **Limitación:** filtrar y ordenar se hace en memoria porque son pocos datos; con miles de registros habría que pasarlo a SQL.

## Navegación

`Navigator` con `MaterialPageRoute`. Con cuatro pantallas (lista, detalle, crear y editar) y sin enlaces profundos, `go_router` solo agregaría configuración. Al detalle y a la edición les paso **únicamente el id** del gasto, y cada pantalla lee el gasto del provider; así siempre muestran la versión más reciente, por ejemplo justo después de editar. Crear y editar comparten el mismo formulario.

## Decisiones técnicas

1. **La regla de fecha futura vive en el dominio.** `validateExpense` la aplica y la usan tanto `AddExpense` como `UpdateExpense`; lanza `FutureDateException`, y el formulario solo muestra el mensaje. Se compara solo la fecha, sin hora, para que elegir "hoy" nunca falle por unos minutos.
   - **Alternativa:** validarla solo en el formulario. Es más rápido de escribir, pero cualquier otra vía de crear o editar se la saltaría.
   - **Limitación:** el selector de fecha también bloquea los días futuros como ayuda, así que la regla existe en dos lugares; la del dominio es la que manda.
2. **Montos en centavos (`int`).** Con `double`, `0.1 + 0.2` da `0.30000000000000004`; con enteros las sumas son exactas, algo importante con dinero. Convierto solo en los bordes: al leer el campo y al mostrar el monto.
   - **Alternativa:** `double`, que es más directo pero acumula errores de redondeo, o un paquete de decimales, que es más complejo de lo que este reto necesita.
   - **Limitación:** hay que acordarse de convertir en los bordes.
3. **Inyección de dependencias manual, con Riverpod como contenedor.** `ExpenseDI` construye por constructor la cadena datasources → repositorio → casos de uso, y `core/di/injection_container.dart` la registra como providers. El dominio solo conoce la interfaz del repositorio, así que en las pruebas basta un `overrideWithValue(FakeExpenseRepository())`.
   - **Alternativa:** `get_it`, un localizador de servicios que duplicaría lo que Riverpod ya hace.
   - **Limitación:** para una sola feature son dos archivos más de los estrictamente necesarios; se justifican si la app crece.
4. **El resumen se calcula, no se guarda.** `calculateSummary` obtiene total, cantidad y categoría con mayor gasto de la lista ya filtrada, así nunca se desincroniza al crear, editar o eliminar.
   - **Alternativa:** guardar el resumen como un estado propio y actualizarlo en cada cambio, que se puede desincronizar.
   - **Limitación:** se recalcula completo cada vez; con muchos datos habría que optimizarlo.
5. **Categorías como `enum`.** Son un conjunto fijo, y el compilador avisa si falta algún caso. El ícono y el color viven en presentación, para que el dominio no dependa de Flutter.
   - **Alternativa:** una clase guardada en la base de datos, más flexible.
   - **Limitación:** el usuario no puede crear categorías propias.
6. **Errores con excepciones propias.** Los fallos de lectura caen en el estado de error con botón "Reintentar"; los de guardado y las validaciones se muestran en un `SnackBar` con un mensaje comprensible; y la lista vacía y el "sin resultados" tienen su propia vista.
   - **Alternativa:** devolver un resultado con éxito o error en vez de lanzar excepciones, que es más explícito pero más verboso.
   - **Limitación:** hay que acordarse de atrapar las excepciones en cada punto donde se guarda.

## Mejoras

- **Estadísticas para el usuario:** una pantalla con gráficas del gasto por categoría y por mes, para ver en qué se va el dinero y cómo cambia con el tiempo. Hoy el resumen solo muestra el total, la cantidad y la categoría con mayor gasto; las gráficas darían una mejor idea del panorama. Sería la mejora más notable para quien usa la app.
- **Resumen general junto al filtrado:** mostrar, además del total de lo que se ve con los filtros activos, el total de todos los gastos. Así el usuario puede comparar cuánto representa lo filtrado frente a todo lo que gastó.
- **Filtrar y ordenar con consultas SQL:** hoy se hace en memoria porque son pocos datos. Si el usuario acumulara miles de gastos, la base de datos lo haría más rápido y la app no cargaría todo en memoria.
- **`go_router`:** si la app tuviera más pantallas o enlaces profundos (por ejemplo, abrir un gasto desde una notificación), un enrutador ordenaría las rutas en un solo lugar. Con cuatro pantallas no hace falta.
- **Categorías creadas por el usuario:** hoy son seis fijas. Poder crear las suyas haría la app más útil, aunque habría que guardarlas en la base de datos y cambiar el `enum` por una clase.
