import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlCodes {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      number TEXT,
      createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('callingvoicerecordapp.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      print('....CREATING TABLE ');
      await createTables(database);
    });
  }

  static Future<int> createItem(String name, String? number) async {
    //database connection
    final db = await SqlCodes.db();
    //insert data as a map method
    final data = {'name': name, 'number': number};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  //get called the first time when we launch app or reload
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlCodes.db();
    //how you want to get the data and ordering as id
    return db.query('items', orderBy: "id");
  }

  //getting one item from our database also our condition is 'id'
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlCodes.db();
    return db.query('items', where: "id= ?", whereArgs: [id], limit: 1);
  }

  //update item method
  static Future<int> updateItem(int id, String name, String? number) async {
    final db = await SqlCodes.db();

    //data dormat in a MAP method
    final data = {
      'name': name,
      'number': number,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('items', data, where: "id= ?", whereArgs: [id]);
    return result;
  }

  //delete item from database method with sqflite
  static Future<void> deleteItem(int id) async {
    final db = await SqlCodes.db();
    try {
      await db.delete("items", where: "id= ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
