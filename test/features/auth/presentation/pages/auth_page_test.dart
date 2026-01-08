import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:games_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:games_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:games_app/features/auth/presentation/pages/auth_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.stream).thenAnswer(
      (_) => Stream.value(const Unauthenticated()),
    );
    when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());
    when(() => mockAuthCubit.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {});
    when(() => mockAuthCubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          username: any(named: 'username'),
        )).thenAnswer((_) async {});
  });

  Widget createTestWidget() {
    return BlocProvider<AuthCubit>.value(
      value: mockAuthCubit,
      child: const CupertinoApp(
        home: AuthPage(),
      ),
    );
  }

  group('AuthPage', () {
    testWidgets('displays sign in mode by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign In'), findsNWidgets(2)); // Title and button
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('displays email and password fields in sign in mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.widgetWithText(CupertinoTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(CupertinoTextField, 'Password'), findsOneWidget);
      
      // Username field should not be visible in sign in mode
      expect(find.widgetWithText(CupertinoTextField, 'Username'), findsNothing);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome to Multiplayer'), findsOneWidget);
    });

    testWidgets('can toggle to sign up mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially in sign in mode
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Now in sign up mode
      expect(find.text('Sign Up'), findsNWidgets(2)); // Title and button
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('displays username field in sign up mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Toggle to sign up mode
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Username field should now be visible
      expect(find.widgetWithText(CupertinoTextField, 'Username'), findsOneWidget);
      expect(find.widgetWithText(CupertinoTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(CupertinoTextField, 'Password'), findsOneWidget);
    });

    testWidgets('displays loading indicator when loading',
        (WidgetTester tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthLoading());
      when(() => mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthLoading()),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('disables inputs when loading', (WidgetTester tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthLoading());
      when(() => mockAuthCubit.stream).thenAnswer(
        (_) => Stream.value(const AuthLoading()),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final emailField = tester.widget<CupertinoTextField>(
        find.widgetWithText(CupertinoTextField, 'Email'),
      );
      expect(emailField.enabled, false);

      final passwordField = tester.widget<CupertinoTextField>(
        find.widgetWithText(CupertinoTextField, 'Password'),
      );
      expect(passwordField.enabled, false);
    });

    testWidgets('calls signIn when sign in button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter email and password
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Password'),
        'password123',
      );

      // Tap sign in button
      await tester.tap(find.widgetWithText(CupertinoButton, 'Sign In'));
      await tester.pump();

      verify(() => mockAuthCubit.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('calls signUp when sign up button is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Toggle to sign up mode
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Enter username, email and password
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Username'),
        'testuser',
      );
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Password'),
        'password123',
      );

      // Tap sign up button
      await tester.tap(find.widgetWithText(CupertinoButton, 'Sign Up'));
      await tester.pump();

      verify(() => mockAuthCubit.signUp(
            email: 'test@example.com',
            password: 'password123',
            username: 'testuser',
          )).called(1);
    });

    testWidgets('clears fields when toggling mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter some text
      await tester.enterText(
        find.widgetWithText(CupertinoTextField, 'Email'),
        'test@example.com',
      );

      // Toggle to sign up mode
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pumpAndSettle();

      // Field should be cleared
      final emailField = tester.widget<CupertinoTextField>(
        find.widgetWithText(CupertinoTextField, 'Email'),
      );
      expect(emailField.controller?.text, isEmpty);
    });

    testWidgets('has correct page structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CupertinoPageScaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets); // Multiple SafeAreas are ok
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(CupertinoNavigationBar), findsOneWidget);
    });

    testWidgets('password field is obscured', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final passwordField = tester.widget<CupertinoTextField>(
        find.widgetWithText(CupertinoTextField, 'Password'),
      );
      expect(passwordField.obscureText, true);
    });

    testWidgets('email field has correct keyboard type',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final emailField = tester.widget<CupertinoTextField>(
        find.widgetWithText(CupertinoTextField, 'Email'),
      );
      expect(emailField.keyboardType, TextInputType.emailAddress);
    });
  });
}

