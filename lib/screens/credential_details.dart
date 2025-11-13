import 'package:flutter/material.dart';

class CredentialDetails extends StatefulWidget {
  const CredentialDetails({super.key});

  @override
  State<CredentialDetails> createState() => _CredentialDetailsState();
}

class _CredentialDetailsState extends State<CredentialDetails> {
  bool _obscurePassword = true;

  void _copyToClipboard(BuildContext context, String text, String label) {
    // Use Flutter's clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin!'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    // Clipboard.setData(ClipboardData(text: text));
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
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              // TODO: Delete logic
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for preview
    final website = 'Amazon';
    final username = 'dianaross@gmail.com';
    final password = 'mypassword123';
    final notes =
        'Pertanyaan keamanan:\nApa nama hewan peliharaan pertama Anda?\nJawaban: Buddy.\n\nIni juga akun yang digunakan untuk Prime Video';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
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
            const SizedBox(height: 10),
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
                    child: Text(username, style: const TextStyle(fontSize: 16)),
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
            const SizedBox(height: 10),
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
                      _obscurePassword ? '••••••••••••••••' : password,
                      style: const TextStyle(fontSize: 16, letterSpacing: 2),
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
            const SizedBox(height: 10),
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12)),
              ),
              child: Text(
                notes,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const Spacer(),
          ],
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
                    Navigator.pushNamed(context, '/add-edit-credential');
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
