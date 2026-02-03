import 'package:flutter/material.dart';
import 'package:commongrounds/widgets/starting_button.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:commongrounds/widgets/starting_textfield.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToSignUpPage() {
    Navigator.of(context).pushReplacementNamed('/signUp');
  }

  void _goToMainPage() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required!'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address!'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password is required!'), backgroundColor: Colors.red),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters!'), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in successful!'), backgroundColor: Colors.green),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pushReplacementNamed('/main');
    });
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Forgot Password clicked!"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.navbar.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: -150,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.navbar.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.navbar.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -140,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.navbar.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Transform.translate(
                      offset: const Offset(0, -60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 80,
                            height: 80,
                            child: Center(
                              child: Icon(
                                Symbols.owl,
                                size: 80,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ),
                          Text('Welcome Back!', style: AppTypography.heading1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Focus. Plan. Achieve',
                              textAlign: TextAlign.center,
                              style: AppTypography.heading2,
                            ),
                          ),
                          const SizedBox(height: 30),

                          CustomTextField(
                            label: 'Email',
                            prefixIcon: Icons.email,
                            controller: _emailController,
                            width: 350,
                          ),
                          CustomTextField(
                            label: 'Password',
                            prefixIcon: Icons.lock,
                            obscureText: true,
                            controller: _passwordController,
                            width: 350,
                          ),

                          const SizedBox(height: 10),

                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: 350,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _goToSignUpPage,
                                    child: Text(
                                      "Don't have an account?",
                                      style: AppTypography.button.copyWith(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _forgotPassword,
                                    child: Text(
                                      "Forgot Password?",
                                      style: AppTypography.button.copyWith(
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: CustomButton(
                              text: 'Sign In',
                              onPressed: _goToMainPage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

