import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/widgets/local_games/tic_tac_toe/tic_tac_toe_board.dart';

/// Widget tests for TicTacToeBoard
///
/// Why widget tests?
/// 1. Verify UI renders correctly with different states
/// 2. Test user interactions (taps, gestures)
/// 3. Validate animations
/// 4. Ensure accessibility
/// 5. Faster than E2E but more realistic than unit tests
void main() {
  group('TicTacToeBoard Widget', () {
    late AnimationController animationController;

    setUp(() {
      // Create a dummy AnimationController for tests
      // In real scenario, this would be provided by the parent widget
    });

    testWidgets('should render empty board', (WidgetTester tester) async {
      // Arrange
      const board = ['', '', '', '', '', '', '', '', ''];
      int? tappedIndex;

      // Build widget tree
      await tester.pumpWidget(
        CupertinoApp(
          home: TicTacToeBoard(
            board: board,
            winningPattern: null,
            lineAnimation: const AlwaysStoppedAnimation(0),
            onCellTap: (index) => tappedIndex = index,
          ),
        ),
      );

      // Assert - Find 9 cells
      expect(find.byType(GestureDetector), findsNWidgets(9));

      // Verify cells are empty (no X or O text)
      expect(find.text('X'), findsNothing);
      expect(find.text('O'), findsNothing);
    });

    testWidgets('should display X and O symbols correctly',
            (WidgetTester tester) async {
          // Arrange
          const board = ['X', 'O', 'X', '', '', '', '', '', ''];

          await tester.pumpWidget(
            CupertinoApp(
              home: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0),
                onCellTap: (_) {},
              ),
            ),
          );

          // Assert
          expect(find.text('X'), findsNWidgets(2));
          expect(find.text('O'), findsWidgets);
        });

    testWidgets('should call onCellTap when cell is tapped',
            (WidgetTester tester) async {
          // Arrange
          const board = ['', '', '', '', '', '', '', '', ''];
          int? tappedIndex;

          await tester.pumpWidget(
            CupertinoApp(
              home: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0),
                onCellTap: (index) => tappedIndex = index,
              ),
            ),
          );

          // Act - Tap the center cell
          final centerCell = find.byType(GestureDetector).at(4);
          await tester.tap(centerCell);
          await tester.pump();

          // Assert
          expect(tappedIndex, 4);
        });

    testWidgets('should highlight winning cells',
            (WidgetTester tester) async {
          // Arrange
          const board = ['X', 'X', 'X', 'O', 'O', '', '', '', ''];
          const winningPattern = [0, 1, 2]; // Top row

          await tester.pumpWidget(
            CupertinoApp(
              home: TicTacToeBoard(
                board: board,
                winningPattern: winningPattern,
                lineAnimation: const AlwaysStoppedAnimation(0),
                onCellTap: (_) {},
              ),
            ),
          );

          // Assert - Find cells with winning highlight
          // This depends on your implementation - adjust accordingly
          final winningCells = tester.widgetList(find.byType(Container)).where((w) {
            final container = w as Container;
            final decoration = container.decoration as BoxDecoration?;
            return decoration?.color == CupertinoColors.activeGreen.withOpacity(0.25);
          });

          expect(winningCells.length, greaterThanOrEqualTo(3));
        });

    testWidgets('should handle rapid taps gracefully',
            (WidgetTester tester) async {
          // Arrange
          const board = ['', '', '', '', '', '', '', '', ''];
          final tappedIndices = <int>[];

          await tester.pumpWidget(
            CupertinoApp(
              home: TicTacToeBoard(
                board: board,
                winningPattern: null,
                lineAnimation: const AlwaysStoppedAnimation(0),
                onCellTap: (index) => tappedIndices.add(index),
              ),
            ),
          );

          // Act - Rapid taps
          for (int i = 0; i < 5; i++) {
            await tester.tap(find.byType(GestureDetector).at(0));
          }
          await tester.pump();

          // Assert
          expect(tappedIndices.length, 5);
          expect(tappedIndices.every((i) => i == 0), true);
        });

    testWidgets('should render at correct size', (WidgetTester tester) async {
      // Arrange
      const board = ['', '', '', '', '', '', '', '', ''];
      const customSize = 400.0;

      await tester.pumpWidget(
        CupertinoApp(
          home: TicTacToeBoard(
            board: board,
            winningPattern: null,
            lineAnimation: const AlwaysStoppedAnimation(0),
            onCellTap: (_) {},
            size: customSize,
          ),
        ),
      );

      // Assert
      final boardContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byType(GridView),
          matching: find.byType(Container),
        ).first,
      );

      expect(boardContainer.constraints?.maxWidth, customSize);
      expect(boardContainer.constraints?.maxHeight, customSize);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      // Test for accessibility
      const board = ['X', 'O', '', '', '', '', '', '', ''];

      await tester.pumpWidget(
        CupertinoApp(
          home: TicTacToeBoard(
            board: board,
            winningPattern: null,
            lineAnimation: const AlwaysStoppedAnimation(0),
            onCellTap: (_) {},
          ),
        ),
      );

      // Ensure all cells are tappable (have semantic labels)
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // Verify semantics are properly set
      expect(tester.getSemantics(find.byType(TicTacToeBoard)), isNotNull);

      handle.dispose();
    });

    group('Responsive behavior', () {
      testWidgets('should render correctly on phone screen',
              (WidgetTester tester) async {
            // Set phone screen size
            tester.view.physicalSize = const Size(375, 812);
            tester.view.devicePixelRatio = 2.0;

            const board = ['', '', '', '', '', '', '', '', ''];

            await tester.pumpWidget(
              CupertinoApp(
                home: Scaffold(
                  body: TicTacToeBoard(
                    board: board,
                    winningPattern: null,
                    lineAnimation: const AlwaysStoppedAnimation(0),
                    onCellTap: (_) {},
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();

            // Board should fit within screen
            final boardFinder = find.byType(TicTacToeBoard);
            expect(boardFinder, findsOneWidget);

            final box = tester.getSize(boardFinder);
            expect(box.width, lessThanOrEqualTo(375));
          });

      testWidgets('should render correctly on tablet screen',
              (WidgetTester tester) async {
            // Set tablet screen size
            tester.view.physicalSize = const Size(768, 1024);
            tester.view.devicePixelRatio = 2.0;

            const board = ['', '', '', '', '', '', '', '', ''];

            await tester.pumpWidget(
              CupertinoApp(
                home: Scaffold(
                  body: TicTacToeBoard(
                    board: board,
                    winningPattern: null,
                    lineAnimation: const AlwaysStoppedAnimation(0),
                    onCellTap: (_) {},
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();

            final boardFinder = find.byType(TicTacToeBoard);
            expect(boardFinder, findsOneWidget);
          });
    });
  });
}