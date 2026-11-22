sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class FutureDateException extends AppException {
  const FutureDateException()
      : super('No puedes registrar un gasto con fecha futura.');
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class ExpenseNotFoundException extends AppException {
  const ExpenseNotFoundException()
      : super('No se encontró el gasto solicitado.');
}

String userMessage(Object error) {
  if (error is AppException) return error.message;
  return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
}