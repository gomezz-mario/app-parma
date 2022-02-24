class Validator {
  static final Map<int, String> mensajes = {
    0: 'Correcto',
    10: 'Error code: 10. Error en el estado declarado.',
    40: 'Error code: 40. TANTOS > TSET && DIF > 2.',
    20: 'Error code: 20. Score en sets no actualizado.',
    21: 'Error code: 21. Score en sets incorrecto.',
    30: 'Error code: 30. Comprobación de campos no nulos.',
  };

  static int setsGanadosLocal = 0;
  static int setsGanadosVisita = 0;
  static int exitCode = 0;

  static int isValid(
      List<int> scoreLocal, List<int> scoreVisita, String estadoDeclarado) {
    bool datosValidos = true;
    bool continuarValidacion = true;
    setsGanadosLocal = 0;
    setsGanadosVisita = 0;
    String estadoValidado = "";
    exitCode = 0;

    //COMPROBAR ESTADO DE PROGRAMADO
    if (estadoDeclarado == "Programado") {
      if (scoreLocal[0] == 0 &&
          scoreLocal[1] == 0 &&
          scoreLocal[2] == 0 &&
          scoreLocal[3] == 0) {
        if (scoreVisita[0] == 0 &&
            scoreVisita[1] == 0 &&
            scoreVisita[2] == 0 &&
            scoreVisita[3] == 0) {
          estadoValidado = "Programado";
        } else {
          estadoValidado = "En proceso";
        }
      } else {
        estadoValidado = "En proceso";
      }

      if (estadoDeclarado != estadoValidado) {
        exitCode = 10;
        datosValidos = false;
      } else {
        exitCode = 0;
        continuarValidacion = false;
      }
    }

    //VALIDACION 1ER SET
    if (datosValidos && continuarValidacion) {
      if (isSetValid(scoreLocal[1], scoreVisita[1])) {
        //1er Set empezado --> comprueba datos nulos en sets no comenzados.. fin validacion.
        if (scoreLocal[0] + scoreVisita[0] == 0 &&
            setsGanadosLocal + setsGanadosVisita == 0) {
          if (scoreLocal[2] == 0 &&
              scoreLocal[3] == 0 &&
              scoreVisita[2] == 0 &&
              scoreVisita[3] == 0) {
            exitCode = 0; //correcto
            estadoValidado = "En juego";
            continuarValidacion = false;
          } else {
            exitCode = 30; //campos no nulos
            datosValidos = false;
          }
        }
        //1er Set no finalizado y score distinto de 0-0 --> datos no validos
        print('(a la vuelta) sets Local: $setsGanadosLocal');
        print(
            'Sets terminados declarados: ${scoreLocal[0] + scoreVisita[0]}. Sets terminados validados: ${setsGanadosLocal + setsGanadosVisita}');
        if (scoreLocal[0] + scoreVisita[0] == 0 &&
            setsGanadosLocal + setsGanadosVisita > 0) {
          exitCode = 20;
          datosValidos = false;
        }
        //1er Set finalizado y score igual a 0-0 --> datos no validos
        if (scoreLocal[0] + scoreVisita[0] > 0 &&
            setsGanadosLocal + setsGanadosVisita == 0) {
          exitCode = 21;
          datosValidos = false;
        }
      } else {
        datosValidos = false;
      }
    }
    //VALIDACION 2DO SET
    if (datosValidos && continuarValidacion) {
      if (isSetValid(scoreLocal[2], scoreVisita[2])) {
        // 2do set comenzado --> validar ceros, fin validacion
        if (scoreLocal[0] + scoreVisita[0] == 1 &&
            setsGanadosLocal + setsGanadosVisita == 1) {
          if (scoreLocal[3] == 0 && scoreVisita[3] == 0) {
            exitCode = 0; //correcto
            estadoValidado = "En juego";
            continuarValidacion = false;
          } else {
            exitCode = 30;
            datosValidos = false;
          }
        }
        //la suma de sets es mayor que 1.. y el segundo set no ha finalizado
        if (scoreLocal[0] + scoreVisita[0] > 1 &&
            setsGanadosLocal + setsGanadosVisita == 1) {
          exitCode = 20;
          datosValidos = false;
        }
        //la suma de sets es 1.. y el segundo set esta finalizado
        if (scoreLocal[0] + scoreVisita[0] == 1 &&
            setsGanadosLocal + setsGanadosVisita > 1) {
          exitCode = 21;
          datosValidos = false;
        }
      } else {
        datosValidos = false;
      }
    }
    //VALIDACION 3ER SET
    if (datosValidos && continuarValidacion) {
      //comprobar si el partido esta 2-0 o 1-1
      if (setsGanadosLocal == 2 || setsGanadosVisita == 2) {
        if (scoreLocal[3] == 0 && scoreVisita[3] == 0) {
          exitCode = 0;
          estadoValidado = "Finalizado";
          continuarValidacion = false;
        } else {
          exitCode = 30;
          datosValidos = false;
        }
      }
      if (setsGanadosLocal == 1 && setsGanadosVisita == 1) {
        if (isTiebValid(scoreLocal[3], scoreVisita[3])) {
          if (scoreLocal[0] + scoreVisita[0] == 2 &&
              setsGanadosLocal + setsGanadosVisita == 2) {
            exitCode = 0;
            estadoValidado = "En juego";
            continuarValidacion = false;
          }
          if (scoreLocal[0] + scoreVisita[0] == 2 &&
              setsGanadosLocal + setsGanadosVisita > 2) {
            exitCode = 20; //
            datosValidos = false;
          }
          if (scoreLocal[0] + scoreVisita[0] > 2 &&
              setsGanadosLocal + setsGanadosVisita == 2) {
            exitCode = 21; //
            datosValidos = false;
          }
        } else {
          datosValidos = false;
        }
      }
      //pensar si no cabe otra posibilidad que me lleve a un error
    }

    //comprueba finalizacion por 2-1
    if (datosValidos && continuarValidacion) {
      if (scoreLocal[0] + scoreVisita[0] == 3 &&
          setsGanadosLocal + setsGanadosVisita == 3) {
        exitCode = 0;
        estadoValidado = "Finalizado";
        continuarValidacion = false;
      } else {
        datosValidos = false;
        if (scoreLocal[0] + scoreVisita[0] != 3) {
          exitCode = 10;
        }
      }
    }

    if (datosValidos) {
      if (estadoDeclarado != estadoValidado) {
        exitCode = 10;
        datosValidos = false;
      }
    }

    return exitCode;
  }

  static bool isTiebValid(int tantosLocal, int tantosVisita) {
    int diferencia;
    diferencia = tantosLocal - tantosVisita;
    if (tantosLocal > 14 && diferencia > 1) {
      if (tantosLocal == 15) {
        setsGanadosLocal++;
        return true;
      } else {
        if (diferencia == 2) {
          setsGanadosLocal++;
          return true;
        } else {
          exitCode = 40;
          return false;
        }
      }
    }
    diferencia = tantosVisita - tantosLocal;
    if (tantosVisita > 14 && diferencia > 1) {
      if (tantosVisita == 15) {
        setsGanadosVisita++;
        return true;
      } else {
        if (diferencia == 2) {
          setsGanadosVisita++;
          return true;
        } else {
          exitCode = 40;
          return false;
        }
      }
    }

    return true;
  }

  static bool isSetValid(int tantosLocal, int tantosVisita) {
    int diferencia;
    diferencia = tantosLocal - tantosVisita;
    if (tantosLocal > 24 && diferencia > 1) {
      if (tantosLocal == 25) {
        setsGanadosLocal++;
        print('sets Local: $setsGanadosLocal');
        return true;
      } else {
        if (diferencia == 2) {
          setsGanadosLocal++;
          print('sets Local: $setsGanadosLocal');
          return true;
        } else {
          exitCode = 40;
          return false;
        }
      }
    }

    diferencia = tantosVisita - tantosLocal;
    if (tantosVisita > 24 && diferencia > 1) {
      if (tantosVisita == 25) {
        setsGanadosVisita++;
        return true;
      } else {
        if (diferencia == 2) {
          setsGanadosVisita++;
          return true;
        } else {
          exitCode = 40;
          return false;
        }
      }
    }

    return true;
  }
}
