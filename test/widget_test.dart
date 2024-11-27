import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:timetab/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp()); // Retirez const si MyApp n'est pas constant

    // Vérifiez que notre compteur commence à 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Appuyez sur l'icône '+' et déclenchez un nouveau cadre.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Vérifiez que notre compteur a été incrémenté.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}