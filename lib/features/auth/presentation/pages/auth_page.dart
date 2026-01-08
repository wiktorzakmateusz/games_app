import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:games_app/widgets/app_text.dart';
import 'package:games_app/widgets/navigation/navigation_bars.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/utils/responsive_layout.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (!_isLogin && username.isEmpty) {
      _showError('Please enter a username');
      return;
    }

    final cubit = context.read<AuthCubit>();

    if (_isLogin) {
      cubit.signIn(email: email, password: password);
    } else {
      cubit.signUp(email: email, password: password, username: username);
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: AppText.bodyMedium('Error'),
        content: AppText.bodySmall(message),
        actions: [
          CupertinoDialogAction(
            child: AppText.bodyMedium('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: AppMenuNavBar(
        title: _isLogin ? 'Sign In' : 'Sign Up',
        onBackPressed: () => Navigator.pop(context),
      ),
      child: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              // Navigate to lobby list
              Navigator.pushReplacementNamed(context, '/lobby_list');
            } else if (state is AuthError) {
              _showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return ResponsiveLayout.constrainWidth(
              context,
              SingleChildScrollView(
                padding: ResponsiveLayout.getPadding(context),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: ResponsiveLayout.getMaxContentWidth(context).clamp(300, 500)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                        AppText.h2('Welcome to Multiplayer'),
                        SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                        if (!_isLogin) ...[
                          CupertinoTextField(
                            controller: _usernameController,
                            placeholder: 'Username',
                            enabled: !isLoading,
                            padding: EdgeInsets.all(ResponsiveLayout.getSpacing(context)),
                            decoration: BoxDecoration(
                              border: Border.all(color: CupertinoColors.separator),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          SizedBox(height: ResponsiveLayout.getSpacing(context)),
                        ],
                        CupertinoTextField(
                          controller: _emailController,
                          placeholder: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          padding: EdgeInsets.all(ResponsiveLayout.getSpacing(context)),
                          decoration: BoxDecoration(
                            border: Border.all(color: CupertinoColors.separator),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: ResponsiveLayout.getSpacing(context)),
                        CupertinoTextField(
                          controller: _passwordController,
                          placeholder: 'Password',
                          obscureText: true,
                          enabled: !isLoading,
                          padding: EdgeInsets.all(ResponsiveLayout.getSpacing(context)),
                          decoration: BoxDecoration(
                            border: Border.all(color: CupertinoColors.separator),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(height: ResponsiveLayout.getSpacing(context) * 1.5),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton.filled(
                            onPressed: isLoading ? null : _handleAuth,
                            child: isLoading
                                ? const CupertinoActivityIndicator(
                                    color: CupertinoColors.white,
                                  )
                                : AppText.button(_isLogin ? 'Sign In' : 'Sign Up'),
                          ),
                        ),
                        SizedBox(height: ResponsiveLayout.getSpacing(context)),
                        CupertinoButton(
                          onPressed: isLoading ? null : _toggleMode,
                          child: AppText.bodyMedium(
                            _isLogin
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Sign In'
                          ),
                        ),
                        SizedBox(height: ResponsiveLayout.getLargeSpacing(context)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

