import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

class GoogleSheetsService {
  static Future<List<Map<String, String>>> fetchSheetData() async {
    final credentials = ServiceAccountCredentials.fromJson(
        json.decode(await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json')));

    const _scopes = [sheets.SheetsApi.spreadsheetsReadonlyScope];
    final client = await clientViaServiceAccount(credentials, _scopes);

    final sheetsApi = sheets.SheetsApi(client);
    final spreadsheetId = '1SB2ek_GjEAiQOzSA4-GBaEC3i83aOPn__8hlLmZ82aI';
    final range = 'Sheet1!A:M';

    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    final values = response.values;

    if (values == null || values.isEmpty) {
      throw Exception('No data found in sheet.');
    }

    final List<Map<String, String>> data = [];
    final headers = values.first.map((header) => header.toString()).toList();

    for (var row in values.skip(1)) {
      final Map<String, String> rowData = {};
      for (int i = 0; i < headers.length; i++) {
        rowData[headers[i]] = row.length > i ? row[i].toString() : '';
      }
      data.add(rowData);
    }

    return data;
  }
}
