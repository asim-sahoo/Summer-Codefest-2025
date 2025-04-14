import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';
import '../../config/app_theme.dart'; // Import AppTheme
// Import LoadingAnimation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        print('Attempting to login with email: ${_emailController.text.trim()}');
        await _authService.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (mounted) {
          // Navigate to home screen and remove all previous routes
          NavigationService.navigateToAndRemoveUntil(const HomeScreen());
        }
      } catch (e) {
        print('Login error: $e');
        setState(() {
          // Extract a more user-friendly error message
          if (e.toString().contains('Failed to login')) {
            // Try to extract the server error message if available
            final errorStart = e.toString().indexOf('Failed to login: ') + 'Failed to login: '.length;
            final serverMessage = e.toString().substring(errorStart);

            try {
              // Try to parse as JSON if possible
              if (serverMessage.contains('"message"')) {
                final messageStart = serverMessage.indexOf('"message"') + '"message"'.length + 2;
                final messageEnd = serverMessage.indexOf('"', messageStart);
                _errorMessage = serverMessage.substring(messageStart, messageEnd);
              } else {
                _errorMessage = 'Invalid email or password. Please try again.';
              }
            } catch (_) {
              _errorMessage = 'Invalid email or password. Please try again.';
            }
          } else if (e.toString().contains('Connection refused') ||
                     e.toString().contains('Failed host lookup') ||
                     e.toString().contains('Network is unreachable')) {
            _errorMessage = 'Cannot connect to the server. Please check your internet connection.';
          } else {
            _errorMessage = 'Login failed. Please try again.';
          }
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColorLight, // Set background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo or Title
                  // Text(
                  //   'WellSta',
                  //   textAlign: TextAlign.center,
                  //   style: theme.textTheme.headlineLarge?.copyWith(
                  //     color: AppTheme.primaryColor, // Use primary color
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // app logo
                  Image.asset(
                    'assets/logo.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorLight,
                      prefixIcon: const Icon(Icons.email, color: AppTheme.lightTextColor),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorLight,
                      prefixIcon: const Icon(Icons.lock, color: AppTheme.lightTextColor),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Error message
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Login button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.darkTextColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.darkTextColor,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?', style: TextStyle(color: AppTheme.lightTextColor)),
                      TextButton(
                        onPressed: () {
                          NavigationService.navigateTo(const RegisterScreen());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}