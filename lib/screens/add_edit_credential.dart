import 'package:flutter/material.dart';
import 'package:password_manager/helpers/db.dart';
import 'package:password_manager/helpers/string.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class AddEditCredential extends StatefulWidget {
  const AddEditCredential({super.key});

  @override
  State<AddEditCredential> createState() => _AddEditCredentialState();
}

class _AddEditCredentialState extends State<AddEditCredential> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePassword = true;

  int? credentialId;
  bool isLoading = true;

  bool get _isFormValid =>
      _nameController.text.isNotEmpty &&
      _usernameController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Database? db;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _usernameController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    // _initDb will be called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    credentialId = id;
    _initDbAndLoadCredential();
  }

  Future<void> _initDbAndLoadCredential() async {
    final dbPassword = await secureStorage.read(key: 'db_password');
    if (dbPassword != null) {
      db = await openDB(dbPassword);
      if (credentialId != null) {
        await _loadCredential(credentialId!);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCredential(int id) async {
    final fieldSalt = await secureStorage.read(key: 'db_field_salt');
    final cred = await getCredentialById(db!, id);
    if (cred != null && fieldSalt != null) {
      _nameController.text = cred['website'] ?? '';
      _usernameController.text = cred['username'] ?? '';
      _passwordController.text = decryptString(cred['password'], fieldSalt);
      _notesController.text = decryptString(cred['notes'], fieldSalt);
    }
  }

  Future<void> _saveCredential() async {
    final website = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final passwordRaw = _passwordController.text.trim();
    final notesRaw = _notesController.text.trim();
    final fieldSalt = await secureStorage.read(key: 'db_field_salt');
    if (fieldSalt == null || db == null) return;

    final encryptedPassword = encryptString(passwordRaw, fieldSalt);
    final encryptedNotes = notesRaw.isNotEmpty
        ? encryptString(notesRaw, fieldSalt)
        : '';
    if (credentialId != null) {
      // Edit mode
      await updateCredential(
        db!,
        credentialId!,
        username,
        encryptedPassword,
        website,
        encryptedNotes,
      );
    } else {
      // Add mode
      await insertCredential(
        db!,
        username,
        encryptedPassword,
        website,
        encryptedNotes,
      );
    }
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          credentialId != null ? 'Edit Kredensial' : 'Tambah Kredensial',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CustomInputCard(
              label: 'Website atau Aplikasi',
              child: TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                  'Masukkan URL website atau aplikasi',
                ),
              ),
            ),
            const SizedBox(height: 16),
            _CustomInputCard(
              label: 'Username atau Email',
              child: TextField(
                controller: _usernameController,
                decoration: _inputDecoration('Masukkan username atau email'),
              ),
            ),
            const SizedBox(height: 16),
            _CustomInputCard(
              label: 'Kata Sandi',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('Masukkan kata sandi')
                          .copyWith(
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black38,
                                  ),
                                  onPressed: _togglePasswordVisibility,
                                  tooltip: 'Tampilkan/Sembunyikan Kata Sandi',
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CustomInputCard(
              label: 'Catatan (Opsional)',
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: _inputDecoration(
                  'Tambahkan catatan opsional di sini',
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.yellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _isFormValid
                ? () async {
                    await _saveCredential();
                    Navigator.pop(context);
                  }
                : null,
            child: Text(
              credentialId != null ? 'Simpan Perubahan' : 'Simpan',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFF23304D).withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black38, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black38, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black45, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.black54),
    );
  }
}

class _CustomInputCard extends StatelessWidget {
  final String label;
  final Widget child;
  const _CustomInputCard({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}
