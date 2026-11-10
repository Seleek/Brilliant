import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/src/celda.dart';
import 'package:brilliant/src/tablero.dart';
import 'package:brilliant/src/tablero_bloc.dart';

void main() {
  test('el turno compartido conserva dados y espera al resto de jugadores', () {
    final posicionesIniciales = {
      for (var x = 0; x < 6; x++) Posicion(x, 0),
    };
    final tablero = Tablero.vacio(
      const {},
      posicionesIniciales: posicionesIniciales,
    );
    final bloc = TableroBloc(tablero, dadosCompartidos: true);
    final celdas = List<dynamic>.filled(49, null);
    for (var x = 0; x < 6; x++) {
      celdas[x] = x + 1;
    }

    bloc.aplicarInstantaneaRemota(
      celdas,
      partidaIniciada: true,
      dados: const [2, 3],
      ronda: 1,
      jugadaEnviada: false,
      puntaje: 5,
    );
    bloc.agregar(SeleccionarDado(0));
    bloc.agregar(SeleccionarCelda(const Posicion(2, 1)));
    bloc.agregar(ColocarFicha());

    expect(bloc.estadoActual.tablero.celdaEn(const Posicion(2, 1)).valor, 2);
    expect(bloc.estadoActual.dados, [2, 3]);
    expect(bloc.estadoActual.turno, 1);
    expect(bloc.estadoActual.jugadaEnviada, isTrue);
    expect(bloc.estadoActual.puedeColocarFichaDelTurno, isFalse);
    expect(bloc.estadoActual.puntajeTotal, 5);

    final siguienteTablero = bloc.valoresCeldas;
    bloc.aplicarInstantaneaRemota(
      siguienteTablero,
      partidaIniciada: true,
      dados: const [4, 5],
      ronda: 2,
      jugadaEnviada: false,
      puntaje: 8,
    );

    expect(bloc.estadoActual.dados, [4, 5]);
    expect(bloc.estadoActual.turno, 2);
    expect(bloc.estadoActual.jugadaEnviada, isFalse);
    expect(bloc.estadoActual.puntajeTotal, 8);
    bloc.agregar(SeleccionarDado(0));
    bloc.actualizarPuntajeRemoto(9);
    expect(bloc.estadoActual.indiceDadoSeleccionado, 0);
    expect(bloc.estadoActual.puntajeTotal, 9);
    bloc.dispose();
  });
}
