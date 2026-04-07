import 'package:equatable/equatable.dart';

enum FailureType { server, cache, network, auth, validation, unexpected }

class Failure extends Equatable {
  const Failure._(this.type, this.message);

  const Failure.server(String message) : this._(FailureType.server, message);
  const Failure.cache(String message) : this._(FailureType.cache, message);
  const Failure.network(String message) : this._(FailureType.network, message);
  const Failure.auth(String message) : this._(FailureType.auth, message);
  const Failure.validation(String message)
    : this._(FailureType.validation, message);
  const Failure.unexpected(String message)
    : this._(FailureType.unexpected, message);

  final FailureType type;
  final String message;

  @override
  List<Object?> get props => <Object?>[type, message];
}
