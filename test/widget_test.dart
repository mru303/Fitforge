import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitforge/main.dart';
import 'package:fitforge/providers/fitness_provider.dart';
import 'package:fitforge/screens/tabs/home_tab.dart';

void main() {
  testWidgets('dashboard shows premium overview content',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => FitnessProvider()),
        ],
        child: const MaterialApp(home: HomeTab()),
      ),
    );

    expect(find.text('Today’s Focus'), findsOneWidget);
    expect(find.text('FitForge'), findsOneWidget);
    expect(find.text('Weight This Week'), findsOneWidget);
  });
}
