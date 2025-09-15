
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/di.dart';
import 'package:flutter_gemini/features/login/presentation/bloc/login_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gemini/main.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginBloc extends MockBloc<LoginEvent, LoginState> implements LoginBloc {}

void main() {
  late LoginBloc loginBloc;

  setUp(() {
    loginBloc = MockLoginBloc();
    when(() => loginBloc.state).thenReturn(const LoginState.initial());
    if (getIt.isRegistered<LoginBloc>()) {
      getIt.unregister<LoginBloc>();
    }
    getIt.registerSingleton<LoginBloc>(loginBloc);
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title is displayed.
    expect(find.text('Login with Google'), findsOneWidget);

    // Verify that the sign-in button is displayed.
    expect(find.widgetWithText(ElevatedButton, 'Sign in with Google'), findsOneWidget);
  });
}
