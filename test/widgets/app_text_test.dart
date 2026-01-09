import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/app_text.dart';

void main() {
  group('AppText Widget Tests', () {
    testWidgets('displays text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText('Hello World'),
            ),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('h1 factory creates heading', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.h1('Main Title'),
            ),
          ),
        ),
      );

      expect(find.text('Main Title'), findsOneWidget);
    });

    testWidgets('h3 factory creates heading', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.h3('Section Title'),
            ),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
    });

    testWidgets('bodyLarge factory creates body text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.bodyLarge('Body content'),
            ),
          ),
        ),
      );

      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('button factory creates button text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.button('Click Me'),
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('caption factory creates caption text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.caption('Small caption'),
            ),
          ),
        ),
      );

      expect(find.text('Small caption'), findsOneWidget);
    });

    testWidgets('respects textAlign parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.h2('Centered', textAlign: TextAlign.center),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Centered'));
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('respects maxLines parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.bodyMedium('Long text', maxLines: 2),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Long text'));
      expect(textWidget.maxLines, 2);
    });

    testWidgets('respects overflow parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child:
                  AppText.bodySmall('Text', overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Text'));
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });

    testWidgets('paragraph factory creates paragraph text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.paragraph('This is a paragraph'),
            ),
          ),
        ),
      );

      expect(find.text('This is a paragraph'), findsOneWidget);
    });

    testWidgets('small factory creates small text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(
              child: AppText.small('Tiny text'),
            ),
          ),
        ),
      );

      expect(find.text('Tiny text'), findsOneWidget);
    });
  });
}

