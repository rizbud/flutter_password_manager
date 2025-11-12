import 'package:flutter/material.dart';
import 'package:password_manager/screens/add_edit_credential.dart';
import 'package:password_manager/screens/authentication.dart';
import 'package:password_manager/screens/credential_details.dart';
import 'package:password_manager/screens/get_started.dart';
import 'package:password_manager/screens/home.dart';
import 'package:password_manager/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      ),
      home: const Splash(),
      routes: {
        '/get-started': (context) => const GetStarted(),
        '/authenticate': (context) => const Authentication(),
        '/home': (context) => const MyHomePage(title: 'Password Manager'),
        '/add-edit-credential': (context) => const AddEditCredential(),
        '/credential-details': (context) => const CredentialDetails(),
      },
    );
  }
}
