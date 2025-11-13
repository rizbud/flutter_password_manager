import 'package:sqflite_sqlcipher/sqflite.dart';

Future<Database> openDB(String password) async {
  final db = await openDatabase(
    'secure_credentials.db',
    password: password,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE credentials (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          password TEXT,
          website TEXT,
          notes TEXT,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    },
  );
  return db;
}

Future<List<Map<String, dynamic>>> getAllCredentials(
  Database db, {
  String? keyword,
}) async {
  return await db.query(
    'credentials',
    columns: ['id', 'username', 'website', 'created_at', 'updated_at'],
    orderBy: 'website ASC',
    where: keyword != null && keyword.isNotEmpty
        ? 'website LIKE ? OR username LIKE ?'
        : null,
    whereArgs: keyword != null && keyword.isNotEmpty
        ? ['%$keyword%', '%$keyword%']
        : null,
  );
}

Future<Map<String, dynamic>?> getCredentialById(Database db, int id) async {
  final results = await db.query(
    'credentials',
    where: 'id = ?',
    whereArgs: [id],
  );
  if (results.isNotEmpty) {
    return results.first;
  }
  return null;
}

Future<void> insertCredential(
  Database db,
  String username,
  String password,
  String website,
  String notes,
) async {
  await db.insert('credentials', {
    'username': username,
    'password': password,
    'website': website,
    'notes': notes,
  });
}

Future<void> updateCredential(
  Database db,
  int id,
  String username,
  String password,
  String website,
  String notes,
) async {
  await db.update(
    'credentials',
    {
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> deleteCredential(Database db, int id) async {
  await db.delete('credentials', where: 'id = ?', whereArgs: [id]);
}
