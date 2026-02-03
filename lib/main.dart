import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';
import 'pages/sign_in_page.dart';
import 'pages/sign_up_page.dart';
import 'pages/main_page.dart';
import 'package:commongrounds/pages/focus_mode_page.dart';
import 'package:commongrounds/pages/wasi_page.dart';
import 'package:commongrounds/pages/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CommonGrounds',
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/signIn': (context) => const SignInPage(),
        '/signUp': (context) => const SignUpPage(),
        '/main': (context) => const MainPage(),
        '/focus': (context) => const FocusModePage(),
        '/wasi': (context) => const WasiPage(),
        '/calendar': (context) => const CalendarPage(),
      },
    );
  }
}
