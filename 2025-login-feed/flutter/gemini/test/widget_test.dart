import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/di.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_event.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_state.dart';
import 'package:flutter_gemini/features/login/presentation/pages/login_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState> implements LoginBloc {}

void main() {
  late MockLoginBloc mockLoginBloc;

  setUpAll(() {
    registerFallbackValue(const LoginEvent.loginWithGoogle());
    registerFallbackValue(const LoginState.initial());
  });

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
    getIt.registerSingleton<LoginBloc>(mockLoginBloc);
  });

  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (context) => mockLoginBloc,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Login with Google'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets('Login button triggers LoginWithGoogle event', (WidgetTester tester) async {
    when(() => mockLoginBloc.state).thenReturn(const LoginState.initial());
    when(() => mockLoginBloc.add(const LoginEvent.loginWithGoogle()))
        .thenReturn(null);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (context) => mockLoginBloc,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    verify(() => mockLoginBloc.add(const LoginEvent.loginWithGoogle())).called(1);
  });

  testWidgets('Loading indicator is shown when state is loading', (WidgetTester tester) async {
    when(() => mockLoginBloc.state).thenReturn(const LoginState.loading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (context) => mockLoginBloc,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Error message is shown when state is error', (WidgetTester tester) async {
    whenListen(
      mockLoginBloc,
      Stream.fromIterable([const LoginState.initial(), const LoginState.error('Test Error')]),
      initialState: const LoginState.initial(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>(
          create: (context) => mockLoginBloc,
          child: const LoginPage(),
        ),
      ),
    );

    await tester.pump(); // Pump to trigger the listener

    expect(find.text('Test Error'), findsOneWidget);
  });
}