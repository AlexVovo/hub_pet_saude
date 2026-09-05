// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:hub_pet_saude/main.dart';

void main() {
  testWidgets('renders the Conecta Onco hub', (WidgetTester tester) async {
    await tester.pumpWidget(const PetSaudeApp());

    expect(find.textContaining('Tudo do Conecta Onco'), findsOneWidget);
    expect(find.text('Apresentações'), findsOneWidget);
    expect(find.text('Áreas do hub'), findsOneWidget);
  });
}
