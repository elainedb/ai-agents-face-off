import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ytdash_flutter_claude/core/error/failures.dart';
import 'package:ytdash_flutter_claude/core/usecases/usecase.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/entities/user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/get_current_user.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:ytdash_flutter_claude/features/authentication/domain/usecases/sign_out.dart';
import 'package:ytdash_flutter_claude/features/authentication/presentation/bloc/auth_bloc.dart';

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

void main() {
  late AuthBloc bloc;
  late MockSignInWithGoogle mockSignIn;
  late MockSignOut mockSignOut;
  late MockGetCurrentUser mockGetCurrentUser;

  const testUser = User(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    photoUrl: 'https://example.com/photo.jpg',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockSignIn = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockGetCurrentUser = MockGetCurrentUser();
    bloc = AuthBloc(mockSignIn, mockSignOut, mockGetCurrentUser);
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is AuthState.initial', () {
    expect(bloc.state, const AuthState.initial());
  });

  group('checkAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when user is found',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.checkAuthStatus()),
      expect: () => [
        const AuthState.authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when no user',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.checkAuthStatus()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] on failure',
      build: () {
        when(() => mockGetCurrentUser(any())).thenAnswer(
            (_) async => const Left(Failure.auth('Error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.checkAuthStatus()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );
  });

  group('signInWithGoogle', () {
    blocTest<AuthBloc, AuthState>(
      'emits [loading, authenticated] on success',
      build: () {
        when(() => mockSignIn(any()))
            .thenAnswer((_) async => const Right(testUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.signInWithGoogle()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [loading, error] on failure',
      build: () {
        when(() => mockSignIn(any())).thenAnswer(
            (_) async => const Left(Failure.auth('Access denied')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.signInWithGoogle()),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error('Access denied'),
      ],
    );
  });

  group('signOut', () {
    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] on success',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const AuthEvent.signOut()),
      expect: () => [
        const AuthState.unauthenticated(),
      ],
    );
  });
}
