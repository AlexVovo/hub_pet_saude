// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hub_pet_saude/datasus_oncology_service.dart';
import 'package:hub_pet_saude/main.dart';

void main() {
  testWidgets('renders the welcome section for the hub', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetSaudeApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Tudo do Conecta Onco'), findsOneWidget);
  });

  testWidgets('keeps the oncology dashboard hidden and the hub available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetSaudeApp());
    await tester.pumpAndSettle();

    expect(find.text('Oncologia geral | custos SIA/SIH'), findsNothing);
    expect(find.text('Apresentações'), findsOneWidget);
    expect(find.text('Artigos'), findsOneWidget);
  });

  testWidgets('shows a tooltip with the monthly value on hover', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PetSaudeApp());
    await tester.pumpAndSettle();

    expect(find.byType(Tooltip), findsWidgets);
  });

  test('supports every oncology year from 2015 through 2026', () {
    expect(
      OncologyDataService.supportedYears,
      List.generate(12, (index) => 2015 + index),
    );
  });

  test('parses DATASUS oncology CSV rows into normalized records', () {
    const csv = '''
ano,regiao,tipo_neoplasia,sistema,custo
2024,Brasil,Oncologia geral,SIA,967000000
2024,Brasil,Oncologia geral,SIH,873000000
2024,Sudeste,Câncer de mama,SIA,520000000
''';

    final records = OncologyDataService.parseCsv(csv);

    expect(records.length, 3);
    expect(records.first.year, 2024);
    expect(records.first.region, 'Brasil');
    expect(records.first.system, 'SIA');
    expect(records.first.cost, 967000000);
    expect(records.last.tumorType, 'Câncer de mama');
  });

  test('preserves the DATASUS monthly competency', () {
    const csv = '''
ano,mes,regiao,tipo_neoplasia,sistema,custo
2026,7,Brasil,Oncologia geral,SIA,1000
''';

    final records = OncologyDataService.parseCsv(csv);

    expect(records.single.year, 2026);
    expect(records.single.month, 7);
  });

  test('parses DATASUS JSON summary rows into normalized records', () {
    const json = '''
{
  "generatedAt": "2024-01-01T00:00:00Z",
  "totalRecords": 2,
  "summary": [
    {"year": 2024, "region": "Brasil", "tumorType": "Oncologia geral", "system": "SIA", "cost": 967000000},
    {"year": 2024, "region": "Brasil", "tumorType": "Oncologia geral", "system": "SIH", "cost": 873000000}
  ]
}
''';

    final records = OncologyDataService.parseSummaryJson(json);

    expect(records.length, 2);
    expect(records.first.system, 'SIA');
    expect(records.first.month, 0);
    expect(records.first.cost, 967000000);
    expect(records.last.system, 'SIH');
  });
}
