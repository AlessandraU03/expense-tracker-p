import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tracker/features/expenses/data/models/expense_model.dart';

class ExpenseSeedDatasource {
  const ExpenseSeedDatasource({this.assetPath = 'assets/seed/expenses.json'});

  final String assetPath;

  Future<List<ExpenseModel>> load() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => ExpenseModel.fromMap(item as Map<String, Object?>))
        .toList();
  }
}
