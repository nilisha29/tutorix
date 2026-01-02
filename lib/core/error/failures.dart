import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure when local database operations fail
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = "Local database operation failed",
  }) : super(message);
}

/// Failure for API calls
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// Failure for network issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = "Network connection failed",
  }) : super(message);
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    String message = "Validation failed",
  }) : super(message);
}
