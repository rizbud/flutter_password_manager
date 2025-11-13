import 'package:flutter/material.dart';
import 'package:password_manager/helpers/string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool hasPin = false;
  bool supportsBiometric = false;
  final List<TextEditingController> pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> createPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> confirmPinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  String? storedPin;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final LocalAuthentication localAuth = LocalAuthentication();

  bool get isCreatePinValid {
    final pin = createPinControllers.map((c) => c.text).join();
    final confirm = confirmPinControllers.map((c) => c.text).join();
    return pin.length == 4 && confirm.length == 4 && pin == confirm;
  }

  @override
  void initState() {
    super.initState();
    _loadPin();
    _checkBiometricSupport();
  }

  Future<void> _loadPin() async {
    final pin = await secureStorage.read(key: 'pin');
    setState(() {
      hasPin = pin != null && pin.length == 4;
      storedPin = pin;
    });
  }

  Future<void> _checkBiometricSupport() async {
    final bool canCheckBiometrics = await localAuth.canCheckBiometrics;
    final bool isDeviceSupported = await localAuth.isDeviceSupported();
    setState(() {
      supportsBiometric = canCheckBiometrics && isDeviceSupported;
    });

    if (isDeviceSupported && hasPin) {
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk membuka aplikasi',
        biometricOnly: true,
      );
      if (didAuthenticate) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autentikasi biometrik gagal!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('userCanceled')
                ? 'Autentikasi dibatalkan oleh pengguna.'
                : 'Terjadi kesalahan: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: hasPin ? _buildPinInput(context) : _buildCreatePin(context),
      ),
      bottomNavigationBar: hasPin ? null : _buildCreatePinButton(context),
    );
  }

  Widget _buildPinSquares(
    List<TextEditingController> controllers, {
    bool updateOnChange = false,
    VoidCallback? onComplete,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 8),
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
          child: TextField(
            controller: controllers[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            obscureText: true,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 3) {
                FocusScope.of(context).nextFocus();
              }
              if (val.isEmpty && i > 0) {
                FocusScope.of(context).previousFocus();
              }
              if (updateOnChange) setState(() {});
              if (onComplete != null &&
                  controllers.every((c) => c.text.isNotEmpty)) {
                onComplete();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildCreatePin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Text(
            'Buat PIN Baru',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan 4 digit PIN untuk mengamankan aplikasi Anda.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPinSquares(createPinControllers, updateOnChange: true),
          const SizedBox(height: 24),
          const Text(
            'Konfirmasi PIN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          _buildPinSquares(confirmPinControllers, updateOnChange: true),
        ],
      ),
    );
  }

  Widget _buildCreatePinButton(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 16 + bottomInset),
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
          onPressed: isCreatePinValid
              ? () async {
                  FocusScope.of(context).unfocus();
                  final prefs = await SharedPreferences.getInstance();
                  await Future.wait([
                    prefs.setBool('isFirstOpen', false),
                    secureStorage.write(
                      key: 'pin',
                      value: createPinControllers.map((c) => c.text).join(),
                    ),
                    secureStorage.write(
                      key: 'db_field_salt',
                      value: generateRandomString(32),
                    ),
                    secureStorage.write(
                      key: 'db_password',
                      value: generateRandomString(10),
                    ),
                  ]);

                  _loadPin();
                }
              : null,
          child: const Text('Buat PIN', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildPinInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          Text(
            'Masukkan PIN',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Masukkan 4 digit PIN Anda untuk membuka aplikasi.',
            style: TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPinSquares(
            pinControllers,
            onComplete: () async {
              final enteredPin = pinControllers.map((c) => c.text).join();
              if (enteredPin == storedPin) {
                FocusScope.of(context).unfocus();
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                // Optionally show error (UI only)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PIN salah!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          if (supportsBiometric)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    await _authenticateWithBiometrics();
                  },
                  icon: const Icon(Icons.fingerprint, color: Colors.blueAccent),
                  label: const Text('Gunakan Biometrik'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
