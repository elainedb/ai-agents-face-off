import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, name, email, photoUrl];
}
