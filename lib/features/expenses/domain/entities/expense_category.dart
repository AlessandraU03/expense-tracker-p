/// Categorías predefinidas de un gasto. Es un `enum` porque el conjunto es
/// fijo. Solo lleva datos del negocio; ícono y color están en la capa de
/// presentación (`category_style.dart`).
enum ExpenseCategory {
  alimentacion('Alimentación'),
  transporte('Transporte'),
  entretenimiento('Entretenimiento'),
  servicios('Servicios'),
  compras('Compras'),
  otros('Otros');

  const ExpenseCategory(this.label);

  final String label;

  String get storageValue => name;

  static ExpenseCategory fromStorage(String? value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ExpenseCategory.otros,
    );
  }
}
