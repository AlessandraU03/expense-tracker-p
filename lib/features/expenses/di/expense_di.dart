import 'package:tracker/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:tracker/features/expenses/data/datasources/expense_seed_datasource.dart';
import 'package:tracker/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:tracker/features/expenses/domain/repositories/expense_repository.dart';
import 'package:tracker/features/expenses/domain/usecases/add_expense.dart';
import 'package:tracker/features/expenses/domain/usecases/update_expense.dart';

class ExpenseDI {
  const ExpenseDI._();

  static final _local = ExpenseLocalDatasource();
  static const _seed = ExpenseSeedDatasource();

  static ExpenseRepository provideRepository() =>
      ExpenseRepositoryImpl(local: _local, seed: _seed);

  static AddExpense provideAddExpense(ExpenseRepository repository) =>
      AddExpense(repository);

  static UpdateExpense provideUpdateExpense(ExpenseRepository repository) =>
      UpdateExpense(repository);
}
