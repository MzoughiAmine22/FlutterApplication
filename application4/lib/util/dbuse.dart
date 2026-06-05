import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/scol_list.dart';
import '../models/list_etudiants.dart';

class dbuse {
  final int version = 1;
  Database? db;

  static final dbuse _dbHelper = dbuse._internal();
  dbuse._internal();
  factory dbuse() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    if (db == null) {
      db = await openDatabase(
        join(await getDatabasesPath(), 'scol.db'),
        onCreate: (database, version) {
          database.execute(
              'CREATE TABLE classes(codClass INTEGER PRIMARY KEY, nomClass TEXT, nbreEtud INTEGER)');
          database.execute(
              'CREATE TABLE etudiants(id INTEGER PRIMARY KEY, codClass INTEGER, nom TEXT, prenom TEXT, datNais TEXT, '
                  'FOREIGN KEY(codClass) REFERENCES classes(codClass))');
        },
        version: version,
      );
    }
    return db!;
  }

  Future<List<ScolList>> getClasses() async {
    final List<Map<String, dynamic>> maps = await db!.query('classes');
    return List.generate(maps.length, (i) {
      return ScolList(
        maps[i]['codClass'],
        maps[i]['nomClass'],
        maps[i]['nbreEtud'],
      );
    });
  }

  Future<List<ListEtudiants>> getEtudiants(int code) async {
    final List<Map<String, dynamic>> maps =
    await db!.query('etudiants', where: 'codClass = ?', whereArgs: [code]);
    return List.generate(maps.length, (i) {
      return ListEtudiants(
        maps[i]['id'],
        maps[i]['codClass'],
        maps[i]['nom'],
        maps[i]['prenom'],
        maps[i]['datNais'],
      );
    });
  }

  Future<int> insertClass(ScolList list) async {
    int codClass = await db!.insert(
      'classes',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return codClass;
  }

  Future<int> insertEtudiants(ListEtudiants etud) async {
    int id = await db!.insert(
      'etudiants',
      etud.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> deleteList(ScolList list) async {
    int result = await db!
        .delete('classes', where: 'codClass = ?', whereArgs: [list.codClass]);
    return result;
  }

  Future<int> deleteStudent(ListEtudiants student) async {
    int result = await db!
        .delete('etudiants', where: 'id = ?', whereArgs: [student.id]);
    return result;
  }
}