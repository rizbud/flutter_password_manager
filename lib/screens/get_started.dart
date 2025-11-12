import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Transform.rotate(
                    angle: 3 * 3.1415926535897932 / 2, // 270 degrees in radians
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      size: 64,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Password Manager',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                              letterSpacing: 1.2,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Satu tempat untuk semua password dan catatan rahasia Anda. Aman, praktis, dan selalu siap saat dibutuhkan.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _KeyPointCard(
                      icon: Icons.lock_rounded,
                      title: 'Keamanan & Enkripsi',
                      description:
                          'Semua data kredensial dienkripsi AES-256 dan hanya tersimpan di perangkat Anda.',
                    ),
                    const SizedBox(height: 16),
                    _KeyPointCard(
                      icon: Icons.fingerprint_rounded,
                      title: 'Autentikasi & Privasi',
                      description:
                          'Akses aplikasi dilindungi PIN dan biometrik. Tidak ada data dikirim ke server.',
                    ),
                    const SizedBox(height: 16),
                    _KeyPointCard(
                      icon: Icons.wifi_off_rounded,
                      title: 'Akses Offline & Performa Cepat',
                      description:
                          'Semua fitur dapat digunakan tanpa internet. Pencarian dan pengelolaan data sangat cepat.',
                    ),
                    const SizedBox(height: 16),
                    _KeyPointCard(
                      icon: Icons.touch_app_rounded,
                      title: 'Kemudahan & Aksesibilitas',
                      description:
                          'Antarmuka sederhana, mendukung layar besar dan aksesibilitas.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
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
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/authenticate');
                },
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyPointCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _KeyPointCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.blueAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
