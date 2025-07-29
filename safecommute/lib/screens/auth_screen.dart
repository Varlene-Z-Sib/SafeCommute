import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _signUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();

  // Sign Up Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Sign In Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSignInPasswordVisible = false;
  bool _rememberMe = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Section
              Container(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primarySafetyGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shield, color: Colors.white, size: 40),
                    ),
                    SizedBox(height: 16),

                    // App Title
                    Text(
                      'SafeCommute',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.primarySafetyGreen,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(height: 8),

                    // Tagline
                    Text(
                      'Your Safety, Our Priority',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 16),

                    // Value Proposition
                    Text(
                      'Join thousands of commuters staying safe together',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Guest Access Option pre auth configuration
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/home'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: Size(double.infinity, 48),
                  ),
                  child: Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: 24),

              // Auth Tabs
              Container(
                margin: EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.primarySafetyGreen,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textDark,
                  tabs: [
                    Tab(text: 'Sign Up'),
                    Tab(text: 'Sign In'),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Tab Views
              SizedBox(
                height: 500,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildSignUpForm(), _buildSignInForm()],
                ),
              ),

              // Privacy Notice
              Container(
                margin: EdgeInsets.all(32),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primarySafetyGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock,
                      color: AppColors.primarySafetyGreen,
                      size: 24,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your location data stays private and secure',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primarySafetyGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We only collect data necessary for your safety',
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _signUpFormKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
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
            SizedBox(height: 16),

            // Phone Number Field (Optional)
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number (Optional)',
                prefixIcon: Icon(Icons.phone),
                helperText: 'For emergency features',
              ),
            ),
            SizedBox(height: 16),

            // Terms & Conditions Checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeToTerms = !_agreeToTerms;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Privacy Policy',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _agreeToTerms ? _signUp : null,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account'),
              ),
            ),
            SizedBox(height: 16),

            // Social Sign Up
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _signInFormKey,
        child: Column(
          children: [
            // Email Field
            TextFormField(
              controller: _signInEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Password Field
            TextFormField(
              controller: _signInPasswordController,
              obscureText: !_isSignInPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isSignInPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSignInPasswordVisible = !_isSignInPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Remember Me & Forgot Password
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
                Text('Remember me'),
                Spacer(),
                TextButton(
                  onPressed: _forgotPassword,
                  child: Text('Forgot Password?'),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _signIn,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign In'),
              ),
            ),
            SizedBox(height: 16),

            // Social Sign In
            _buildSocialButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        Text('Or continue with', style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _signInWithGoogle,
                icon: Icon(Icons.g_mobiledata, color: Colors.red),
                label: Text('Google'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _signInWithFacebook,
                icon: Icon(Icons.facebook, color: Colors.blue),
                label: Text('Facebook'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (_signUpFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _signIn() async {
    if (_signInFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _signInWithGoogle() {
    // Implement Google Sign In
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Google Sign In - Coming Soon')));
  }

  void _signInWithFacebook() {
    // Implement Facebook Sign In
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Facebook Sign In - Coming Soon')));
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email to receive password reset instructions.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset email sent')),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
}
