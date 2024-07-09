import 'package:flutter/material.dart';
import 'welcome_page.dart'; // Update this import based on the file's location

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fast Tag Form',
      theme: ThemeData(
        // Customize your theme here
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: WelcomePage(), // Use WelcomePage as the home screen
    );
  }
}
