import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parma_support/pages/create_partido_page.dart';
import 'package:parma_support/pages/edit_estado_page.dart';
import 'package:parma_support/pages/mis_partidos_page.dart';
import 'package:parma_support/pages/partidos_recientes_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _fondoApp(),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_titulos(), _createMenu()],
            ),
          )
        ],
      ),
    );
  }

  _fondoApp() {
    final gradiente = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            Color.fromRGBO(36, 169, 209, 1.0),
            Color.fromRGBO(94, 134, 219, 1.0)
          ],
          begin: FractionalOffset(0.0, 0.5),
          end: FractionalOffset(0.0, 1.0),
        ),
      ),
    );

    final cajaBlanca = Transform.rotate(
      angle: 10.0,
      child: Container(
        width: 380.0,
        height: 380.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.0),
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromRGBO(179, 237, 255, 1.0),
              Color.fromRGBO(94, 134, 219, 0.9)
            ],
            begin: FractionalOffset(0.0, 1.0),
            end: FractionalOffset(1.0, 1.0),
          ),
        ),
      ),
    );

    final logo = Container(
      width: 360.0,
      height: 360.0,
      child: Image(image: AssetImage('assets/logo_parma.png'), height: 200.0),
    );

    return Stack(
      children: <Widget>[
        gradiente,
        Positioned(
          child: cajaBlanca,
          top: -120.0,
          left: 0.0,
        ),
        Positioned(
          child: logo,
          bottom: -20.0,
          left: 5.0,
        )
      ],
    );
  }

  _createCardOpcion(String title, IconData iconData, Color color, funcion()) {
    return Container(
      height: 180.0,
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.all(25.0),
      decoration: BoxDecoration(
          //color: Color.fromRGBO(232, 232, 232, 0.8),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.9),
                blurRadius: 0.3,
                spreadRadius: 0.2)
          ],
          gradient: LinearGradient(colors: [
            Color.fromRGBO(0, 209, 255, 0.8),
            Color.fromRGBO(103, 183, 240, 0.2)
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: TextButton(
        onPressed: funcion,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CircleAvatar(
              child: Icon(iconData, color: Colors.white, size: 35.0),
              radius: 35.0,
              backgroundColor: color,
            ),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14.0)),
          ],
        ),
      ),
    );
  }

  Widget _createMenu() {
    return Table(
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            _createCardOpcion('Mis partidos', Icons.upload, Colors.red, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MisPartidosPage()));
            }),
            _createCardOpcion(
                'En juego', Icons.gamepad_outlined, Colors.orange.shade600, () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PartidosRecientesPage()));
            }),
          ],
        ),
        /*TableRow(
          children: <Widget>[
            _createCardOpcion('Nuevo Partido', Icons.add, Colors.green, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => CreatePartidoPage()));
            }),
            _createCardOpcion(
                'Editar Partido', Icons.edit, Colors.lightBlue.shade900, () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => EditEstadoPage()));
            })
          ],
        ),*/
      ],
    );
  }

  _titulos() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parma 2022',
                style: TextStyle(
                    color: Color.fromRGBO(2, 65, 84, 1.0),
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Text('5ta edición',
                  style: TextStyle(
                      color: Color.fromRGBO(2, 65, 84, 1.0), fontSize: 18.0))
            ],
          ),
        ),
      ),
    );
  }
}
