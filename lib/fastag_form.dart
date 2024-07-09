import 'dart:io';
import 'package:BKACCFASTAG/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class FastagForm extends StatefulWidget {
  @override
  _FastagFormState createState() => _FastagFormState();
}

class _FastagFormState extends State<FastagForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedInstitution = 'Please select an institution';
  String? _department;
  String? _userName;
  String? _whatsappNumber;
  String? _vehicleNumber;
  String? _vehicleType = 'Please select vehicle type';
  String? _travelFromTo;
  String? _departmentInChargePermission;
  String? _rechargeAmount;
  DateTime? _requestDate;

  final _institutionFocusNode = FocusNode();
  final _departmentFocusNode = FocusNode();
  final _userNameFocusNode = FocusNode();
  final _whatsappNumberFocusNode = FocusNode();
  final _vehicleNumberFocusNode = FocusNode();
  final _vehicleTypeFocusNode = FocusNode();
  final _travelFromToFocusNode = FocusNode();
  final _departmentInChargePermissionFocusNode = FocusNode();
  final _rechargeAmountFocusNode = FocusNode();
  final _requestDateFocusNode = FocusNode();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _requestDate) {
      setState(() {
        _requestDate = picked;
      });
    }
  }

  Future<String> getAccessToken() async {
    final String credentials = await rootBundle.loadString('assets/androidfastrack-aa32e2e5db9c.json');
    final Map<String, dynamic> credentialsJson = json.decode(credentials);

    final response = await http.post(
      Uri.parse('https://oauth2.googleapis.com/token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': _createJwt(credentialsJson),
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  String _createJwt(Map<String, dynamic> credentialsJson) {
    final jwt = JWT(
      {
        'iss': credentialsJson['client_email'],
        'scope': 'https://www.googleapis.com/auth/spreadsheets',
        'aud': 'https://oauth2.googleapis.com/token',
        'exp': (DateTime.now().millisecondsSinceEpoch / 1000).round() + 3600,
        'iat': (DateTime.now().millisecondsSinceEpoch / 1000).round(),
      },
    );

    final key = RSAPrivateKey(credentialsJson['private_key']);
    return jwt.sign(key, algorithm: JWTAlgorithm.RS256);
  }

  void _showPreviewDialog() {
    String message = 'Institution: $_selectedInstitution\n'
        'Department: $_department\n'
        'User Name: $_userName\n'
        'WhatsApp Number: $_whatsappNumber\n'
        'Vehicle Number: $_vehicleNumber\n'
        'Vehicle Type: $_vehicleType\n'
        'Travel From-To: $_travelFromTo\n'
        'Permission: $_departmentInChargePermission\n'
        'Recharge Amount: $_rechargeAmount\n'
        'Request Date: ${_requestDate != null ? DateFormat('dd-MM-yyyy').format(_requestDate!) : ''}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Preview Details'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _sendDataToServer();
              },
            ),
          ],
        );
      },
    );
  }

  void _validateForm() {
    if (_selectedInstitution == null || _selectedInstitution!.trim().isEmpty || _selectedInstitution == 'Please select an institution') {
      _showSnackbar('Please select an institution');
      FocusScope.of(context).requestFocus(_institutionFocusNode);
      return;
    }
    if (_department == null || _department!.trim().isEmpty) {
      _showSnackbar('Please enter the department name');
      FocusScope.of(context).requestFocus(_departmentFocusNode);
      return;
    }
    if (_userName == null || _userName!.trim().isEmpty) {
      _showSnackbar('Please enter the user name');
      FocusScope.of(context).requestFocus(_userNameFocusNode);
      return;
    }
    if (_whatsappNumber == null || _whatsappNumber!.trim().isEmpty) {
      _showSnackbar('Please enter the WhatsApp mobile number');
      FocusScope.of(context).requestFocus(_whatsappNumberFocusNode);
      return;
    }
    if (_vehicleNumber == null || _vehicleNumber!.trim().isEmpty) {
      _showSnackbar('Please enter your vehicle number');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(_vehicleNumber!)) {
      _showSnackbar('Vehicle number should not contain spaces or special characters');
      FocusScope.of(context).requestFocus(_vehicleNumberFocusNode);
      return;
    }
    if (_vehicleType == null || _vehicleType!.trim().isEmpty || _vehicleType == 'Please select vehicle type') {
      _showSnackbar('Please select the type of vehicle');
      FocusScope.of(context).requestFocus(_vehicleTypeFocusNode);
      return;
    }
    if (_travelFromTo == null || _travelFromTo!.trim().isEmpty) {
      _showSnackbar('Please enter the travel details');
      FocusScope.of(context).requestFocus(_travelFromToFocusNode);
      return;
    }
    if (_departmentInChargePermission == null || _departmentInChargePermission!.trim().isEmpty) {
      _showSnackbar('Please enter the permission details');
      FocusScope.of(context).requestFocus(_departmentInChargePermissionFocusNode);
      return;
    }
    if (_rechargeAmount == null || _rechargeAmount!.trim().isEmpty) {
      _showSnackbar('Please enter the recharge amount');
      FocusScope.of(context).requestFocus(_rechargeAmountFocusNode);
      return;
    }
    final int? amount = int.tryParse(_rechargeAmount!);
    if (amount == null || amount < 100) {
      _showSnackbar('Minimum recharge amount is Rs. 100');
      FocusScope.of(context).requestFocus(_rechargeAmountFocusNode);
      return;
    }
    if (_requestDate == null) {
      _showSnackbar('Please select the date of request');
      FocusScope.of(context).requestFocus(_requestDateFocusNode);
      return;
    }
    _showPreviewDialog();
  }

  void _sendDataToServer() async {
    try {
      bool isConnected = await _checkInternetConnectivity();
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No internet connection. Please check your network settings.'),
        ));
        return;
      }

      final String accessToken = await getAccessToken();
      final String referenceNumber = DateTime.now().millisecondsSinceEpoch.toString();
      final String spreadsheetId = '1SB2ek_GjEAiQOzSA4-GBaEC3i83aOPn__8hlLmZ82aI';
      final String range = 'Sheet1!A1:M1'; // Adjust the range as needed

      final List<List<Object?>> values = [
        [
          _selectedInstitution ?? '',
          _department ?? '',
          _userName ?? '',
          _whatsappNumber ?? '',
          _vehicleNumber ?? '',
          _vehicleType ?? '',
          _travelFromTo ?? '',
          _departmentInChargePermission ?? '',
          _rechargeAmount ?? '',
          _requestDate != null ? DateFormat('dd-MM-yyyy').format(_requestDate!) : '',
          referenceNumber, // Reference number
          'Pending', // Status
          'NO' // Expiration
        ]
      ];

      final body = json.encode({
        'range': range,
        'majorDimension': 'ROWS',
        'values': values,
      });

      final response = await http.post(
        Uri.parse('https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range:append?valueInputOption=RAW'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Form data submitted successfully. Reference Number: $referenceNumber'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => WelcomePage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to submit data');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error submitting form: $error'),
      ));
    }
  }

  Future<bool> _checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _institutionFocusNode.dispose();
    _departmentFocusNode.dispose();
    _userNameFocusNode.dispose();
    _whatsappNumberFocusNode.dispose();
    _vehicleNumberFocusNode.dispose();
    _vehicleTypeFocusNode.dispose();
    _travelFromToFocusNode.dispose();
    _departmentInChargePermissionFocusNode.dispose();
    _rechargeAmountFocusNode.dispose();
    _requestDateFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FASTAG Recharges Requisition Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.cyan,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FASTAG Recharges Requisition Form',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Name of Institution (Only for BK & WRST Vehicles, Not for RERF)',style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _selectedInstitution,
                  focusNode: _institutionFocusNode,
                  items: [
                    DropdownMenuItem(
                      value: 'Please select an institution',
                      child: Text('Please select an institution'),
                    ),
                    DropdownMenuItem(
                      value: 'BRAHMAKUMARIS',
                      child: Text('BRAHMAKUMARIS'),
                    ),
                    DropdownMenuItem(
                      value: 'W.R.S.T.',
                      child: Text('W.R.S.T.'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedInstitution = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Name of Department',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _departmentFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _department = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter department name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Name of User',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _userNameFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _userName = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter user name',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('WhatsApp Mobile Number',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _whatsappNumberFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _whatsappNumber = value;
                    });
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter WhatsApp mobile number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Full Vehicle Number (Vehicle number should not contain spaces or special characters)',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _vehicleNumberFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _vehicleNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter full vehicle number',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Vehicle Type',style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: _vehicleType,
                  focusNode: _vehicleTypeFocusNode,
                  items: [
                    DropdownMenuItem(
                      value: 'Please select vehicle type',
                      child: Text('Please select vehicle type'),
                    ),
                    DropdownMenuItem(
                      value: 'BUS',
                      child: Text('BUS'),
                    ),
                    DropdownMenuItem(
                      value: 'CAR',
                      child: Text('CAR'),
                    ),
                    DropdownMenuItem(
                      value: 'TRUCK',
                      child: Text('TRUCK'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _vehicleType = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Travel From-To',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _travelFromToFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _travelFromTo = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter travel details',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Department In-Charge Permission',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _departmentInChargePermissionFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _departmentInChargePermission = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter permission details',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Recharge Amount',style: TextStyle(fontWeight: FontWeight.bold)),
                TextFormField(
                  focusNode: _rechargeAmountFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _rechargeAmount = value;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter recharge amount',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                Text('Date of Request',style: TextStyle(fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    child: Text(
                      _requestDate != null
                          ? DateFormat('dd-MM-yyyy').format(_requestDate!)
                          : 'Select date',
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Center(
                  child: ElevatedButton(
                    onPressed: _validateForm,
                    child: Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
