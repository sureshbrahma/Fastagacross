import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';

class CheckStatusPage extends StatefulWidget {
  @override
  _CheckStatusPageState createState() => _CheckStatusPageState();
}

class _CheckStatusPageState extends State<CheckStatusPage> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  List<Map<String, String>> _sheetData = [];
  List<String> _referenceNumbers = [];
  String? _selectedReferenceNumber;
  String? _selectedStatus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentials = await _loadServiceAccountCredentials();
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    final scopes = [sheets.SheetsApi.spreadsheetsReadonlyScope];

    return clientViaServiceAccount(accountCredentials, scopes);
  }

  Future<Map<String, dynamic>> _loadServiceAccountCredentials() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/androidfastrack-aa32e2e5db9c.json');
    if (!await file.exists()) {
      final data = await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json');
      await file.writeAsString(data);
    }
    final credentials = await file.readAsString();
    return json.decode(credentials);
  }

  Future<void> _fetchSheetData() async {
    try {
      final client = await _getAuthClient();
      final sheetsApi = sheets.SheetsApi(client);
      final String spreadsheetId = '1SB2ek_GjEAiQOzSA4-GBaEC3i83aOPn__8hlLmZ82aI';
      final String range = 'Sheet1!A:M'; // Adjust the range as needed

      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
      final values = response.values;

      if (values != null) {
        List<Map<String, String>> sheetData = [];
        for (var row in values.skip(1)) { // skip the header row
          if (row.length >= 13) {
            sheetData.add({
              'institution': row[0]?.toString() ?? '',
              'department': row[1]?.toString() ?? '',
              'userName': row[2]?.toString() ?? '',
              'whatsappNumber': row[3]?.toString() ?? '',
              'vehicleNumber': row[4]?.toString() ?? '',
              'vehicleType': row[5]?.toString() ?? '',
              'travelFromTo': row[6]?.toString() ?? '',
              'departmentInChargePermission': row[7]?.toString() ?? '',
              'rechargeAmount': row[8]?.toString() ?? '',
              'requestDate': row[9]?.toString() ?? '',
              'referenceNumber': row[10]?.toString() ?? '',
              'status': row[11]?.toString() ?? '',
              'expiration': row[12]?.toString()?.toLowerCase() ?? '',
            });
          }
        }

        setState(() {
          _sheetData = sheetData;
        });
      } else {
        print('No data found.');
      }
    } catch (e) {
      print('Error fetching sheet data: $e');
    }
  }

  String _normalizeString(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true; // Internet connection is available
      }
      return false; // Internet connection is not available
    } on SocketException catch (_) {
      return false; // Internet connection is not available
    }
  }

  Future<void> _fetchReferenceNumbers() async {
    final vehicleNumber = _normalizeString(_vehicleNumberController.text);
    final bool isConnected = await _checkInternetConnectivity();
    if (!isConnected) {
      setState(() {
        _errorMessage = 'No internet connection. Please check your network settings.';
      });
      return;
    }
    final referenceNumbers = _sheetData
        .where((row) => _normalizeString(row['vehicleNumber']!) == vehicleNumber && row['expiration'] == 'no')
        .map((row) => row['referenceNumber']!)
        .toList();

    setState(() {
      _referenceNumbers = referenceNumbers;
      _selectedReferenceNumber = null;
      _selectedStatus = null;

      if (_sheetData.any((row) => _normalizeString(row['vehicleNumber']!) == vehicleNumber)) {
        if (_referenceNumbers.isEmpty) {
          _errorMessage = 'Reference numbers associated with this vehicle are expired';
        } else {
          _errorMessage = null;
        }
      } else {
        _errorMessage = 'Vehicle Number Not Found';
      }
    });
  }

  void _fetchStatus() {
    final row = _sheetData.firstWhere(
          (row) => _normalizeString(row['referenceNumber']!) == _normalizeString(_selectedReferenceNumber!),
      orElse: () => {},
    );

    setState(() {
      _selectedStatus = row.isNotEmpty ? row['status'] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Status'),
        backgroundColor: Colors.blue, // Customize app bar color
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
                hintText: 'Please Enter your Full Vehicle Number',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await _fetchSheetData();
                _fetchReferenceNumbers();
              },
              child: Text('Fetch Reference Numbers'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Customize button color
              ),
            ),
            SizedBox(height: 16.0),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16, color: Colors.red),
              )
            else if (_referenceNumbers.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text('Select Reference Number'),
                    value: _selectedReferenceNumber,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedReferenceNumber = newValue;
                      });
                    },
                    items: _referenceNumbers.map((referenceNumber) {
                      return DropdownMenuItem(
                        value: referenceNumber,
                        child: Text(referenceNumber),
                      );
                    }).toList(),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                    style: TextStyle(color: Colors.black, fontSize: 16),
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            if (_selectedReferenceNumber != null)
              ElevatedButton(
                onPressed: _fetchStatus,
                child: Text('Submit'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.blue), // Customize button color
                ),
              ),
            SizedBox(height: 16.0),
            if (_selectedReferenceNumber != null && _selectedStatus != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Number: $_selectedReferenceNumber',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Status: $_selectedStatus',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: CheckStatusPage()));
