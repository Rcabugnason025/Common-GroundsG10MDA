import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:commongrounds/pages/sign_in_page.dart';
import 'package:commongrounds/pages/dashboard_page.dart';

void main() {
  testWidgets('App smoke test - Verify Sign In Page renders', (
    WidgetTester tester,
  ) async {
    // Build SignInPage directly
    await tester.pumpWidget(const MaterialApp(home: SignInPage()));

    // Verify that the Sign In page is displayed
    expect(find.text('Sign In'), findsWidgets); // Finds title and button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify buttons exist
    expect(find.byType(ElevatedButton), findsWidgets);
  });

  testWidgets('Dashboard displays mock data tasks', (
    WidgetTester tester,
  ) async {
    // Set a larger screen size to avoid overflow in tests
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    // Build DashboardPage directly
    await tester.pumpWidget(const MaterialApp(home: DashboardPage()));

    // Verify that the static/mock data is loaded and displayed
    // "Mobile Development Fundamentals" is a subject in the mock data
    expect(find.text('Mobile Development Fundamentals'), findsWidgets);

    // Reset size
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
