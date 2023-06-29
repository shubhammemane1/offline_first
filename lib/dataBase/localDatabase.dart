import 'package:sciverse/Models/User.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static var localDatabase;

  static connect() async {
    localDatabase = await openDatabase(
      'local_dataBase.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE user (id INTEGER PRIMARY KEY,name TEXT,username TEXT,email TEXT,password TEXT,address TEXT,number INTEGER,dob TEXT,securityQuestion TEXT,securityAnswer TEXT,created_at TEXT,updated_at TEXT)'
            '');
      },
    );
    print("dataBase is Created");
  }

  Future<bool> checkIfDatabaseExists() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'local_dataBase.db');
    return await databaseExists(path);
  }

  Future<int> insertUser(User user) async {
    int result = await localDatabase.insert(
      "user",
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
      nullColumnHack: 'address, dob, number, updated_at',
    );
    print(result.toString());
    return result;
  }

  Future<User> getUserByEmail(String email) async {
    print("received email : $email");
    final List<Map<String, dynamic>> maps =
        await LocalDatabaseHelper.localDatabase.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );
    User user = User.fromJson(maps[0]);
    return User.fromJson(maps.first);
  }

  Future<User> getUserByUser(String username) async {
    final List<Map<String, dynamic>> maps =
        await LocalDatabaseHelper.localDatabase.query(
      'user',
      where: 'username = ?',
      whereArgs: [username],
    );
    User user = User.fromJson(maps[0]);
    return User.fromJson(maps.first);
  }

  Future<void> updateUserPassword(User user) async {
    await LocalDatabaseHelper.localDatabase.update(
      'user',
      {
        'password': user.password,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'email = ?',
      whereArgs: [user.email],
    );
  }

  Future<void> printUsersTable() async {
    // final db = await database;
    final users = await localDatabase.query("user");
    print('Users table:');
    for (final user in users) {
      print(user);
    }
  }
}
