import 'package:flutter/material.dart';
import 'package:parma_support/model/partido_model.dart';
import 'package:parma_support/pages/home_page.dart';
import 'package:parma_support/providers/partido_provider.dart';
import 'package:parma_support/providers/recientes_provider.dart';
import 'package:parma_support/utils.dart';
import 'package:parma_support/validator.dart';

class FormularioDeActualizacion extends StatefulWidget {
  FormularioDeActualizacion(this.partidoModel);
  PartidoModel partidoModel;

  @override
  _FormularioDeActualizacionState createState() =>
      _FormularioDeActualizacionState(partidoModel);
}

class _FormularioDeActualizacionState extends State<FormularioDeActualizacion> {
  _FormularioDeActualizacionState(this.partidoModel);

  PartidoModel partidoModel;
  late List<int> planillaScoreLocal;
  late List<int> planillaScoreVisita;
  late String estadoSelected;

  bool inicialize = true;
  bool camposEnable = true;
  bool esperandoData = false;
  bool enviandoData = false;

  @override
  void initState() {
    if (partidoModel.estado == "Finalizado") {
      camposEnable = false;
    } else {
      camposEnable = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
        title: Text('Actualizar partido'),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  esperandoData = true;
                });
                misPartidosProvider
                    .getPartidoDBR(partidoModel.id)
                    .then((partido) {
                  if (partido != null) {
                    setState(() {
                      partidoModel = partido; //TODO: ver si esto anda..
                      esperandoData = false;
                      if (partidoModel.estado == "Finalizado") {
                        camposEnable = false;
                      } else {
                        camposEnable = true;
                      }
                    });
                  } else {
                    setState(() {
                      esperandoData = false;
                    });
                  }
                });
              },
              icon: Icon(Icons.refresh_sharp))
        ],
      ),
      body: _build(),
    );
  }

  _build() {
    if (enviandoData) {
      return _createScreenProceso('Enviando datos');
    }
    if (esperandoData) {
      return _createScreenProceso('Esparando datos');
    }
    return _crearFormulario();
  }

  Future<int> actualizarDatos() async {
    final resp = await misPartidosProvider.getPartidoDBR(partidoModel.id);
    if (resp != null) {
      if (resp.estado == "Finalizado") {
        camposEnable = false;
      }
      partidoModel = resp;
      return 0;
    } else {
      return 1;
    }
  }

  //pantalla de esperando datos
  Widget _createScreenProceso(String mensaje) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 40.0),
        Center(child: Text(mensaje))
      ],
    );
  }

  //pantalla normal
  Widget _crearFormulario() {
    return Column(
      children: [
        _crearEncabezadoEquipo(partidoModel.idLocal),
        Row(
          children: [
            Expanded(child: selecLocalSets()),
            Expanded(child: selecLocalSet1()),
            Expanded(child: selecLocalSet2()),
            Expanded(child: selecLocalSet3()),
          ],
        ),
        _crearEncabezadoEquipo(partidoModel.idVisita),
        Row(
          children: [
            Expanded(child: selecVisitaSets()),
            Expanded(child: selecVisitaSet1()),
            Expanded(child: selecVisitaSet2()),
            Expanded(child: selecVisitaSet3()),
          ],
        ),
        Divider(),
        selectEstado(),
        Divider(),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _createBtnEnviar(),
          ],
        ),
        Expanded(child: SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _crearDescripcion(),
          ],
        ),
      ],
    );
  }

  //encabezado de equipos
  Widget _crearEncabezadoEquipo(String id) {
    return Container(
      child: ListTile(
        title: Text(Utils.teamsMap[id]["shortName"]),
        subtitle: Text(Utils.teamsMap[id]["longName"]),
        contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
        leading: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30.0,
            child: Image(
                image: AssetImage(Utils.teamsMap[id]["img"]), height: 45)),
      ),
    );
  }

  //campo estado select
  Widget selectEstado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Seleccionar estado:'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<String>(
              value: partidoModel.estado,
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (String? value) {
                      setState(() {
                        partidoModel.estado = value!;
                      });
                    }
                  : null,
              items:
                  Utils.estados.map<DropdownMenuItem<String>>((String valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text(valor),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  //campos planilla
  Widget selecLocalSets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Sets'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreLocal[0],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() {
                        partidoModel.scoreLocal[0] = value!;
                      });
                    }
                  : null,
              items: crearVectorNros(3).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecLocalSet1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 1'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreLocal[1],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreLocal[1] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecLocalSet2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 2'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreLocal[2],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreLocal[2] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecLocalSet3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 3'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreLocal[3],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreLocal[3] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecVisitaSets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Sets'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreVisita[0],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreVisita[0] = value!);
                    }
                  : null,
              items: crearVectorNros(3).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecVisitaSet1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 1'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreVisita[1],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreVisita[1] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecVisitaSet2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 2'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreVisita[2],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreVisita[2] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget selecVisitaSet3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: Text('Set 3'),
        ),
        Container(
          height: 40.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: DropdownButton<int>(
              value: partidoModel.scoreVisita[3],
              icon: const Icon(Icons.arrow_drop_down_sharp),
              underline: SizedBox(),
              isExpanded: true,
              style: TextStyle(fontSize: 14.0, color: Colors.black),
              onChanged: camposEnable
                  ? (int? value) {
                      setState(() => partidoModel.scoreVisita[3] = value!);
                    }
                  : null,
              items:
                  crearVectorNros(49).map<DropdownMenuItem<int>>((int valor) {
                return DropdownMenuItem(
                  value: valor,
                  child: Text('$valor'),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<int> crearVectorNros(int max) {
    List<int> vector = [];
    for (int i = 0; i < max; i++) vector.add(i);
    return vector;
  }

  Widget _createBtnEnviar() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 15.0),
        child: OutlinedButton(
            onPressed: camposEnable
                ? () {
                    int isValidData = Validator.isValid(partidoModel.scoreLocal,
                        partidoModel.scoreVisita, partidoModel.estado);
                    if (isValidData == 0) {
                      setState(() {
                        esperandoData = true;
                        misPartidosProvider
                            .getEstadoPartidoDBE(partidoModel.id)
                            .then((estadoBDR) {
                          if (estadoBDR != "Finalizado") {
                            setState(() {
                              esperandoData = false;
                              enviandoData = true;

                              _enviarDatos(estadoBDR!).then((value) {
                                setState(() {
                                  enviandoData = false;
                                });
                              });
                            });
                          } else {
                            actualizarDatos().then((value) {
                              setState(() {
                                esperandoData = false;
                              });
                            });
                          }
                        });
                      });
                    } else {
                      _showSnackBar(Validator.mensajes[isValidData]);
                    }
                  }
                : null,
            child: Text('ENVIAR')));
  }

  Future<int> _enviarDatos(String estadoDBR) async {
    await misPartidosProvider.updateResultadoBDR(
        id: partidoModel.id,
        scoreLocal: partidoModel.scoreLocal,
        scoreVisita: partidoModel.scoreVisita,
        estado: partidoModel.estado);
    await misPartidosProvider.updateResultadoPartido(
        id: partidoModel.id,
        scoreLocal: partidoModel.scoreLocal,
        scoreVisita: partidoModel.scoreVisita,
        estado: partidoModel.estado);
    if (estadoDBR == "Programado" && partidoModel.estado != "En juego") {
      print('ESTOY ACAAAA');
      final ids = await recientesProvider.getIdsPartidosEnJuego();
      print('ids: $ids');
      ids.add(partidoModel.id);
      print('ids: $ids');
      await recientesProvider.updateIdsEnJuego(ids);
    }

    if (partidoModel.estado == "Finalizado") {
      await misPartidosProvider.insertInfoPartido(partidoModel);
      await recientesProvider.insertIdFinishedDBR(partidoModel.id);
      setState(() {
        camposEnable = false;
      });
    }

    return 0;
  }

  Future<int> updateEstadoRecientes(String estadoDBR) async {
    if (estadoDBR == "Programado" && partidoModel.estado == "En juego") {
      // print('cumple la condicion de no estar en juego dbr?');
      List<String> idsEnJuego = await recientesProvider.getIdsPartidosEnJuego();
      if (idsEnJuego.indexOf(partidoModel.id) == -1) {
        idsEnJuego.add(partidoModel.id);
        await recientesProvider.updateIdsEnJuego(idsEnJuego);
      }
    }

    if (estadoDBR != "Finalizado" && partidoModel.estado == "Finalizado") {
      recientesProvider.insertIdFinishedDBR(partidoModel.id);
    }
    return 0;
  }

  _crearDescripcion() {
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Text('${partidoModel.agenda}. ${partidoModel.descripcion}.'),
    );
  }

  void _showSnackBar(String? mensaj) {
    if (mensaj != null) {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(mensaj),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
