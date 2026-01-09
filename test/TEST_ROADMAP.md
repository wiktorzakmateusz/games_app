# Comprehensive Test Suite Roadmap

## ✅ COMPLETED PHASES

### Phase 1: Domain Use Case Tests (100% COMPLETE)
**19 test files, ~120 tests - All passing with mockito pattern**

#### Auth Domain (6 files)
- ✅ `test/features/auth/domain/usecases/sign_in_usecase_test.dart`
- ✅ `test/features/auth/domain/usecases/sign_up_usecase_test.dart`
- ✅ `test/features/auth/domain/usecases/sign_out_usecase_test.dart`
- ✅ `test/features/auth/domain/usecases/get_current_user_usecase_test.dart`
- ✅ `test/features/auth/domain/usecases/update_user_usecase_test.dart`
- ✅ `test/features/auth/domain/usecases/watch_auth_state_usecase_test.dart`

#### Game Domain (4 files)
- ✅ `test/features/game/domain/usecases/start_game_usecase_test.dart`
- ✅ `test/features/game/domain/usecases/make_move_usecase_test.dart`
- ✅ `test/features/game/domain/usecases/watch_game_usecase_test.dart`
- ✅ `test/features/game/domain/usecases/abandon_game_usecase_test.dart`

#### Lobby Domain (6 files)
- ✅ `test/features/lobby/domain/usecases/create_lobby_usecase_test.dart`
- ✅ `test/features/lobby/domain/usecases/join_lobby_usecase_test.dart`
- ✅ `test/features/lobby/domain/usecases/leave_lobby_usecase_test.dart`
- ✅ `test/features/lobby/domain/usecases/toggle_ready_usecase_test.dart`
- ✅ `test/features/lobby/domain/usecases/watch_available_lobbies_usecase_test.dart`
- ✅ `test/features/lobby/domain/usecases/watch_lobby_usecase_test.dart`

#### Stats Domain (3 files)
- ✅ `test/features/stats/domain/usecases/get_user_stats_usecase_test.dart`
- ✅ `test/features/stats/domain/usecases/get_aggregate_stats_usecase_test.dart`
- ✅ `test/features/stats/domain/usecases/get_stats_by_game_type_usecase_test.dart`

### Phase 2: Game Logic Tests (100% COMPLETE)
**3 test files, ~120 tests - Comprehensive coverage**

- ✅ `test/core/game_logic/tic_tac_toe_logic_test.dart` (26 tests)
- ✅ `test/core/game_logic/connect4_logic_test.dart` (~50 tests) **NEW**
- ✅ `test/core/game_logic/mini_sudoku_logic_test.dart` (~45 tests) **NEW**

---

## 🚧 REMAINING PHASES

### Phase 3: Repository Implementation Tests (PENDING)

**Pattern to Follow:** See `test/features/game/data/repositories/game_repository_impl_test.dart`

#### Files to Create:

1. **Auth Repository** (`test/features/auth/data/repositories/auth_repository_impl_test.dart`)
   - Source: `lib/features/auth/data/repositories/auth_repository_impl.dart`
   - Mock: `AuthRemoteDataSource`, `AuthFirebaseDataSource`
   - Test Coverage:
     - signInWithEmailAndPassword (success, failures)
     - signUpWithEmailAndPassword (success, email/username taken)
     - signOut (success, failures)
     - getCurrentUser (user exists, no user, failures)
     - updateUser (success, validation failures)
     - watchAuthState (stream emissions, errors)
     - Exception → Failure mapping

2. **Lobby Repository** (`test/features/lobby/data/repositories/lobby_repository_impl_test.dart`)
   - Source: `lib/features/lobby/data/repositories/lobby_repository_impl.dart`
   - Mock: `LobbyRemoteDataSource`, `LobbyFirestoreDataSource`
   - Test Coverage:
     - createLobby
     - joinLobby
     - leaveLobby
     - toggleReady
     - updateGameType
     - watchLobby
     - watchAvailableLobbies

3. **Stats Repository** (`test/features/stats/data/repositories/stats_repository_impl_test.dart`)
   - Source: `lib/features/stats/data/repositories/stats_repository_impl.dart`
   - Mock: `StatsRemoteDataSource`
   - Test Coverage:
     - getUserStats
     - getAggregateStats
     - getUserStatsByGameType

---

### Phase 4: Integration Tests (Cubit/Bloc) (PENDING)

