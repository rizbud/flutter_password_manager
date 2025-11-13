import 'dart:async';
import 'package:flutter/material.dart';
import 'package:password_manager/helpers/db.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/helpers/string.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> credentials = [];
  Database? db;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    _initDb();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _loadCredentials(keyword: _searchController.text);
    });
  }

  Future<void> _initDb() async {
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
    await _loadCredentials();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCredentials({String? keyword}) async {
    if (db == null) return;
    final creds = await getAllCredentials(db!, keyword: keyword);
    setState(() {
      credentials = creds;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCredentials(keyword: _searchController.text);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Container(
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari website, aplikasi, atau username',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black38,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: credentials.isEmpty
                        ? const Center(child: Text('Belum ada kredensial'))
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: credentials.length,
                            itemBuilder: (context, index) {
                              final cred = credentials[index];
                              final website = cred['website'] ?? '';
                              final username = cred['username'] ?? '';
                              final id = cred['id'] as int;
                              final icon = isValidUrl(website)
                                  ? Icons.language
                                  : Icons.phone_iphone;
                              final iconBg = Colors.blue.shade200;
                              return _CredentialCard(
                                id: id,
                                icon: icon,
                                iconBg: iconBg,
                                title: website,
                                subtitle: username,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          onPressed: () {
            Navigator.pushNamed(context, '/add-edit-credential');
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _CredentialCard extends StatelessWidget {
  final int id;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  const _CredentialCard({
    required this.id,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushNamed(context, '/credential-details', arguments: id);
          },
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black87, size: 28),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
