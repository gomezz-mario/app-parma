import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class RecientesProvider {
  //constantes de base de datos local
  final String _urlTablaRecientes = "https://sedpluv.firebaseio.com/recientes";
  final String _databaseName = "recientes.db";
  final String _tableName = "finalizados";
  final String _columnKey = "key";
  final String _columnId = "id";

  RecientesProvider._();
  late Database _database;

  Future<void> _oppenDatabase() async {
    Directory databaseDirectory = await getApplicationDocumentsDirectory();
    _database = await openDatabase(join(databaseDirectory.path, _databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $_tableName (" +
          "$_columnKey INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "$_columnId TEXT NOT NULL)");
    });
  }

  Future<List<String>> getIdsPartidosTerminadosAlmacenados() async {
    List<String> idFinish = [];
    await _oppenDatabase();
    //_database.delete(_tableName);
    List<Map<String, dynamic>> maps = await _database.query(_tableName);
    _database.close();
    //print(maps);

    if (maps.isNotEmpty) {
      maps.forEach((data) {
        idFinish.add(data['id']);
      });
    }

    print('idFinish: $idFinish');
    return idFinish;
  }

  Future<int> getFinalizadosCount() async {
    final response =
        await http.get(Uri.parse('$_urlTablaRecientes/finalizados.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        return data;
      }
    }
    return 0;
  }

  Future<void> updateIdsEnJuego(List<String> ids) async {
    await http.patch(
      Uri.parse('$_urlTablaRecientes/idsEnJuego.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(ids),
    );
  }

  Future<List<String>> getIdsPartidosEnJuego() async {
    List<String> idsEnJuego = [];
    final response =
        await http.get(Uri.parse('$_urlTablaRecientes/idsEnJuego.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        idsEnJuego = List<String>.from(data.map((x) => x));
      }
    }
    return idsEnJuego;
  }

  Future<String> getIdFinished(int index) async {
    String idFinish = "";
    final response = await http
        .get(Uri.parse('$_urlTablaRecientes/idsFinalizados/$index.json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        idFinish = data;
      }
    }
    return idFinish;
  }

  Future<int> insertIdFinishedDBR(String id) async {
    int count = await getFinalizadosCount();
    print('count finish: $count');
    count++;
    await http.patch(
      Uri.parse('$_urlTablaRecientes/idsFinalizados/$count.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: id,
    );
    await http.patch(Uri.parse('$_urlTablaRecientes/finalizados.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(count));
    return 0;
  }

  Future<int> insertFinished(String id) async {
    await _oppenDatabase();
    final insert = await _database.insert(
      _tableName,
      {'$_columnId': id},
    );
    _database.close();
    return insert;
  }
}

final recientesProvider = RecientesProvider._();
