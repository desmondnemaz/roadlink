import 'package:equatable/equatable.dart';

/// Base class for domain/application failures.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure returned by the backend server.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

/// Represents a failure due to lack of internet or connection timeout.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Unable to connect. Please check your internet connection.',
  ]);
}

/// Represents an authentication or authorisation failure (HTTP 401 / 403).
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

/// Represents a local storage or cache failure.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

