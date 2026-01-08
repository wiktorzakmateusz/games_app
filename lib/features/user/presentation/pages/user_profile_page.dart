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
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/utils/device_type.dart';

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
                  child: ResponsiveLayout.constrainWidth(
                    context,
                    Padding(
                      padding: ResponsiveLayout.getPadding(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                          UserAvatar(
                            imageUrl: user.photoURL,
                            size: 150,
                          ),
                          SizedBox(height: ResponsiveLayout.getSpacing(context) * 2),
                          UserDisplayName(displayName: user.displayName),
                          SizedBox(height: ResponsiveLayout.getSpacing(context) * 0.75),
                          UserUsername(username: user.username),
                          SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                          BlocBuilder<StatsCubit, StatsState>(
                            builder: (context, statsState) {
                              final isTabletOrDesktop = DeviceTypeHelper.isTablet(context) || DeviceTypeHelper.isDesktop(context);
                              
                              if (statsState is StatsLoaded) {
                                if (isTabletOrDesktop && statsState.aggregateStats != null) {
                                  // Side by side layout for tablets/desktops
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AggregateStatsCardProfile(
                                          aggregateStats: statsState.aggregateStats!,
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveLayout.getSpacing(context)),
                                      Expanded(
                                        child: GameTypeStatsCard(
                                          stats: statsState.stats,
                                          userId: user.id,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Stacked layout for phones
                                  return Column(
                                    children: [
                                      if (statsState.aggregateStats != null)
                                        AggregateStatsCardProfile(
                                          aggregateStats: statsState.aggregateStats!,
                                        ),
                                      if (statsState.aggregateStats != null)
                                        SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.5),
                                      GameTypeStatsCard(
                                        stats: statsState.stats,
                                        userId: user.id,
                                      ),
                                    ],
                                  );
                                }
                              }
                              if (statsState is StatsLoading) {
                                if (isTabletOrDesktop) {
                                  // Side by side skeletons for tablets/desktops
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        child: AggregateStatsCardProfileSkeleton(),
                                      ),
                                      SizedBox(width: ResponsiveLayout.getSpacing(context)),
                                      const Expanded(
                                        child: GameTypeStatsCardSkeleton(),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Stacked skeletons for phones
                                  return Column(
                                    children: [
                                      const AggregateStatsCardProfileSkeleton(),
                                      SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.5),
                                      const GameTypeStatsCardSkeleton(),
                                    ],
                                  );
                                }
                              }
                              if (statsState is StatsError) {
                                return Padding(
                                  padding: ResponsiveLayout.getPadding(context),
                                  child: Column(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.exclamationmark_triangle,
                                        color: CupertinoColors.systemRed,
                                      ),
                                      SizedBox(height: ResponsiveLayout.getSpacing(context) * 0.5),
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
                          SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                          const UserLogoutButton(),
                          SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                        ],
                      ),
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

