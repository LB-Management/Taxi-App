// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/main.dart';

void main() {
  testWidgets('Auth screen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxiApp());

    expect(find.text('Welcome to Yellow & Black Taxi'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
  });

  testWidgets('Login form validation', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxiApp());
    await tester.tap(find.text('Login'));
    await tester.pump();

    // Try to submit empty form
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}