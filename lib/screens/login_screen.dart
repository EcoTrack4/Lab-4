import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

/// Login Screen - Role-based login for Professional Hunters and Permit Officers
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'hunter'; // 'hunter' or 'officer'
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        if (response.user != null) {
          // Login successful - navigate to welcome screen
          // Role-based routing will be handled by auth gate
          context.go('/welcome');
        } else {
          _showError('Login failed. Invalid email or password.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),

                  // Logo
                  const AppLogo(
                    size: 100,
                    showText: true,
                  ),
                  const SizedBox(height: 40),

                  // Role Selection Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Your Role',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Choose the account type that matches your role',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Professional Hunter Option
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'hunter';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'hunter'
                                    ? AppColors.primaryGreen.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedRole == 'hunter'
                                      ? AppColors.primaryGreen
                                      : AppColors.borderGrey,
                                  width: _selectedRole == 'hunter' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Professional Hunter',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Submit and track hunt returns',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedRole == 'hunter')
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Permit Officer Option
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = 'officer';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'officer'
                                    ? AppColors.primaryGreen.withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedRole == 'officer'
                                      ? AppColors.primaryGreen
                                      : AppColors.borderGrey,
                                  width: _selectedRole == 'officer' ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Permit Officer',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.darkGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Review and approve returns',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.mediumGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_selectedRole == 'officer')
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Login Form Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Login to your account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Email address',
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryGreen,
                              ),
                              labelText: 'Email',
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.primaryGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                disabledBackgroundColor: AppColors.mediumGrey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Forgot Password
                  TextButton(
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '© 2026 EcoTrack Namibia\nWildlife Compliance Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
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
