import 'dart:convert';

PartidoModel partidoModelFromJson(String str) =>
    PartidoModel.fromJson(json.decode(str));

String partidoModelToJson(PartidoModel data) => json.encode(data.toJson());

class PartidoModel {
  PartidoModel({
    required this.id,
    required this.orden,
    required this.agenda,
    required this.descripcion,
    required this.idLocal,
    required this.idVisita,
    required this.estado,
    required this.scoreLocal,
    required this.scoreVisita,
  });

  String id;
  int orden;
  String agenda;
  String descripcion;
  String idLocal;
  String idVisita;
  String estado;
  List<int> scoreLocal;
  List<int> scoreVisita;

  factory PartidoModel.fromJson(Map<String, dynamic> json) => PartidoModel(
        id: json["id"],
        orden: json["orden"],
        agenda: json["agenda"],
        descripcion: json["descripcion"],
        idLocal: json["idLocal"],
        idVisita: json["idVisita"],
        estado: json["estado"],
        scoreLocal: List<int>.from(json["scoreLocal"].map((x) => x)),
        scoreVisita: List<int>.from(json["scoreVisita"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "orden": orden,
        "agenda": agenda,
        "descripcion": descripcion,
        "idLocal": idLocal,
        "idVisita": idVisita,
        "estado": estado,
        "scoreLocal": List<dynamic>.from(scoreLocal.map((x) => x)),
        "scoreVisita": List<dynamic>.from(scoreVisita.map((x) => x)),
      };
}
