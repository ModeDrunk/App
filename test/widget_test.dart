// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drunk_mode/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ModoBorrachoApp(),
      ),
    );

    // Verify that the app shows something (no crash)
    expect(find.byType(ModoBorrachoApp), findsOneWidget);
  });
}
