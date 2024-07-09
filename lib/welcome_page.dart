import 'package:flutter/material.dart';
import 'dart:io';
import 'fastag_form.dart';
import 'check_status_page.dart'; // Import CheckStatusPage

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEFA),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.only(top: 16.0),
              child: Image.asset(
                'assets/shiva2.png', // Update with your image asset
                height: 150.0,
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.red, width: 12.0),
              ),
              color: Color(0xD0E86B0B),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome to FASTAG Recharge Requisition Form',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0,
                        backgroundColor:Colors.white,
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Image.asset(
                      'assets/welcome_image.jpg', // Update with your image asset
                      height: 100.0,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FastagForm()),
                        );
                      },
                      child: Text('New Request'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckStatusPage()),
                        );
                      },
                      child: Text('Check Status'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: Text('Exit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
