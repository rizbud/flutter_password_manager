import 'package:flutter/material.dart';

class CredentialDetails extends StatelessWidget {
  const CredentialDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Credential Details')),
      body: const Center(
        child: Text('Details of the selected credential will be shown here.'),
      ),
    );
  }
}
