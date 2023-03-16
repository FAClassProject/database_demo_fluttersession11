
//Singleton Class
import 'dart:developer';
import 'package:database_demo_fluttersession11/user_model/user_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseService {
  static final DataBaseService _dataBaseService = DataBaseService._internal();

  factory DataBaseService() => _dataBaseService;

  DataBaseService._internal();

  static Database? _database;


  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<void> insertUser(UserModel userModel)async{
    final db = await _dataBaseService.database;
    var data = await db.insert("Users", userModel.toMap());
    log(data.toString());
    print("Data  $data");

  }

  Future<void> editUser(UserModel userModel)async{
    final db = await _dataBaseService.database;
    var Updated = await db.update("Users", userModel.toMap(), where: 'id=?', whereArgs: [userModel.id]);
    log(Updated.toString());
    print("Updated  $Updated");

  }
  Future<void> deleteUser(String id)async{
    final db = await _dataBaseService.database;
    var deleted = await db.delete("Users", where: 'id=?', whereArgs: [id]);
    log(deleted.toString());
    print("deleted  $deleted");
  }

  Future<List<UserModel>> getAllUser()async{
    final db = await _dataBaseService.database;
    var data = await db.query("Users");
    List<UserModel> users = List.generate(data.length, (index) => UserModel.fromJson(data[index]));
    print(users.length);
    return users;

  }

  Future<Database> initDatabase() async {
    final getDirectory = await getApplicationDocumentsDirectory();
    String path = getDirectory.path + '/users.db';
    print("Path $path");
    log(path);
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  void _onCreate(Database database, int version) async {
    await database.execute(
        "CREATE TABLE Users(id TEXT PRIMARY KEY, name TEXT, email TEXT, age INTEGER)");
    log("Table Created");
    print("table created ${database.path}");
  }
}