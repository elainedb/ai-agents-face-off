import 'package:equatable/equatable.dart';

enum FailureType { server, cache, network, auth, validation, unexpected }

class Failure extends Equatable {
  const Failure(this.type, this.message);

  const Failure.server(String message) : this(FailureType.server, message);

  const Failure.cache(String message) : this(FailureType.cache, message);

  const Failure.network(String message) : this(FailureType.network, message);

  const Failure.auth(String message) : this(FailureType.auth, message);

  const Failure.validation(String message)
    : this(FailureType.validation, message);

  const Failure.unexpected(String message)
    : this(FailureType.unexpected, message);

  final FailureType type;
  final String message;

  @override
  List<Object?> get props => [type, message];
}
