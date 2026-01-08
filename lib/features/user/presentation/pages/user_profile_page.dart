import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../stats/presentation/cubit/stats_cubit.dart';
import '../../../stats/presentation/cubit/stats_state.dart';
import '../../../stats/presentation/widgets/aggregate_stats_card_profile.dart';
import '../../../stats/presentation/widgets/game_type_stats_card.dart';
import '../widgets/user_avatar.dart';
import '../widgets/user_display_name.dart';
import '../widgets/user_username.dart';
import '../widgets/user_logout_button.dart';
import 'edit_profile_page.dart';
import '../../../../injection_container.dart' as di;

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          final user = authState.user;
          
          return BlocProvider(
            create: (_) => di.sl<StatsCubit>()
              ..loadUserStats(user.id),
            child: CupertinoPageScaffold(
              navigationBar: AppNavBar(
                title: 'Profile',
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.pencil),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        UserAvatar(
                          imageUrl: user.photoURL,
                          size: 150,
                        ),
                        const SizedBox(height: 32),
                        UserDisplayName(displayName: user.displayName),
                        const SizedBox(height: 12),
                        UserUsername(username: user.username),
                        const SizedBox(height: 48),
                        BlocBuilder<StatsCubit, StatsState>(
                          builder: (context, statsState) {
                            if (statsState is StatsLoaded) {
                              return Column(
                                children: [
                                  if (statsState.aggregateStats != null)
                                    AggregateStatsCardProfile(
                                      aggregateStats: statsState.aggregateStats!,
                                    ),
                                  if (statsState.aggregateStats != null)
                                    const SizedBox(height: 24),
                                  GameTypeStatsCard(
                                    stats: statsState.stats,
                                    userId: user.id,
                                  ),
                                ],
                              );
                            }
                            if (statsState is StatsLoading) {
                              return Column(
                                children: [
                                  const AggregateStatsCardProfileSkeleton(),
                                  const SizedBox(height: 24),
                                  const GameTypeStatsCardSkeleton(),
                                ],
                              );
                            }
                            if (statsState is StatsError) {
                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.exclamationmark_triangle,
                                      color: CupertinoColors.systemRed,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      statsState.message,
                                      style: const TextStyle(
                                        color: CupertinoColors.systemRed,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 48),
                        const UserLogoutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          // Should not happen if route is protected, but handle gracefully
          return CupertinoPageScaffold(
            navigationBar: const AppNavBar(title: 'Profile'),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.person_circle,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    const Text('Not authenticated'),
                    const SizedBox(height: 24),
                    CupertinoButton.filled(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: const Text('Go to Home'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

