import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/core/constants/avatars.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../widgets/user_avatar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;
  String? _selectedAvatar;
  bool _isLoading = false;
  UserEntity? _originalUser;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();
    
    _usernameController.addListener(_onFieldChanged);
    _displayNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onFieldChanged);
    _displayNameController.removeListener(_onFieldChanged);
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  bool _hasChanges(UserEntity user) {
    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();
    
    return username != user.username ||
        displayName != user.displayName ||
        _selectedAvatar != user.photoURL;
  }

  void _handleSave() {
    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (username.isEmpty) {
      _showError('Username cannot be empty');
      return;
    }

    if (displayName.isEmpty) {
      _showError('Display name cannot be empty');
      return;
    }

    if (username.length < 3) {
      _showError('Username must be at least 3 characters');
      return;
    }

    if (username.length > 30) {
      _showError('Username must be at most 30 characters');
      return;
    }

    final state = context.read<AuthCubit>().state;
    if (state is! Authenticated) {
      _showError('Not authenticated');
      return;
    }

    setState(() {
      _isLoading = true;
      _originalUser = state.user;
    });

    context.read<AuthCubit>().updateUser(
          id: state.user.id,
          username: username != state.user.username ? username : null,
          displayName: displayName != state.user.displayName ? displayName : null,
          photoURL: _selectedAvatar != state.user.photoURL ? _selectedAvatar : null,
        );
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final wasLoading = _isLoading;
          setState(() {
            _isLoading = false;
          });
          
          if (state.errorMessage != null) {
            showCupertinoDialog(
              context: context,
              builder: (dialogContext) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text(state.errorMessage!),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (context.mounted) {
                        context.read<AuthCubit>().clearError();
                      }
                    },
                  ),
                ],
              ),
            );
          } else if (wasLoading && _originalUser != null) {
            final userChanged = state.user.username != _originalUser!.username ||
                state.user.displayName != _originalUser!.displayName ||
                state.user.photoURL != _originalUser!.photoURL;
            
            if (userChanged) {
              Navigator.pop(context);
            }
          }
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false;
          });
          _showError(state.message);
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) {
          return CupertinoPageScaffold(
            navigationBar: const AppNavBar(title: 'Edit Profile'),
            child: const Center(
              child: Text('Not authenticated'),
            ),
          );
        }

        if (!_isInitialized) {
          _usernameController.text = state.user.username;
          _displayNameController.text = state.user.displayName;
          _selectedAvatar = state.user.photoURL;
          _isInitialized = true;
        }

        final hasChanges = _hasChanges(state.user);

        return CupertinoPageScaffold(
          navigationBar: AppNavBar(
            title: 'Edit Profile',
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            trailing: _isLoading
                ? const CupertinoActivityIndicator()
                : hasChanges
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text('Save'),
                        onPressed: _handleSave,
                      )
                    : null,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    AppText.h3('Choose Avatar'),
                    const SizedBox(height: 16),
                    Center(
                      child: UserAvatar(
                        imageUrl: _selectedAvatar,
                        size: 120,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: Avatars.availableAvatars.length,
                      itemBuilder: (context, index) {
                        final avatarPath = Avatars.availableAvatars[index];
                        final isSelected = _selectedAvatar == avatarPath;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = avatarPath;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? CupertinoColors.activeBlue
                                    : CupertinoColors.systemGrey4,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                avatarPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: CupertinoColors.systemGrey5,
                                    child: const Icon(
                                      CupertinoIcons.person_fill,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    AppText.bodyLargeBold('Username'),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _usernameController,
                      placeholder: 'Enter username',
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppText.bodyLargeBold('Display Name'),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _displayNameController,
                      placeholder: 'Enter display name',
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