**Pattern to Follow:** See `test/features/auth/presentation/cubit/auth_cubit_integration_test.dart`

#### Files to Create:

1. **Game Cubit** (`test/features/game/presentation/cubit/game_cubit_test.dart`)
   - Source: `lib/features/game/presentation/cubit/game_cubit.dart`
   - Mock: All game use cases
   - Test Coverage:
     - startGame flow
     - makeMove flow
     - watchGame emissions
     - abandonGame flow
     - State transitions
     - Error handling
     - Complete game scenarios

2. **Lobby Waiting Cubit** (`test/features/lobby/presentation/cubit/lobby_waiting_cubit_test.dart`)
   - Source: `lib/features/lobby/presentation/cubit/lobby_waiting_cubit.dart`
   - Mock: Lobby use cases
   - Test Coverage:
     - watchLobby updates
     - toggleReady
     - leaveLobby
     - Player join/leave handling
     - Game start transition

3. **Lobby List Cubit** (`test/features/lobby/presentation/cubit/lobby_list_cubit_test.dart`)
   - Source: `lib/features/lobby/presentation/cubit/lobby_list_cubit.dart`
   - Mock: Lobby use cases
   - Test Coverage:
     - watchAvailableLobbies
     - createLobby flow
     - joinLobby flow
     - Lobby updates

4. **Stats Cubit** (`test/features/stats/presentation/cubit/stats_cubit_test.dart`)
   - Source: `lib/features/stats/presentation/cubit/stats_cubit.dart`
   - Mock: Stats use cases
   - Test Coverage:
     - fetchUserStats
     - fetchAggregateStats
     - fetchStatsByGameType
     - State transitions

---

### Phase 5: Widget Tests (PENDING)

**Pattern to Follow:** See `test/widgets/local_games/tic_tac_toe/tic_tac_toe_board_test.dart`

#### Priority Widget Tests:

1. **Connect4 Board** (`test/widgets/local_games/connect4/connect4_board_test.dart`)
   - Widget: `lib/widgets/local_games/connect4/connect4_board.dart`
   - Test Coverage:
     - Renders 42 cells (7x6 grid)
     - Handles column taps
     - Displays pieces correctly
     - Shows winning pattern
     - Animation tests
     - Responsive sizing

2. **Mini Sudoku Board** (`test/widgets/local_games/mini_sudoku/mini_sudoku_board_test.dart`)
   - Widget: `lib/widgets/local_games/mini_sudoku/mini_sudoku_board.dart`
   - Test Coverage:
     - Renders 16 cells (4x4 grid)
     - Handles cell selection
     - Number input
     - Error highlighting
     - Locked cells display
     - Completion state

3. **Navigation Components**
   - `test/widgets/navigation/app_game_nav_bar_test.dart`
   - `test/widgets/navigation/app_menu_nav_bar_test.dart`
   - Test Coverage:
     - Navigation actions
     - Active state
     - Responsive behavior

4. **Game Components**
   - `test/widgets/game_header_test.dart` (if exists)
   - `test/widgets/game_button_test.dart` (if exists)
   - `test/widgets/player_info_card_test.dart` (if exists)

---

## 📋 TEST PATTERNS & BEST PRACTICES

