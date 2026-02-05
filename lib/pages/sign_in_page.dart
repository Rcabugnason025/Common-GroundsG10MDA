import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:commongrounds/widgets/starting_button.dart';
import 'package:commongrounds/widgets/starting_textfield.dart';
import 'package:commongrounds/pages/sign_up_page.dart';
import 'package:commongrounds/pages/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  Future<void> _signIn() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

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

  setState(() => _loading = true);

  try {
    // ✅ Sign in
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      _showSnack('Sign in failed. Try again.', Colors.red);
      return;
    }

    // ✅ Ensure Firestore profile doc exists (important!)
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      await docRef.set({
        'fullName': user.displayName ?? '',
        'email': user.email ?? email,
        'bio': '',
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
      }, SetOptions(merge: true));
    }

    if (!mounted) return;

    _showSnack('Sign in successful!', Colors.green);

    // ✅ Go to MainPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
    );
  } on FirebaseAuthException catch (e) {
    String msg = 'Sign in failed.';
    if (e.code == 'user-not-found') msg = 'No account found for that email.';
    else if (e.code == 'wrong-password') msg = 'Wrong password.';
    else if (e.code == 'invalid-credential') msg = 'Incorrect email or password.';
    else if (e.code == 'invalid-email') msg = 'Invalid email.';
    else if (e.code == 'user-disabled') msg = 'This account has been disabled.';

    if (mounted) _showSnack(msg, Colors.red);
  } catch (e) {
    debugPrint('Sign in error: $e');
    if (mounted) _showSnack('Something went wrong. Try again.', Colors.red);
  } finally {
    if (mounted) setState(() => _loading = false);
  }
  }

  void _forgotPassword() {
    _showSnack('Forgot Password clicked!', Colors.blue);
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
                    const Icon(
                      Symbols.owl,
                      size: 80,
                      color: Color(0xFF0D47A1),
                    ),
                    Text('Welcome Back!',
                        style: AppTypography.heading1),
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
                            onPressed: _loading ? null : _goToSignUpPage,
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

                    CustomButton(
                      text: _loading ? 'Signing in...' : 'Sign In',
                      onPressed: _loading ? null : _signIn,
                    ),
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
