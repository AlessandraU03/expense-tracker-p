import 'package:flutter/material.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';

extension ExpenseCategoryStyle on ExpenseCategory {
  IconData get icon => switch (this) {
        ExpenseCategory.alimentacion => Icons.restaurant_outlined,
        ExpenseCategory.transporte => Icons.directions_car_outlined,
        ExpenseCategory.entretenimiento => Icons.movie_outlined,
        ExpenseCategory.servicios => Icons.bolt_outlined,
        ExpenseCategory.compras => Icons.shopping_bag_outlined,
        ExpenseCategory.otros => Icons.more_horiz,
      };

  Color get color => switch (this) {
        ExpenseCategory.alimentacion => const Color(0xFFF08A52),
        ExpenseCategory.transporte => const Color(0xFF5B9BEA),
        ExpenseCategory.entretenimiento => const Color(0xFFA184F5),
        ExpenseCategory.servicios => const Color(0xFFF2B53D),
        ExpenseCategory.compras => const Color(0xFFEE6B9B),
        ExpenseCategory.otros => const Color(0xFF9AA7A1),
      };
}

/// Color de los íconos que van sobre el círculo de color de la categoría.
const Color categoryOnColor = Color(0xFF0E1311);