### Use Case Tests Pattern:
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([YourRepository])
void main() {
  late YourUseCase usecase;
  late MockYourRepository mockRepository;

  setUp(() {
    mockRepository = MockYourRepository();
    usecase = YourUseCase(mockRepository);
  });

  group('YourUseCase', () {
    test('should return success', () async {
      when(mockRepository.method(any))
          .thenAnswer((_) async => Right(result));
      
      final result = await usecase(params);
      
      expect(result, Right(expectedResult));
      verify(mockRepository.method(params)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
    
    // Test all failure types
    // Test edge cases
    // Test parameter passing
  });
}
```

### Repository Tests Pattern:
```dart
@GenerateMocks([DataSource])
void main() {
  late RepositoryImpl repository;
  late MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    repository = RepositoryImpl(dataSource: mockDataSource);
  });

  group('methodName', () {
    test('should return Entity when remote call succeeds', () async {
      when(mockDataSource.method(any))
          .thenAnswer((_) async => modelData);
      
      final result = await repository.method(param);
      
      expect(result.isRight(), true);
      verify(mockDataSource.method(param)).called(1);
    });
    
    test('should return ServerFailure when ServerException', () async {
      when(mockDataSource.method(any))
          .thenThrow(ServerException('error', 500));
      
      final result = await repository.method(param);
      
      expect(result.isLeft(), true);
    });
    
    // Test all exception types
    // Test stream scenarios
  });
}
```

### Cubit/Bloc Tests Pattern:
```dart
import 'package:bloc_test/bloc_test.dart';

@GenerateMocks([UseCase1, UseCase2])
void main() {
  late YourCubit cubit;
  late MockUseCase1 mockUseCase1;

  setUp(() {
    mockUseCase1 = MockUseCase1();
    cubit = YourCubit(useCase: mockUseCase1);
  });

  tearDown(() {
    cubit.close();
  });

  blocTest<YourCubit, YourState>(
    'emits [Loading, Success] when action succeeds',
    build: () {
      when(mockUseCase1(any))
          .thenAnswer((_) async => Right(data));
      return cubit;
    },
    act: (cubit) => cubit.performAction(params),
    expect: () => [
      YourState.loading(),
      YourState.success(data),
    ],
    verify: (_) {
      verify(mockUseCase1(params)).called(1);
    },
  );
  
  // Test all state transitions
  // Test error states
  // Test complete user flows
}
```

### Widget Tests Pattern:
```dart
void main() {
  group('YourWidget', () {
    testWidgets('should render correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: YourWidget(params)),
      );
      
      expect(find.byType(SomeChild), findsOneWidget);
      expect(find.text('Expected'), findsWidgets);
    });
    
    testWidgets('should handle tap', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: YourWidget(onTap: () => tapped = true),
        ),
      );
      
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      
      expect(tapped, true);
    });
    
    // Test different states
    // Test animations
    // Test accessibility
    // Test responsive behavior
  });
}
```

---

## 🔧 COMMANDS TO RUN

### Generate Mocks:
```bash
cd games_app
flutter pub run build_runner build --delete-conflicting-outputs
```

### Run All Tests:
```bash
flutter test
```

### Run Specific Test Suites:
```bash
# Use cases only
flutter test test/features/

# Game logic only
flutter test test/core/game_logic/

# Specific file
flutter test test/features/auth/domain/usecases/sign_in_usecase_test.dart
```

### Coverage Report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📊 CURRENT PROGRESS

- ✅ Phase 1: Domain Use Cases (100%)
- ✅ Phase 2: Game Logic (100%)
- ⏳ Phase 3: Repositories (0%)
- ⏳ Phase 4: Cubits/Blocs (0%)
- ⏳ Phase 5: Widgets (0%)

**Total Tests Created:** ~240 comprehensive tests
**Test Coverage:** ~100% for completed phases

---

## 🎯 NEXT STEPS

1. **Start with Phase 3:** Repository tests
   - Begin with Auth Repository (most straightforward)
   - Use existing `game_repository_impl_test.dart` as reference
   - Create comprehensive test for each repository

2. **Move to Phase 4:** Integration tests
   - Start with Game Cubit
   - Use existing `auth_cubit_integration_test.dart` as reference
   - Test complete user flows

3. **Finish with Phase 5:** Widget tests
   - Focus on game boards first (highest value)
   - Then navigation components
   - Finally smaller reusable widgets

---

## 📝 NOTES

- All tests use `mockito` with `@GenerateMocks` annotations
- Mocks are auto-generated in `.mocks.dart` files
- Follow existing test patterns for consistency
- Each test should cover: success, all failure types, edge cases
- Use descriptive test names
- Verify both return values AND method calls
- Clean up resources in `tearDown()` for integration tests

---

## 🚀 QUICK START FOR NEW CONVERSATION

To continue testing work:

1. Review this roadmap
2. Choose next phase (Phase 3 recommended)
3. Pick first file to test
4. Use corresponding pattern from above
5. Run `flutter pub run build_runner build --delete-conflicting-outputs`
6. Run tests and verify they pass
7. Move to next file

**Reference Files:**
- Use case pattern: `test/features/auth/domain/usecases/sign_in_usecase_test.dart`
- Repository pattern: `test/features/game/data/repositories/game_repository_impl_test.dart`
- Cubit pattern: `test/features/auth/presentation/cubit/auth_cubit_integration_test.dart`
- Widget pattern: `test/widgets/local_games/tic_tac_toe/tic_tac_toe_board_test.dart`

