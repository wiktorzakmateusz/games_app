import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Needed for some extra icons
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Variables to manage switches (aesthetic only for now)
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;
  
  // Changed to false as requested: notifications disabled by default
  bool _notificationsEnabled = false; 

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground, // Typical iOS settings gray color
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            
            // User Data
            String displayName = "Guest";
            String email = "Not logged in";
            bool isLoggedIn = false;

            if (state is Authenticated) {
              displayName = state.user.email.split('@')[0];
              email = state.user.email;
              isLoggedIn = true;
            }

            return ListView(
              children: [
                const SizedBox(height: 20),

                // --- PROFILE SECTION ---
                Container(
                  color: CupertinoColors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isLoggedIn ? CupertinoIcons.person_crop_circle_fill : CupertinoIcons.person_crop_circle,
                        size: 60,
                        color: isLoggedIn ? CupertinoColors.activeBlue : CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: CupertinoColors.systemGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- PREFERENCES SECTION (SWITCHES) ---
                CupertinoListSection.insetGrouped(
                  header: const Text('PREFERENCES'),
                  children: [
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.speaker_2_fill, color: CupertinoColors.systemPink),
                      title: const Text('Sound Effects'),
                      trailing: CupertinoSwitch(
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.device_phone_portrait, color: CupertinoColors.systemOrange),
                      title: const Text('Haptic Feedback'),
                      trailing: CupertinoSwitch(
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        },
                      ),
                    ),
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.bell_fill, color: CupertinoColors.systemRed),
                      title: const Text('Notifications'),
                      trailing: CupertinoSwitch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),

// --- ABOUT SECTION (MODIFIED) ---
                CupertinoListSection.insetGrouped(
                  header: const Text('ABOUT'),
                  children: [
                    const CupertinoListTile(
                      leading: Icon(CupertinoIcons.info_circle_fill, color: CupertinoColors.systemBlue),
                      title: Text('App Version'),
                      additionalInfo: Text('1.0.0 (Beta)'),
                    ),
                    
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.doc_text_fill, color: CupertinoColors.systemGrey),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(CupertinoIcons.right_chevron, size: 14, color: CupertinoColors.systemGrey3),
                      onTap: () {
                        // Opens the Terms of Service dialog
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text('Terms of Service'),
                            content: const SingleChildScrollView(
                              child: Text(
                                '\nLorem ipsum dolor sit amet, consectetur adipiscing elit. '
                                'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n\n'
                                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n'
                                'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Close'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- LOGOUT BUTTON ---
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      child: const Text('Log Out'),
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pop(context);
                      },
                    ),
                  ),

                if (!isLoggedIn)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Login is currently disabled for maintenance. Please play as Guest.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CupertinoColors.systemGrey),
                    ),
                  ),
                  
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}