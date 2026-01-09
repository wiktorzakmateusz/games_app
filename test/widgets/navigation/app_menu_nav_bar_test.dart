import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/navigation/app_menu_nav_bar.dart';

void main() {
  group('AppMenuNavBar Widget Tests', () {
    testWidgets('displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppMenuNavBar(title: 'Settings'),
            child: Container(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows back button when navigation stack has routes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) => CupertinoButton(
                child: const Text('Go to Settings'),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const CupertinoPageScaffold(
                      navigationBar: AppMenuNavBar(title: 'Settings'),
                      child: SizedBox(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.back), findsOneWidget);
    });

    testWidgets('hides back button when no navigation stack',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: const AppMenuNavBar(title: 'Home'),
            child: Container(),
          ),
        ),
      );

      expect(find.byIcon(CupertinoIcons.back), findsNothing);
    });

    testWidgets('calls custom onBackPressed when provided',
        (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: AppMenuNavBar(
              title: 'Settings',
              onBackPressed: () => backPressed = true,
            ),
            child: Container(),
          ),
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pump();

      expect(backPressed, true);
    });

    testWidgets('pops navigation when back pressed without custom callback',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Builder(
              builder: (context) => CupertinoButton(
                child: const Text('Go to Settings'),
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => CupertinoPageScaffold(
                      navigationBar: const AppMenuNavBar(title: 'Settings'),
                      child: Container(key: const Key('settings_page')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go to Settings'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_page')), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.back));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('settings_page')), findsNothing);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const navBar = AppMenuNavBar(title: 'Settings');
      expect(navBar.preferredSize.height, kMinInteractiveDimension);
    });

    testWidgets('should not fully obstruct', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) {
              const navBar = AppMenuNavBar(title: 'Settings');
              expect(navBar.shouldFullyObstruct(context), false);
              return Container();
            },
          ),
        ),
      );
    });
  });
}

