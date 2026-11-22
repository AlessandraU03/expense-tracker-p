import 'package:flutter/material.dart';
import 'package:tracker/features/expenses/domain/entities/expense_category.dart';
import 'package:tracker/features/expenses/presentation/widgets/category/category_style.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.category, this.size = 44});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
      child: Icon(
        category.icon,
        size: size * 0.5,
        color: categoryOnColor,
      ),
    );
  }
}
