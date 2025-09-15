
import 'package:flutter_gemini/features/login/domain/repositories/login_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignOut {
  final LoginRepository repository;

  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}
