import 'package:flutter/material.dart';
import 'package:commongrounds/services/auth_service.dart';
import 'package:commongrounds/widgets/starting_button.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:commongrounds/widgets/starting_textfield.dart';
import 'package:commongrounds/pages/sign_up_page.dart';
import 'package:commongrounds/pages/main_page.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  Future<void> _goToMainPage() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password is required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call AuthService
    final success = await AuthService().signIn(email, password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pushReplacementNamed('/main');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot Password clicked!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Symbols.owl, size: 80, color: Color(0xFF0D47A1)),
                    Text('Welcome Back!', style: AppTypography.heading1),
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

                    SizedBox(
                      width: 350,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: _goToSignUpPage,
                            child: const Text("Don't have an account?"),
                          ),
                          TextButton(
                            onPressed: _forgotPassword,
                            child: const Text("Forgot Password?"),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    CustomButton(text: 'Sign In', onPressed: _goToMainPage),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
