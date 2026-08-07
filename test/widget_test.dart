import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:accounting/main.dart';

void main() {
  testWidgets('App renders landing page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('ENTERPRISE ACCOUNTING'), findsOneWidget);
  });
}
