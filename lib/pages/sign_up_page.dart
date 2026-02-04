import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:commongrounds/widgets/starting_button.dart';
import 'package:commongrounds/widgets/starting_textfield.dart';
import 'package:commongrounds/pages/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final emailRegex =
        RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

    // ---------- VALIDATION ----------
    if (name.isEmpty) {
      _showSnack('Name is required!', Colors.red);
      return;
    }
    if (email.isEmpty) {
      _showSnack('Email is required!', Colors.red);
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      _showSnack('Enter a valid email address!', Colors.red);
      return;
    }
    if (password.isEmpty) {
      _showSnack('Password is required!', Colors.red);
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters!', Colors.red);
      return;
    }
    if (password != confirm) {
      _showSnack('Passwords do not match!', Colors.red);
      return;
    }

    setState(() => _loading = true);

    try {
      // ---------- FIREBASE SIGN UP ----------
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _showSnack(
        'Account created! Please sign in.',
        Colors.green,
      );

      // ✅ SAFE NAVIGATION (NO ROUTE ERRORS)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed.';
      if (e.code == 'email-already-in-use') {
        msg = 'Email is already registered.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else if (e.code == 'weak-password') {
        msg = 'Password is too weak.';
      } else if (e.code == 'operation-not-allowed') {
        msg = 'Email/password sign-up is disabled.';
      }

      if (mounted) _showSnack(msg, Colors.red);
    } catch (e) {
      debugPrint('Signup error: $e');
      if (mounted) {
        _showSnack('Something went wrong. Try again.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignInPage()),
            );
          },
        ),
      ),

      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Transform.translate(
                  offset: const Offset(0, -30),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(
                          Symbols.owl,
                          size: 80,
                          color: Color(0xFF0D47A1),
                        ),
                        const SizedBox(height: 10),
                        Text('Create Account',
                            style: AppTypography.heading1),
                        const SizedBox(height: 6),
                        Text(
                          'Focus. Plan. Achieve',
                          style: AppTypography.heading2,
                        ),
                        const SizedBox(height: 30),

                        CustomTextField(
                          label: 'Enter your full name',
                          controller: _nameController,
                          width: 350,
                        ),
                        CustomTextField(
                          label: 'Enter your email',
                          controller: _emailController,
                          width: 350,
                        ),
                        CustomTextField(
                          label: 'Enter password',
                          obscureText: true,
                          controller: _passwordController,
                          width: 350,
                        ),
                        CustomTextField(
                          label: 'Confirm password',
                          obscureText: true,
                          controller: _confirmPasswordController,
                          width: 350,
                        ),

                        const SizedBox(height: 20),
                        CustomButton(
                          text: _loading ? 'Creating...' : 'Sign Up',
                          onPressed: _loading ? null : () => _signUp(),
                        ),
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
