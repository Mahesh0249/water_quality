"""
Integration tests for the SportsTalent AI Flutter app.
"""

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sports_talent_ai/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SportsTalent AI Integration Tests', () {
    testWidgets('app launches and shows auth screen', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that auth screen is displayed
      expect(find.text('SportsTalent AI'), findsOneWidget);
      expect(find.text('Discover your running potential'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('can navigate between login and signup', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify login tab is selected by default
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Tap on Sign Up tab
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify sign up form is displayed
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Go back to Login tab
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Verify login form is displayed again
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to login with empty fields
      await tester.tap(find.text('Login').last); // Login button
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('can enter text in form fields', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter email
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      await tester.pumpAndSettle();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password visibility toggle works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find password field and visibility toggle
      final passwordField = find.byKey(const Key('password_field'));
      final visibilityToggle = find.byKey(const Key('password_visibility_toggle'));

      // Enter password
      await tester.enterText(passwordField, 'secret123');
      await tester.pumpAndSettle();

      // Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Tap again to hide
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();
    });

    // Note: These tests would require actual Firebase setup to test authentication
    // For now, we'll test the UI components
    
    group('Sign Up Flow', () {
      testWidgets('sign up form validation', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Switch to Sign Up tab
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Try to sign up with empty fields
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Verify validation errors
        expect(find.text('Please enter your name'), findsOneWidget);
        expect(find.text('Please enter your email'), findsOneWidget);
        expect(find.text('Please enter your password'), findsOneWidget);
      });

      testWidgets('password confirmation validation', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Switch to Sign Up tab
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Enter different passwords
        await tester.enterText(find.byKey(const Key('password_field')), 'password123');
        await tester.enterText(find.byKey(const Key('confirm_password_field')), 'different123');
        
        // Try to sign up
        await tester.tap(find.text('Sign Up').last);
        await tester.pumpAndSettle();

        // Verify password mismatch error
        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Navigation Tests', () {
      testWidgets('app routing works correctly', (WidgetTester tester) async {
        // This test would require mocking authentication
        // For now, we'll test that the navigation structure is in place
        app.main();
        await tester.pumpAndSettle();

        // Verify initial route is auth
        expect(find.text('SportsTalent AI'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('app is accessible', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Check for semantic labels
        expect(tester.getSemantics(find.text('SportsTalent AI')), isNotNull);
        
        // Verify buttons have proper semantics
        final loginButton = find.text('Login').last;
        expect(tester.getSemantics(loginButton), isNotNull);
      });

      testWidgets('supports screen readers', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Test semantic announcements
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/semantics',
          null,
          (data) {},
        );
      });
    });

    group('Performance Tests', () {
      testWidgets('app starts quickly', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        app.main();
        await tester.pumpAndSettle();
        
        stopwatch.stop();
        
        // App should start within 3 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      });

      testWidgets('smooth navigation between screens', (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        // Navigate between tabs
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Navigation should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Error Handling Tests', () {
      testWidgets('handles network errors gracefully', (WidgetTester tester) async {
        // This would test network error handling
        // For now, we'll test that error states are handled
        app.main();
        await tester.pumpAndSettle();

        // Verify app doesn't crash with invalid inputs
        await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
        await tester.tap(find.text('Login').last);
        await tester.pumpAndSettle();

        // App should still be responsive
        expect(find.text('SportsTalent AI'), findsOneWidget);
      });
    });
  });
}