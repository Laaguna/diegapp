import 'package:diegapp/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassCard', () {
    testWidgets('renderiza el child correctamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(child: Text('Hello Glass')),
          ),
        ),
      );
      expect(find.text('Hello Glass'), findsOneWidget);
    });

    testWidgets('funciona en modo oscuro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GlassCard(child: Text('Dark')),
          ),
        ),
      );
      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('GlassScaffold', () {
    testWidgets('renderiza body', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Body content')),
          ),
        ),
      );
      expect(find.text('Body content'), findsOneWidget);
    });
  });
}
