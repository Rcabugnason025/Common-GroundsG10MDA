import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:commongrounds/services/auth_service.dart';
import 'package:commongrounds/widgets/starting_button.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:commongrounds/widgets/starting_textfield.dart';
import 'package:commongrounds/pages/sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    _courseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _goToMainPage() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name is required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email is required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password is required!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm your password!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call AuthService
    final success = await AuthService().signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      course: _courseController.text.trim().isNotEmpty
          ? _courseController.text.trim()
          : "BS Computer Science",
=======
  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
>>>>>>> eb9db82089c4d3903b07165166fb444bd9297a63
    );
  }

<<<<<<< HEAD
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign up successful!'),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.of(context).pushReplacementNamed('/main');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email already exists!'),
          backgroundColor: Colors.red,
        ),
      );
=======
  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

    // ---------- VALIDATION ----------
    if (name.isEmpty) return _showSnack('Name is required!', Colors.red);
    if (email.isEmpty) return _showSnack('Email is required!', Colors.red);
    if (!emailRegex.hasMatch(email)) {
      return _showSnack('Enter a valid email address!', Colors.red);
    }
    if (password.isEmpty) return _showSnack('Password is required!', Colors.red);
    if (password.length < 6) {
      return _showSnack('Password must be at least 6 characters!', Colors.red);
    }
    if (password != confirm) {
      return _showSnack('Passwords do not match!', Colors.red);
    }

    setState(() => _loading = true);

    try {
      // ---------- FIREBASE AUTH SIGN UP ----------
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // ✅ Create / update profile doc per account
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fullName': name,
          'email': email,
          'bio': '',
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
        },
        SetOptions(merge: true),
      );

      // ✅ Flow #2: sign out, then they sign in manually
      await FirebaseAuth.instance.signOut();

      _showSnack('Account created! Please sign in.', Colors.green);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Sign up failed. Please try again.';
      if (e.code == 'email-already-in-use') msg = 'Email is already registered.';
      if (e.code == 'invalid-email') msg = 'Invalid email address.';
      if (e.code == 'weak-password') msg = 'Password is too weak.';
      if (e.code == 'operation-not-allowed') {
        msg = 'Email/password sign-up is disabled in Firebase.';
      }
      _showSnack(msg, Colors.red);
    } catch (e) {
      _showSnack('Something went wrong. Try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
>>>>>>> eb9db82089c4d3903b07165166fb444bd9297a63
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
<<<<<<< HEAD

      body: Stack(
        children: [
          // Background circles
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

          // Content
          Center(
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            const Icon(
                              Symbols.owl,
                              size: 80,
                              color: Color(0xFF0D47A1),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Create Account',
                              style: AppTypography.heading1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Focus. Plan. Achieve',
                              textAlign: TextAlign.center,
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
                              label: 'Course / Year (e.g. BSCS - 2nd Year)',
                              controller: _courseController,
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
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: CustomButton(
                                text: 'Sign Up',
                                onPressed: _goToMainPage,
                              ),
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
        ],
      ),
    );
  }
}
