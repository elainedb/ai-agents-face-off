import 'package:equatable/equatable.dart';

class Channel extends Equatable {
  final String id;
  final String label;

  const Channel({required this.id, required this.label});

  @override
  List<Object?> get props => [id, label];
}
