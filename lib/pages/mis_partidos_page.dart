import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parma_support/model/partido_model.dart';
import 'package:parma_support/pages/home_page.dart';
import 'package:parma_support/pages/nuevo_formulario.dart';
import 'package:parma_support/providers/partido_provider.dart';
import 'package:parma_support/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class MisPartidosPage extends StatefulWidget {
  @override
  _MisPartidosPageState createState() => _MisPartidosPageState();
}

class _MisPartidosPageState extends State<MisPartidosPage> {
  List<PartidoModel> misPartidos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis partidos'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            }),
      ),
      floatingActionButton: _createFloatingActionButton(),
      body: FutureBuilder(
          future: _consultarPartidos(),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Algo salió mal'));
            } else {
              if (snapshot.hasData) {
                return _misRegistros(snapshot.data!, context);
              } else {
                return _createScreenProcess();
              }
            }
          }),
    );
  }

  _crearPartidoItem(BuildContext context, PartidoModel miPartido) {
    return Dismissible(
        key: Key(miPartido.id.toString()),
        onDismissed: (direction) {
          misPartidosProvider.deletePartido(miPartido.id);
          misPartidos.remove(miPartido);
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.qr_code_2_sharp)),
                title: Text(
                    '${Utils.teamsMap[miPartido.idLocal]["shortName"]} vs ${Utils.teamsMap[miPartido.idVisita]["shortName"]}'),
                subtitle:
                    Text('${miPartido.descripcion} - ${miPartido.agenda}.'),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FormularioDeActualizacion(miPartido)));
                  //builder: (context) => FormularioPage(miPartido)));
                },
              ),
              Divider()
            ],
          ),
        ));
  }

  Future<int> _consultarPartidos() async {
    misPartidos = await misPartidosProvider.getTodosPartidos();
    return misPartidos.length;
  }

  Widget _misRegistros(int lengthData, BuildContext context) {
    if (lengthData > 0) {
      return ListView.builder(
        itemCount: misPartidos.length,
        itemBuilder: (BuildContext context, int index) =>
            _crearPartidoItem(context, misPartidos[index]),
      );
    } else {
      return Center(child: Text('No sigues ningun partido'));
    }
  }

  _createFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _scan,
      child: Icon(Icons.qr_code_2_sharp),
    );
  }

  Widget _createScreenProcess() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 40.0),
        Center(child: Text('Buscando'))
      ],
    );
  }

  Future _scan() async {
    await Permission.camera.request();
    String? barcode = await scanner.scan();
    if (barcode != null) {
      procesarLectura(barcode);
    }
  }

  void procesarLectura(String barcode) async {
    final PartidoModel? miPartido =
        await misPartidosProvider.getPartido(barcode);
    if (miPartido == null) {
      final nuevoPartido = await misPartidosProvider.getPartidoDBR(barcode);
      if (nuevoPartido != null) {
        setState(() {
          misPartidosProvider.insertPartido(nuevoPartido);
        });
      }
    }
  }
}
