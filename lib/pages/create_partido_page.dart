import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parma_support/model/partido_model.dart';
import 'package:parma_support/pages/home_page.dart';
import 'package:parma_support/providers/partido_provider.dart';
import 'package:parma_support/utils.dart';

class CreatePartidoPage extends StatefulWidget {
  @override
  _CreatePartidoPageState createState() => _CreatePartidoPageState();
}

class _CreatePartidoPageState extends State<CreatePartidoPage> {
  //COMPONENTES
  //select equipos
  late List<String> idTeams;
  late List<String> namesTeams;
  late String idLocalTeamSelected;
  late String idVisitTeamSelected;
  late String nameLocalTeamSelected;
  late String nameVisitTeamSelected;

  //select dias
  late String diaSelected;

  //select horario
  late String horaSelected;
  late String minutosSelected;

  //select cancha
  late String canchaSelected;

  //select rama
  late String ramaSelected;

  //select orden
  late int ordenSelected;
  late List<int> nrosOrden;

  //select description
  late String descriptionSelected;

  //VARIABLES
  String newId = "";
  bool idVerify = false;

  @override
  void initState() {
    print('iniState');
    super.initState();
    initVariables();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Partido'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            }),
      ),
      body: Column(
        children: [
          _sectionKey(),
          _sectionTeams(),
          _sectionAgenda(),
          _sectionDescription(),
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
      ),
    );
  }

  void initVariables() {
    _getIdTeams();
    _getNamesTeams();
    diaSelected = Utils.dias[0];
    horaSelected = Utils.horas[0];
    minutosSelected = Utils.minutos[0];
    canchaSelected = Utils.canchas[0];
    ordenSelected = 1;
    ramaSelected = Utils.ramas[0];
    nrosOrden = [];
    for (int i = 0; i < 100; i++) {
      nrosOrden.add(i);
    }
    descriptionSelected = Utils.instancias[0];
  }

  //ACTION BUTTONS
  void _verifyId() async {
    _createNewId();
    final resp = await misPartidosProvider.getPartidoDBR(newId);
    resp == null ? idVerify = true : idVerify = false;
    setState(() {
      if (!idVerify)
        _showSnackBar('El ID no esta disponible');
      else
        _showSnackBar('ID disponible');
    });
    print('verificar onpressed');
    print('idVerify: $idVerify');
  }

  void _enableEdit() {
    setState(() {
      idVerify = false;
    });
  }

  Widget _createVerifyButton() {
    String text;
    idVerify ? text = 'EDITAR' : text = 'VERIFICAR';
    return OutlinedButton(
        onPressed: idVerify ? _enableEdit : _verifyId, child: Text(text));
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

  Widget _createEnviarButton() {
    return OutlinedButton(
        onPressed: idVerify ? _captionData : null, child: Text('ENVIAR'));
  }

  void _captionData() {
    final nuevoPartido = PartidoModel(
      agenda: '$diaSelected, $horaSelected:$minutosSelected, $canchaSelected.',
      descripcion: descriptionSelected,
      estado: "Programado",
      id: newId,
      idLocal: idLocalTeamSelected,
      idVisita: idVisitTeamSelected,
      scoreLocal: [0, 0, 0, 0],
      scoreVisita: [0, 0, 0, 0],
      orden: ordenSelected,
    );

    _enviar(nuevoPartido);
  }

  Future<void> _enviar(PartidoModel nuevoPartido) async {
    final rsp = await misPartidosProvider.getPartidoDBR(nuevoPartido.id);
    if (rsp == null) {
      await misPartidosProvider.pathPartidoDBR(nuevoPartido);
      setState(() {
        _showSnackBar('El partido ha sido creado exitosamente');
        idVerify = false;
      });
    } else {
      _showSnackBar('Se intento crear un partido ya existente');
      idVerify = false;
    }
  }

  //SECTION KEY
  _sectionKey() {
    return Column(
      children: [
        _headerKey(),
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
      ],
    );
  }

  Widget _headerKey() {
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
                      Icons.code_sharp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text('ID KEY',
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
          onChanged: !idVerify
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
          onChanged: !idVerify
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

  //SECTION DIA, HORA, LUGAR
  Widget _sectionAgenda() {
    return Column(
      children: [
        _headerAgenda(),
        SizedBox(height: 6.0),
        Row(
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('Fecha')),
                    _diaSelect()
                  ],
                )),
            Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Text('Horario')),
                    Row(
                      children: [
                        Expanded(child: _horaSelect(), flex: 1),
                        Expanded(child: _minutosSelect(), flex: 1),
                      ],
                    ),
                  ],
                )),
            Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text('Cancha')),
                    _canchaSelect()
                  ],
                )),
          ],
        ),
        SizedBox(height: 5.0),
        Divider(),
      ],
    );
  }

  Widget _headerAgenda() {
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
                      Icons.calendar_today,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text('AGENDA',
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

  Widget _diaSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: diaSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    diaSelected = newValue!;
                  });
                }
              : null,
          items: Utils.dias.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _horaSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: horaSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    horaSelected = newValue!;
                  });
                }
              : null,
          items: Utils.horas.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _minutosSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: minutosSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    minutosSelected = newValue!;
                  });
                }
              : null,
          items: Utils.minutos.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _canchaSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: canchaSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    canchaSelected = newValue!;
                  });
                }
              : null,
          items: Utils.canchas.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  //SECTION EQUIPOS

  Widget _sectionTeams() {
    return Column(
      children: [
        _headerSectionTeams(),
        _localTeam(),
        Divider(),
        _visitTeam(),
        Divider(),
      ],
    );
  }

  void _getIdTeams() {
    idTeams = [];
    Utils.teamsMap.forEach((idTeam, teamData) {
      idTeams.add(idTeam);
    });
    idLocalTeamSelected = idTeams[0];
    idVisitTeamSelected = idTeams[0];
  }

  void _getNamesTeams() {
    namesTeams = [];
    Utils.teamsMap.forEach((idTeam, teamData) {
      namesTeams.add(teamData["shortName"]);
    });
    nameLocalTeamSelected = namesTeams[0];
    nameVisitTeamSelected = namesTeams[0];
  }

  Widget _headerSectionTeams() {
    return Row(
      children: [
        Expanded(
            child: Container(
                color: Color.fromRGBO(0, 0, 32, 1.0),
                padding: EdgeInsets.all(5.0),
                margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
                child: Row(
                  children: [
                    Icon(Icons.groups_sharp, color: Colors.white),
                    SizedBox(width: 10.0),
                    Text('EQUIPOS',
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

  Widget _localTeam() {
    return ListTile(
      title: _localTeamSelect(),
      subtitle: Text(Utils.teamsMap[idLocalTeamSelected]["longName"]),
      leading: CircleAvatar(
        child: Image(
            image: AssetImage(Utils.teamsMap[idLocalTeamSelected]["img"])),
        radius: 35.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _localTeamSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: nameLocalTeamSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    nameLocalTeamSelected = newValue!;
                    idLocalTeamSelected = idTeams[namesTeams.indexOf(newValue)];
                  });
                }
              : null,
          items: namesTeams.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _visitTeam() {
    return ListTile(
      title: _visitTeamSelect(),
      subtitle: Text(Utils.teamsMap[idVisitTeamSelected]["longName"]),
      leading: CircleAvatar(
        child: Image(
            image: AssetImage(Utils.teamsMap[idVisitTeamSelected]["img"])),
        radius: 35.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _visitTeamSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: nameVisitTeamSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    nameVisitTeamSelected = newValue!;
                    idVisitTeamSelected = idTeams[namesTeams.indexOf(newValue)];
                  });
                }
              : null,
          items: namesTeams.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
    );
  }

  //SECTION DESCRIPCION
  Widget _sectionDescription() {
    return Column(
      children: [
        _headerDescription(),
        Row(
          children: [
            Expanded(child: _descriptionSelect(), flex: 1),
          ],
        ),
      ],
    );
  }

  Widget _headerDescription() {
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
                      Icons.insights_sharp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.0),
                    Text('FASE',
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

  Widget _descriptionSelect() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: DropdownButton<String>(
          value: descriptionSelected,
          icon: const Icon(Icons.arrow_drop_down_sharp),
          underline: SizedBox(),
          isExpanded: true,
          style: TextStyle(fontSize: 14.0, color: Colors.black),
          onChanged: idVerify
              ? (String? newValue) {
                  setState(() {
                    descriptionSelected = newValue!;
                  });
                }
              : null,
          items: Utils.instancias.map<DropdownMenuItem<String>>((String name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(name),
            );
          }).toList(),
        ),
      ),
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
