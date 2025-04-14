import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import '../home/home_screen.dart';
import '../../config/app_theme.dart'; // Import AppTheme
// Import LoadingAnimation

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        print('Attempting to register with email: ${_emailController.text.trim()}');
        // Note: The parameter order matters here - email, password, firstname, lastname
        await _authService.register(
          _emailController.text.trim(),
          _passwordController.text,
          _firstnameController.text.trim(),
          _lastnameController.text.trim(),
        );

        if (mounted) {
          // Navigate to home screen and remove all previous routes
          NavigationService.navigateToAndRemoveUntil(const HomeScreen());
        }
      } catch (e) {
        print('Registration error: $e');
        setState(() {
          // Extract a more user-friendly error message
          if (e.toString().contains('Failed to register')) {
            // Try to extract the server error message if available
            final errorStart = e.toString().indexOf('Failed to register: ') + 'Failed to register: '.length;
            final serverMessage = e.toString().substring(errorStart);

            try {
              // Try to parse as JSON if possible
              if (serverMessage.contains('"message"')) {
                final messageStart = serverMessage.indexOf('"message"') + '"message"'.length + 2;
                final messageEnd = serverMessage.indexOf('"', messageStart);
                _errorMessage = serverMessage.substring(messageStart, messageEnd);
              } else if (serverMessage.contains('duplicate key')) {
                _errorMessage = 'Email already exists. Please try a different one.';
              } else {
                _errorMessage = 'Registration failed. Please try again.';
              }
            } catch (_) {
              _errorMessage = 'Registration failed. Please try again.';
            }
          } else if (e.toString().contains('Connection refused') ||
                     e.toString().contains('Failed host lookup') ||
                     e.toString().contains('Network is unreachable')) {
            _errorMessage = 'Cannot connect to the server. Please check your internet connection.';
          } else {
            _errorMessage = 'Registration failed. Please try again.';
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
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColorLight,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Create Account'),
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
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
                  // First name field
                  TextFormField(
                    controller: _firstnameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      hintText: 'Enter your first name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorLight,
                      prefixIcon: const Icon(Icons.person, color: AppTheme.lightTextColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Last name field
                  TextFormField(
                    controller: _lastnameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      hintText: 'Enter your last name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceColorLight,
                      prefixIcon: const Icon(Icons.person, color: AppTheme.lightTextColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
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
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
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

                  // Register button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
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
                        : const Text('Register'),
                  ),
                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?', style: TextStyle(color: AppTheme.lightTextColor)),
                      TextButton(
                        onPressed: () => NavigationService.goBack(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child: const Text('Login'),
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