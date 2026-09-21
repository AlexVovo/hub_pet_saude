import 'dart:convert';

import 'package:flutter/services.dart';

class DatSusOncologyRecord {
  const DatSusOncologyRecord({
    required this.year,
    required this.month,
    required this.region,
    required this.tumorType,
    required this.system,
    required this.cost,
  });

  final int year;
  final int month;
  final String region;
  final String tumorType;
  final String system;
  final double cost;

  factory DatSusOncologyRecord.fromCsvRow(List<String> row) {
    if (row.length < 5) {
      throw const FormatException(
        'Linha CSV inválida para registro de oncologia.',
      );
    }

    final hasMonth = row.length >= 6;
    final year = int.tryParse(row[0].trim()) ?? 0;
    final month = hasMonth ? int.tryParse(row[1].trim()) ?? 0 : 0;
    final offset = hasMonth ? 1 : 0;
    final region = row[1 + offset].trim();
    final tumorType = row[2 + offset].trim();
    final system = row[3 + offset].trim();
    final rawCost = row[4 + offset].trim();
    final value = double.tryParse(
      rawCost.replaceAll('.', '').replaceAll(',', '.'),
    );

    return DatSusOncologyRecord(
      year: year,
      month: month,
      region: region,
      tumorType: tumorType,
      system: system,
      cost: value ?? 0,
    );
  }

  factory DatSusOncologyRecord.fromSummaryJson(Map<String, dynamic> json) {
    final year = (json['year'] is int)
        ? json['year'] as int
        : int.tryParse('${json['year'] ?? 0}') ?? 0;
    final month = (json['month'] is int)
        ? json['month'] as int
        : int.tryParse('${json['month'] ?? 0}') ?? 0;
    final region = '${json['region'] ?? 'Brasil'}';
    final tumorType = '${json['tumorType'] ?? 'Oncologia geral'}';
    final system = '${json['system'] ?? 'GERAL'}';
    final rawCost = json['cost'];
    final cost = (rawCost is num)
        ? rawCost.toDouble()
        : double.tryParse('$rawCost') ?? 0.0;

    return DatSusOncologyRecord(
      year: year,
      month: month,
      region: region,
      tumorType: tumorType,
      system: system,
      cost: cost,
    );
  }
}

class DatSusSourceDefinition {
  const DatSusSourceDefinition({
    required this.name,
    required this.path,
    required this.description,
    required this.filePattern,
  });

  final String name;
  final String path;
  final String description;
  final String filePattern;
}

class DatSusSummaryMetadata {
  const DatSusSummaryMetadata({
    required this.status,
    required this.pendingFiles,
  });

  final String status;
  final int pendingFiles;

  bool get isComplete => status == 'complete' && pendingFiles == 0;
}

class OncologyDataService {
  static const ftpBaseUrl = 'ftp://ftp.datasus.gov.br/dissemin/publicos/';
  static const supportedYears = [
    2015,
    2016,
    2017,
    2018,
    2019,
    2020,
    2021,
    2022,
    2023,
    2024,
    2025,
    2026,
  ];

  static const List<DatSusSourceDefinition> officialDataSources = [
    DatSusSourceDefinition(
      name: 'Painel de oncologia',
      path: 'dissemin/publicos/painel_oncologia/Dados',
      description:
          'Público de referência para indicadores e dados oncológicos.',
      filePattern: 'POBR*.dbc',
    ),
    DatSusSourceDefinition(
      name: 'SIA',
      path: 'dissemin/publicos/SIASUS/200801_/Dados',
      description:
          'Arquivos do sistema de atendimentos ambulatoriais do DATASUS.',
      filePattern: '*.dbc',
    ),
    DatSusSourceDefinition(
      name: 'SIH',
      path: 'dissemin/publicos/SIHSUS/200801_/Dados',
      description:
          'Arquivos do sistema de internações hospitalares do DATASUS.',
      filePattern: '*.dbc',
    ),
  ];

  static List<DatSusOncologyRecord> parseCsv(String csv) {
    final rows = const LineSplitter()
        .convert(csv)
        .where((line) => line.trim().isNotEmpty)
        .toList();
    if (rows.length < 2) return const [];

    return rows.skip(1).map((line) {
      final cells = _splitCsvLine(line);
      return DatSusOncologyRecord.fromCsvRow(cells);
    }).toList();
  }

  static List<DatSusOncologyRecord> parseSummaryJson(String jsonString) {
    final trimmed = jsonString.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(trimmed);
    if (decoded is! Map<String, dynamic>) {
      return const [];
    }

    final summary = decoded['summary'];
    if (summary is! List) {
      return const [];
    }

    return summary
        .whereType<Map>()
        .map(
          (item) => DatSusOncologyRecord.fromSummaryJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static List<String> _splitCsvLine(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final current = line[i];
      if (current == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      if (current == ',' && !inQuotes) {
        cells.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(current);
    }

    cells.add(buffer.toString().trim());
    return cells;
  }

  static Future<List<DatSusOncologyRecord>> loadSummaryAsset() async {
    try {
      final source = await rootBundle.loadString(
        'assets/data/oncologia_summary.json',
      );
      final records = parseSummaryJson(source);
      if (records.isNotEmpty) {
        return records;
      }
    } catch (_) {
      // Ignore and fallback to demo source when the real asset is absent.
    }

    return const [];
  }

  static Future<DatSusSummaryMetadata> loadSummaryMetadata() async {
    try {
      final source = await rootBundle.loadString(
        'assets/data/oncologia_summary.json',
      );
      final decoded = jsonDecode(source);
      if (decoded is Map<String, dynamic>) {
        return DatSusSummaryMetadata(
          status: '${decoded['dataStatus'] ?? 'partial'}',
          pendingFiles: (decoded['pendingFiles'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {
      // Missing or invalid official asset is incomplete by definition.
    }
    return const DatSusSummaryMetadata(status: 'partial', pendingFiles: 0);
  }

  static Future<List<DatSusOncologyRecord>> loadDashboardData() async {
    // Never replace missing official data with plausible-looking demo values.
    return loadSummaryAsset();
  }
}
