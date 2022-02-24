import 'dart:convert';
import 'dart:io';

import 'package:parma_support/model/partido_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;

class PartidosProvider {
  //constantes de base de datos local
  final String _databaseName = "mispartidos.db";
  final String _tableName = "partidos";
  final String _columnKey = "key";
  final String _columnId = "id";
  final String _columnIdLocal = "idLocal";
  final String _columnIdVisita = "idVisita";
  final String _columnAgenda = "agenda";
  final String _columnDescripcion = "descripcion";
  final String _columnScoreLocal = "scoreLocal";
  final String _columnScoreVisita = "scoreVisita";
  final String _columnEstado = "estado";
  final String _columnOrden = "orden";

  //constantes de base de datos  remota
  final String _urlTablaPartidos = "https://sedpluv.firebaseio.com/partidos";
  final String _urlTablaInfo = "https://sedpluv.firebaseio.com/informes";

  PartidosProvider._();
  late Database _database;

  //metodos de base de datos local
  Future<void> _oppenDatabase() async {
    Directory databaseDirectory = await getApplicationDocumentsDirectory();
    _database = await openDatabase(join(databaseDirectory.path, _databaseName),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE $_tableName (" +
          "$_columnKey INTEGER PRIMARY KEY AUTOINCREMENT, " +
          "$_columnId TEXT NOT NULL, " +
          "$_columnIdLocal TEXT NOT NULL, " +
          "$_columnIdVisita TEXT NOT NULL, " +
          "$_columnOrden INTEGER NOT NULL, " +
          "$_columnAgenda TEXT NOT NULL, " +
          "$_columnDescripcion TEXT NOT NULL, " +
          "$_columnScoreLocal INTEGER ARRAY NOT NULL, " +
          "$_columnScoreVisita INTEGER ARRAY NOT NULL, " +
          "$_columnEstado TEXT NOT NULL)");
    });
  }

  Future<int> deleteTable() async {
    _oppenDatabase();
    await _database.delete(_tableName);
    return 0;
  }

  Future<PartidoModel?> getPartido(String id) async {
    await _oppenDatabase();
    List<Map<String, dynamic>> maps = await _database.query(_tableName,
        columns: [
          _columnOrden,
          _columnIdLocal,
          _columnIdVisita,
          _columnAgenda,
          _columnDescripcion,
          _columnScoreLocal,
          _columnScoreVisita,
          _columnEstado
        ],
        where: '$_columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) return PartidoModel.fromJson(maps.first);
    return null;
  }

  Future<void> updateResultadoPartido(
      {required String id,
      required List<int> scoreLocal,
      required List<int> scoreVisita,
      required String estado}) async {
    await _oppenDatabase();
    print('antes de update');
    await _database.update(
        _tableName,
        {
          "scoreLocal": scoreLocal,
          "scoreVisita": scoreVisita,
          "estado": estado
        },
        where: '$_columnId = ?',
        whereArgs: [id]);
    print('despues de update');
  }

  Future<void> updatePartido(PartidoModel partidoModel) async {
    await _oppenDatabase();
    _database.update(_tableName, partidoModel.toJson(),
        where: '$_columnId = ?', whereArgs: [partidoModel.id]);
    _database.close();
  }

  Future<void> insertPartido(PartidoModel partidoModel) async {
    await _oppenDatabase();
    _database.insert(_tableName, partidoModel.toJson());
    _database.close();
  }

  Future<void> deletePartido(String id) async {
    await _oppenDatabase();
    _database.delete(_tableName, where: '$_columnId = ?', whereArgs: [id]);
    _database.close();
  }

  Future<List<PartidoModel>> getTodosPartidos() async {
    List<PartidoModel> partidos = [];
    await _oppenDatabase();
    List<Map<String, dynamic>> maps = await _database.query(_tableName);
    _database.close();
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        partidos.add(PartidoModel.fromJson(maps[i]));
      }
    }
    return partidos;
  }

  //metodos de base de datos remota
  Future<int> insertInfoPartido(PartidoModel partidoModel) async {
    int totalSets = partidoModel.scoreLocal[0] + partidoModel.scoreVisita[0];
    int puntosLocal = 0;
    int puntosVisita = 0;
    bool todoOk = false;
    if (totalSets == 2) {
      if (partidoModel.scoreLocal[0] == 2 && partidoModel.scoreVisita[0] == 0) {
        puntosLocal = 3;
        puntosVisita = 0;
        todoOk = true;
      }
      if (partidoModel.scoreLocal[0] == 0 && partidoModel.scoreVisita[0] == 2) {
        puntosLocal = 0;
        puntosVisita = 3;
        todoOk = true;
      }
    }

    if (totalSets == 3) {
      if (partidoModel.scoreLocal[0] == 2 && partidoModel.scoreVisita[0] == 1) {
        puntosLocal = 2;
        puntosVisita = 1;
        todoOk = true;
      }
      if (partidoModel.scoreLocal[0] == 1 && partidoModel.scoreVisita[0] == 2) {
        puntosLocal = 1;
        puntosVisita = 2;
        todoOk = true;
      }
    }

    if (todoOk) {
      Map<String, String> info = {
        partidoModel.idLocal:
            '${partidoModel.idLocal};$puntosLocal;${partidoModel.scoreLocal[0]};-${partidoModel.scoreVisita[0]};${partidoModel.scoreLocal[1]};-${partidoModel.scoreVisita[1]};${partidoModel.scoreLocal[2]};-${partidoModel.scoreVisita[2]};${partidoModel.scoreLocal[3]};-${partidoModel.scoreVisita[3]}',
        partidoModel.idVisita:
            '${partidoModel.idVisita};$puntosVisita;${partidoModel.scoreVisita[0]};-${partidoModel.scoreLocal[0]};${partidoModel.scoreVisita[1]};-${partidoModel.scoreLocal[1]};${partidoModel.scoreVisita[2]};-${partidoModel.scoreLocal[2]};${partidoModel.scoreVisita[3]};-${partidoModel.scoreLocal[3]}',
      };

      await http.patch(
        Uri.parse('$_urlTablaInfo/${partidoModel.id}.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(info),
      );
      return 0;
    }
    return 1;
  }

  Future updateResultadoBDR(
      {required String id,
      required List<int> scoreLocal,
      required List<int> scoreVisita,
      required String estado}) async {
    await http.patch(
      Uri.parse('$_urlTablaPartidos/$id.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic>{
        'scoreLocal': [
          scoreLocal[0],
          scoreLocal[1],
          scoreLocal[2],
          scoreLocal[3]
        ],
        'scoreVisita': [
          scoreVisita[0],
          scoreVisita[1],
          scoreVisita[2],
          scoreVisita[3]
        ],
        'estado': estado
      }),
    );
  }

  Future<int> updateEstadoPartido(String id, String estado) async {
    await http.patch(Uri.parse('$_urlTablaPartidos/$id.json'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          "estado": estado,
        }));
    return 0;
  }

  Future<String?> getEstadoPartidoDBE(String id) async {
    final query =
        await http.get(Uri.parse('$_urlTablaPartidos/$id/estado.json'));
    if (query.statusCode == 200) {
      final estado = query.body;
      return estado;
    }
    return null;
  }

  //metodos verificados

  Future pathPartidoDBR(PartidoModel partidoModel) async {
    await http.patch(
      Uri.parse('$_urlTablaPartidos/${partidoModel.id}.json'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: jsonEncode(<String, dynamic>{
        _columnAgenda: partidoModel.agenda,
        _columnDescripcion: partidoModel.descripcion,
        _columnIdLocal: partidoModel.idLocal,
        _columnIdVisita: partidoModel.idVisita,
        _columnScoreLocal: partidoModel.scoreLocal,
        _columnScoreVisita: partidoModel.scoreVisita,
        _columnEstado: partidoModel.estado,
        _columnOrden: partidoModel.orden
      }),
    );
  }

  Future<PartidoModel?> getPartidoDBR(String id) async {
    final respuesta = await http.get(Uri.parse('$_urlTablaPartidos/$id.json'));
    if (respuesta.statusCode == 200) {
      final data = jsonDecode(respuesta.body);
      if (data != null) {
        return PartidoModel(
          id: id,
          idLocal: data[_columnIdLocal],
          idVisita: data[_columnIdVisita],
          scoreLocal: List<int>.from(data[_columnScoreLocal].map((x) => x)),
          scoreVisita: List<int>.from(data[_columnScoreVisita].map((x) => x)),
          agenda: data[_columnAgenda],
          descripcion: data[_columnDescripcion],
          estado: data[_columnEstado],
          orden: data[_columnOrden],
        );
      }
    }

    return null;
  }
}

final misPartidosProvider = PartidosProvider._();
