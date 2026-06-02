import 'package:diegapp/widgets/glass_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GlassTextField', () {
    testWidgets('muestra initialValue al construirse', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassTextField(
              label: 'Especialista',
              initialValue: 'Lagu',
            ),
          ),
        ),
      );
      expect(find.text('Lagu'), findsOneWidget);
    });

    testWidgets('acepta texto vacío si initialValue es vacío', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassTextField(label: 'X', initialValue: ''),
          ),
        ),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller!.text, '');
    });

    testWidgets('actualiza el texto cuando cambia initialValue', (tester) async {
      String? currentValue = 'uno';
      late StateSetter outerSetState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                outerSetState = setState;
                return GlassTextField(
                  label: 'X',
                  initialValue: currentValue,
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('uno'), findsOneWidget);

      outerSetState(() => currentValue = 'dos');
      await tester.pump();

      expect(find.text('dos'), findsOneWidget);
      expect(find.text('uno'), findsNothing);
    });

    testWidgets('respeta controller externo', (tester) async {
      final controller = TextEditingController(text: 'externo');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTextField(
              label: 'X',
              controller: controller,
            ),
          ),
        ),
      );
      expect(find.text('externo'), findsOneWidget);
    });

    testWidgets('onChanged se dispara al escribir', (tester) async {
      String? changed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassTextField(
              label: 'X',
              initialValue: 'a',
              onChanged: (v) => changed = v,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      expect(changed, 'abc');
    });
  });
}
