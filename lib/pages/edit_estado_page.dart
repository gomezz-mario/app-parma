import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parma_support/model/partido_model.dart';
import 'package:parma_support/pages/home_page.dart';
import 'package:parma_support/providers/partido_provider.dart';
import 'package:parma_support/utils.dart';

class EditEstadoPage extends StatefulWidget {
  @override
  _EditEstadoPageState createState() => _EditEstadoPageState();
}

class _EditEstadoPageState extends State<EditEstadoPage> {
  late String ramaSelected;
  late int ordenSelected;
  late List<int> nrosOrden;
  late String estadoSelected;
  bool partidoEncontrado = false;
  late String newId;
  late PartidoModel partidoModel;

  @override
  void initState() {
    super.initState();
    _initVariables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar partido'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            }),
      ),
      body: _build(),
    );
  }

  Widget _build() {
    return Column(
      children: [_sectionKey(), _sectionPartidoEdit()],
    );
  }

  //ACTION BUTTONS
  Widget _createVerifyButton() {
    String text;
    partidoEncontrado ? text = 'EDITAR' : text = 'BUSCAR';
    return OutlinedButton(
        onPressed: !partidoEncontrado ? _searchId : _enableEdit,
        child: Text(text));
  }

  Widget _createEnviarButton() {
    return OutlinedButton(
        onPressed: () {
          misPartidosProvider
              .updateEstadoPartido(partidoModel.id, estadoSelected)
              .then((value) {
            _showSnackBar('Nuevo estado: $estadoSelected');
            setState(() {
              partidoModel.estado = estadoSelected;
              partidoEncontrado = false;
            });
          });
        },
        child: Text('ENVIAR'));
  }

  void _searchId() {
    _createNewId();
    print('id: $newId');
    print('busca');
    misPartidosProvider.getPartidoDBR(newId).then((partido) {
      setState(() {
        if (partido != null) {
          partidoModel = partido;
          estadoSelected = partido.estado;
          partidoEncontrado = true;
        } else {
          _showSnackBar('Partido no encontrado');
          partidoEncontrado = false;
        }
      });
    });
  }

  void _createNewId() {
    switch (ramaSelected) {
      case "Masculina":
        newId = 'rm-';
        break;
      case "Femenina":
        newId = 'rf-';
        break;
    }

    if (ordenSelected < 10) {
      newId += 'p00$ordenSelected';
    } else {
      newId += 'p0$ordenSelected';
    }
  }

  void _enableEdit() {
    setState(() {
      partidoEncontrado = false;
    });
  }

  //SECTION PARTIDO EDIT
  Widget _headerEditMatch() {
    return Row(
      children: [
        Expanded(
            child: Container(
                color: Color.fromRGBO(0, 0, 32, 1.0),
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.switch_left_sharp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text('EDITAR PARTIDO',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500)),
                  ],
                ))),
      ],
    );
  }

  Widget _sectionPartidoEdit() {
    if (partidoEncontrado) {
      return Column(
        children: [
          _headerEditMatch(),
          Container(
            child: _viewTeam(partidoModel.idLocal),
            margin: EdgeInsets.symmetric(vertical: 5.0),
            padding: EdgeInsets.all(5.0),
          ),
          Divider(),
          Container(
            child: _viewTeam(partidoModel.idVisita),
            margin: EdgeInsets.symmetric(vertical: 5.0),
            padding: EdgeInsets.all(5.0),
          ),
          Divider(),
          _estadoSelect(),
          Row(
            children: [
              Expanded(child: Container(), flex: 1),
              Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                  child: _createEnviarButton())
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _viewTeam(String idTeam) {
    return ListTile(
      title: Text(Utils.teamsMap[idTeam]["shortName"]),
      subtitle: Text(Utils.teamsMap[idTeam]["longName"]),
      leading: CircleAvatar(
        child: Image(image: AssetImage(Utils.teamsMap[idTeam]["img"])),
        radius: 35.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _estadoSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: estadoSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: (String? newValue) {
            setState(() {
              estadoSelected = newValue!;
            });
          },
          items: Utils.estados.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  //SECTION KEY
  Widget _sectionKey() {
    return Column(
      children: [
        _headerSearchMatch(),
        SizedBox(height: 5.0),
        Row(
          children: [
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('Rama'),
                    ),
                    _ramaSelect(),
                  ],
                ),
                flex: 2),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text('Orden'),
                    ),
                    _ordenSelect(),
                  ],
                ),
                flex: 1),
            //Expanded(child: Container(), flex: 1),
            Container(
              width: 120.0,
              //color: Colors.black,
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  SizedBox(height: 15.0),
                  _createVerifyButton(),
                ],
              ),
            ),

            //SizedBox(width: 15.0),
          ],
        ),
        SizedBox(height: 10.0),
      ],
    );
  }

  Widget _headerSearchMatch() {
    return Row(
      children: [
        Expanded(
            child: Container(
                color: Color.fromRGBO(0, 0, 32, 1.0),
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text('BUSCAR PARTIDO',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500)),
                  ],
                ))),
      ],
    );
  }

  Widget _ramaSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: ramaSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: !partidoEncontrado
              ? (String? newValue) {
                  setState(() {
                    ramaSelected = newValue!;
                  });
                }
              : null,
          items: Utils.ramas.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _ordenSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<int>(
          value: ordenSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: !partidoEncontrado
              ? (int? newValue) {
                  setState(() {
                    ordenSelected = newValue!;
                  });
                }
              : null,
          items: nrosOrden.map<DropdownMenuItem<int>>((int nro) {
            return DropdownMenuItem(
              value: nro,
              child: Text('$nro'),
            );
          }).toList(),
        ),
      ),
    );
  }

  //OTROS METODOS
  void _initVariables() {
    ramaSelected = Utils.ramas[0];

    nrosOrden = [];
    for (int i = 0; i < 100; i++) {
      nrosOrden.add(i);
    }
    ordenSelected = 1;
    estadoSelected = Utils.estados[0];
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
