import 'package:flutter_test/flutter_test.dart';
import 'package:ytdash_flutter_gemini/features/authentication/data/models/user_model.dart';

void main() {
  test('UserModel toEntity converts correctly', () {
    const userModel = UserModel(
      id: '123',
      name: 'Test User',
      email: 'test@example.com',
      photoUrl: 'https://example.com/photo.jpg',
    );

    final userEntity = userModel.toEntity();

    expect(userEntity.id, '123');
    expect(userEntity.name, 'Test User');
    expect(userEntity.email, 'test@example.com');
    expect(userEntity.photoUrl, 'https://example.com/photo.jpg');
    expect(userEntity.hasPhoto, true);
  });
}