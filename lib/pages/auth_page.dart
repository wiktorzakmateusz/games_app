import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/game_button.dart';

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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        // Sign in with Firebase
        await authService.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        // Check if user exists in backend, create if not
        final user = authService.currentUser;
        if (user != null) {
          try {
            // Try to get user from backend
            await userService.getUserByFirebaseUid(user.uid);
          } catch (e) {
            // User doesn't exist in backend, create them
            // Use email username as fallback if displayName is null
            final emailUsername = user.email?.split('@').first ?? 'user';
            final username = user.displayName ?? 
                           emailUsername ?? 
                           'user_${user.uid.substring(0, 8)}';
            await userService.createUser(
              firebaseUid: user.uid,
              email: user.email ?? _emailController.text.trim(),
              username: username,
              displayName: user.displayName ?? username,
              photoURL: user.photoURL,
            );
          }
        }
      } else {
        // Sign up
        if (_usernameController.text.trim().isEmpty) {
          setState(() {
            _errorMessage = 'Please enter a username';
            _isLoading = false;
          });
          return;
        }
        
        // Create Firebase user
        final userCredential = await authService.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Failed to create Firebase user');
        }
        
        // Create user in backend database
        await userService.createUser(
          firebaseUid: user.uid,
          email: user.email ?? _emailController.text.trim(),
          username: _usernameController.text.trim(),
          displayName: _usernameController.text.trim(),
          photoURL: user.photoURL,
        );
      }

      // Navigate to lobby list
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/lobby_list');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _isLogin
            ? 'Failed to sign in. Please check your credentials.'
            : 'Failed to sign up. ${e.toString().contains('already') ? "Email or username may already be in use." : "Please try again."}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Check if user is already logged in
    if (authService.isLoggedIn) {
      // Redirect to lobby list if already logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/lobby_list');
      });
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isLogin ? 'Sign In' : 'Sign Up'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to Multiplayer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              if (!_isLogin) ...[
                CupertinoTextField(
                  controller: _usernameController,
                  placeholder: 'Username',
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: CupertinoColors.separator),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                keyboardType: TextInputType.emailAddress,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.separator),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.destructiveRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _isLoading ? null : _handleAuth,
                  child: _isLoading
                      ? const CupertinoActivityIndicator()
                      : Text(_isLogin ? 'Sign In' : 'Sign Up'),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _emailController.clear();
                          _passwordController.clear();
                          _usernameController.clear();
                        });
                      },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Sign In',
                  style: const TextStyle(
                    color: CupertinoColors.activeBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

