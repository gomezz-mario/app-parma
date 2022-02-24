import 'package:flutter/material.dart';
import 'package:parma_support/model/partido_model.dart';
import 'package:parma_support/pages/home_page.dart';
import 'package:parma_support/providers/partido_provider.dart';
import 'package:parma_support/providers/recientes_provider.dart';
import 'package:parma_support/utils.dart';

class PartidosRecientesPage extends StatefulWidget {
  @override
  _PartidosRecientesPageState createState() => _PartidosRecientesPageState();
}

class _PartidosRecientesPageState extends State<PartidosRecientesPage> {
  final colorRfEnJuego = Colors.pink.shade600;
  final colorRfFinished = Colors.pink.shade900;
  final colorRmEnJuego = Colors.lightBlue.shade800;
  final colorRmEnFinished = Colors.lightBlue.shade900;

  late int
      matchFinishedCount; //lleva la cuenta de los partidos finalizados..se sincroniza con la dbr
  late int
      indexViewPartidoFinalizado; //este indica el ultimo partido finalizado que se cargo en el listview
  //late int totalEnJuego;
  //late int totalProximos;

  late List<String> matchsIdsFinished;
  late List<PartidoModel> allMatchs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partidos recientes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          },
        ),
      ),
      body: FutureBuilder(
        future: _loadPartidos(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              if (snapshot.data == 0) {
                return Center(child: Text('No se encontraron partidos'));
              } else {
                return ListView.builder(
                  itemCount: allMatchs.length,
                  itemBuilder: (context, index) {
                    return _listile(allMatchs[index]);
                  },
                );
              }
            }
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<int> _loadPartidos() async {
    allMatchs = [];
    allMatchs = await _loadPartidosEnJuego();
    //await _loadIdsPartidosFinalizados();
    //indexViewPartidoFinalizado = matchsIdsFinished.length;
    //await _loadPartidosFinalizados();
    return allMatchs.length;
  }

  Future<List<PartidoModel>> _loadPartidosEnJuego() async {
    List<PartidoModel> enJuego = [];
    List<String> ids = await recientesProvider.getIdsPartidosEnJuego();
    if (ids.length > 0) {
      for (int i = 0; i < ids.length; i++) {
        final nuevoPartidoEnJuego =
            await misPartidosProvider.getPartidoDBR(ids[i]);
        if (nuevoPartidoEnJuego != null) {
          enJuego.add(nuevoPartidoEnJuego);
        }
      }
    }
    return enJuego;
  }

  //

  /* //va agregando de 3 en 3 partidos finalizados a AllMatchs.. los agrega al inicio.. para que se muestren arriba...
  Future _loadPartidosFinalizados() async {
    int stopIndex = indexViewPartidoFinalizado - 3;
    while (indexViewPartidoFinalizado > stopIndex &&
        indexViewPartidoFinalizado > 0) {
      indexViewPartidoFinalizado--;
      final nuevoPartidoFinalizado = await misPartidosProvider
          .getPartidoDBR(matchsIdsFinished[indexViewPartidoFinalizado]);
      if (nuevoPartidoFinalizado != null) {
        allMatchs.insert(0, nuevoPartidoFinalizado);
      }
    }
  }

  Future<int> _loadIdsPartidosFinalizados() async {
    //INICIALIZA VARIABLES CON LA INFO ALMACENADA EN EL DISPOSITIVO
    matchsIdsFinished =
        await recientesProvider.getIdsPartidosTerminadosAlmacenados();
    matchFinishedCount = matchsIdsFinished.length;

    //CONSULTA INFO EN DBR
    final dbrCount = await recientesProvider.getFinalizadosCount();

    //SI ES NECESARIO ACTUALIZA LA INFO ALMACENADA
    bool infoActualizada = true;
    if (matchFinishedCount < dbrCount) {
      //INFO NO ACTUALIZADA
      int auxCount = matchFinishedCount + 1;
      infoActualizada = false;
      while (!infoActualizada) {
        final newIdFinish = await recientesProvider.getIdFinished(auxCount);
        if (newIdFinish.isNotEmpty) {
          matchsIdsFinished.add(newIdFinish);
          await recientesProvider.insertFinished(newIdFinish);
          matchFinishedCount++;
        }
        if (auxCount == dbrCount)
          infoActualizada = true;
        else
          auxCount++;
      }
      //INFO ACTUALIZADA
    }
    return 0;
  }
*/
  //ACA ESTAN LOS ESTILOS DE LOS ITEM LIST VIEW

  final textStyle16 = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );

  final textStyle14 = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 14.0,
  );

  _listile(PartidoModel partidoModel) {
    String id = partidoModel.id;
    List<String> data = id.split("-");
    print(data[0]);
    if (data[0] == 'rf') {
      return _listileMujeres(partidoModel);
    } else {
      return _listileVarones(partidoModel);
    }
  }

  _listileMujeres(PartidoModel partidoModel) {
    return Container(
      //color: Colors.amber,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: colorRfEnJuego,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(partidoModel.descripcion, style: textStyle14),
          SizedBox(height: 5.0),
          Row(
            children: [
              CircleAvatar(
                  child: Image(
                      image: AssetImage(
                          Utils.teamsMap[partidoModel.idLocal]["img"]),
                      height: 28.0),
                  radius: 15.0,
                  backgroundColor: colorRfEnJuego),
              SizedBox(width: 15.0),
              Expanded(
                  child: Text(Utils.teamsMap[partidoModel.idLocal]["shortName"],
                      style: textStyle16),
                  flex: 3),
              Expanded(
                  child: Text(partidoModel.scoreLocal[0].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[1].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[2].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[3].toString(),
                      style: textStyle14),
                  flex: 1),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                  child: Image(
                      image: AssetImage(
                          Utils.teamsMap[partidoModel.idVisita]["img"]),
                      height: 28.0),
                  radius: 15.0,
                  backgroundColor: colorRfEnJuego),
              SizedBox(width: 15.0),
              Expanded(
                  child: Text(
                      Utils.teamsMap[partidoModel.idVisita]["shortName"],
                      style: textStyle16),
                  flex: 3),
              Expanded(
                  child: Text(partidoModel.scoreVisita[0].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[1].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[2].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[3].toString(),
                      style: textStyle14),
                  flex: 1),
            ],
          ),
        ],
      ),
    );
  }

  _listileVarones(PartidoModel partidoModel) {
    return Container(
      //color: Colors.amber,
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: colorRmEnJuego,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(partidoModel.descripcion, style: textStyle14),
          SizedBox(height: 5.0),
          Row(
            children: [
              CircleAvatar(
                  child: Image(
                      image: AssetImage(
                          Utils.teamsMap[partidoModel.idLocal]["img"]),
                      height: 28.0),
                  radius: 15.0,
                  backgroundColor: colorRmEnJuego),
              SizedBox(width: 15.0),
              Expanded(
                  child: Text(Utils.teamsMap[partidoModel.idLocal]["shortName"],
                      style: textStyle16),
                  flex: 3),
              Expanded(
                  child: Text(partidoModel.scoreLocal[0].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[1].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[2].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreLocal[3].toString(),
                      style: textStyle14),
                  flex: 1),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                  child: Image(
                      image: AssetImage(
                          Utils.teamsMap[partidoModel.idVisita]["img"]),
                      height: 28.0),
                  radius: 15.0,
                  backgroundColor: colorRmEnJuego),
              SizedBox(width: 15.0),
              Expanded(
                  child: Text(
                      Utils.teamsMap[partidoModel.idVisita]["shortName"],
                      style: textStyle16),
                  flex: 3),
              Expanded(
                  child: Text(partidoModel.scoreVisita[0].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[1].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[2].toString(),
                      style: textStyle14),
                  flex: 1),
              Expanded(
                  child: Text(partidoModel.scoreVisita[3].toString(),
                      style: textStyle14),
                  flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}
