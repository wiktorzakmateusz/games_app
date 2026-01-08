import 'package:flutter/cupertino.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../core/utils/responsive_layout.dart';
import '../core/utils/device_type.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = DeviceTypeHelper.isTablet(context);
    final gameImageSize = isTablet ? 180.0 : 150.0;
    
    return CupertinoPageScaffold(
      navigationBar: AppMenuNavBar(
        title: 'Local Games',
        onBackPressed: () {
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ResponsiveLayout.constrainWidth(
              context,
              Padding(
                padding: ResponsiveLayout.getPadding(context),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                    AppText.h2('Select a game'),
                    SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: ResponsiveLayout.getSpacing(context) * 2,
                      runSpacing: ResponsiveLayout.getSpacing(context) * 1.5,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/game_player_settings',
                            arguments: 'tic_tac_toe'),
                          child: Column(
                            children: [
                              Image.asset('images/tic_tac_toe.png',
                                  width: gameImageSize, height: gameImageSize),
                              SizedBox(height: ResponsiveLayout.getSpacing(context) * 0.5),
                              AppText.h5('Tic-Tac-Toe'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/game_difficulty_settings',
                            arguments: 'mini_sudoku'),
                          child: Column(
                            children: [
                              Image.asset('images/mini_sudoku.png',
                                  width: gameImageSize, height: gameImageSize),
                              SizedBox(height: ResponsiveLayout.getSpacing(context) * 0.5),
                              AppText.h5('Mini Sudoku'),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/game_player_settings',
                            arguments: 'connect4'),
                          child: Column(
                            children: [
                              Image.asset('images/connect_4.jpeg',
                                  width: gameImageSize, height: gameImageSize),
                              SizedBox(height: ResponsiveLayout.getSpacing(context) * 0.5),
                              AppText.h5('Connect 4'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
