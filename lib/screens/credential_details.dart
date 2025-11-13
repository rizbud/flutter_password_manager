import 'package:flutter/material.dart';
import 'package:password_manager/helpers/db.dart';
import 'package:password_manager/helpers/string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:clipboard/clipboard.dart';

class CredentialDetails extends StatefulWidget {
  const CredentialDetails({super.key});

  @override
  State<CredentialDetails> createState() => _CredentialDetailsState();
}

class _CredentialDetailsState extends State<CredentialDetails> {
  bool _obscurePassword = true;
  Map<String, dynamic>? credential;
  bool isLoading = true;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Database? db;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    if (id != null) {
      _loadDB(id);
    }
  }

  Future<void> _loadDB(int id) async {
    final dbPassword = await secureStorage.read(key: 'db_password');
    if (dbPassword == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    db = await openDB(dbPassword);
    if (db == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    _loadCredential(id);
  }

  Future<void> _loadCredential(int id) async {
    final fieldSalt = await secureStorage.read(key: 'db_field_salt');
    final cred = await getCredentialById(db!, id);
    String? password;
    String? notes;
    if (cred != null && fieldSalt != null) {
      password = decryptString(cred['password'], fieldSalt);
      notes = decryptString(cred['notes'], fieldSalt);
    }
    setState(() {
      credential = {
        'id': cred?['id'],
        'website': cred?['website'] ?? '',
        'username': cred?['username'] ?? '',
        'password': password ?? '',
        'notes': notes ?? '',
      };
      isLoading = false;
    });
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String text,
    String label,
  ) async {
    // Use Flutter's clipboard
    await FlutterClipboard.copy(text);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin!'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kredensial ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await deleteCredential(db!, credential!['id']);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (credential == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: Text('Kredensial tidak ditemukan')),
      );
    }
    final website = credential!['website'] ?? '';
    final username = credential!['username'] ?? '';
    final password = credential!['password'] ?? '';
    final notes = credential!['notes'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'Detail Kredensial',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Website atau Aplikasi',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Text(
                  website,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Username atau Email',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blueAccent),
                      tooltip: 'Salin Username',
                      onPressed: () =>
                          _copyToClipboard(context, username, 'Username'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kata Sandi',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _obscurePassword ? '•' * password.length : password,
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: _obscurePassword ? 2 : null,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black38,
                      ),
                      tooltip: _obscurePassword
                          ? 'Tampilkan Kata Sandi'
                          : 'Sembunyikan Kata Sandi',
                      onPressed: _togglePasswordVisibility,
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.blueAccent),
                      tooltip: 'Salin Kata Sandi',
                      onPressed: () =>
                          _copyToClipboard(context, password, 'Kata Sandi'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Catatan',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 0,
                ),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Text(
                  notes,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Colors.blueAccent,
                        width: 1,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/add-edit-credential',
                      arguments: credential!['id'],
                    ).then((_) {
                      _loadCredential(credential!['id']);
                    });
                  },
                  child: const Text('Edit'),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showDeleteConfirmation(context),
                  child: const Text('Hapus'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
