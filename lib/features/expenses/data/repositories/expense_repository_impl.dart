import 'package:tracker/core/errors/app_exceptions.dart';
import 'package:tracker/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:tracker/features/expenses/data/datasources/expense_seed_datasource.dart';
import 'package:tracker/features/expenses/data/models/expense_model.dart';
import 'package:tracker/features/expenses/domain/entities/expense.dart';
import 'package:tracker/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required this._local,
    required this._seed,
  });

  final ExpenseLocalDatasource _local;
  final ExpenseSeedDatasource _seed;

  @override
  Future<List<Expense>> getAll() {
    return _guard('No se pudieron cargar los gastos.', () async {

      if (!await _local.isSeeded()) {
        await _local.seed(await _seed.load());
      }
      final models = await _local.getAll();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<void> add(Expense expense) {
    return _guard(
      'No se pudo guardar el gasto.',
      () => _local.insert(ExpenseModel.fromEntity(expense)),
    );
  }

  @override
  Future<void> update(Expense expense) {
    return _guard('No se pudo actualizar el gasto.', () async {
      final updated = await _local.update(ExpenseModel.fromEntity(expense));
      if (updated == 0) throw const ExpenseNotFoundException();
    });
  }

  @override
  Future<void> delete(String id) {
    return _guard('No se pudo eliminar el gasto.', () => _local.delete(id));
  }

  Future<T> _guard<T>(String message, Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw StorageException(message);
    }
  }
}
