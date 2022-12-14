import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHandler {

  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE userdetails(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        username TEXT,
        email TEXT,
        password TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'kindacode.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createUser(String username, String? email, String? password) async {
    final db = await SQLHandler.db();
    final data = {'username': username, 'email': email, 'password': password};
    final id = await db.insert('userdetails', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    //debugPrint(id.toString());
    return id;
  }

  // Read all items (journals)
  static Future<String> compareUser(String username, String password) async {
    final db = await SQLHandler.db();
    var res = await db.rawQuery("SELECT * FROM userdetails WHERE username = '$username' and password = '$password'");
    if (res.length > 0) {
      return "1";
    }
    return "0";
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await SQLHandler.db();
    return db.query('userdetails', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getUser(String username, String password) async {
    final db = await SQLHandler.db();
    return db.query('userdetails', where: "username = ? && password = ?", whereArgs: [username,password], limit: 1);
  }

  // Update an item by id
  static Future<int> updateUser(int id, String username, String? email, String? password) async {
    final db = await SQLHandler.db();
    final data = {
      'title': username,
      'email': email,
      'password': password,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('userdetails', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteUser(int id) async {
    final db = await SQLHandler.db();
    try {
      await db.delete("userdetails", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}