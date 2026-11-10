import 'package:brilliant/brilliant.dart';
import 'package:brilliant/src/datos/niveles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableroBloc puntuación morada', () {
    test('puntúa la zona completa solo cuando tiene dos valores distintos', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoMorado(),
          const Posicion(1, 0): TipoMorado(),
          const Posicion(2, 0): TipoMorado(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(2, 0), 1));
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.agregar(ColocarNumero(const Posicion(2, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 6);

      bloc.dispose();
    });

    test('no permite un tercer valor distinto en la zona', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoMorado(),
          const Posicion(1, 0): TipoMorado(),
          const Posicion(2, 0): TipoMorado(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));
      bloc.agregar(ColocarNumero(const Posicion(2, 0), 3));

      expect(bloc.estadoActual.mensajeError, contains('Máximo 2'));
      expect(bloc.estadoActual.tablero.celdaEn(const Posicion(2, 0)).estaVacia,
          isTrue);
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.dispose();
    });

    test('asigna los puestos morados en orden de finalización', () {
      const posicionesMoradas = [
        Posicion(0, 0),
        Posicion(1, 0),
        Posicion(3, 0),
        Posicion(4, 0),
        Posicion(0, 2),
        Posicion(1, 2),
      ];
      final tipo = TipoMorado(puntuaciones: const {1: 7, 2: 5, 3: 3});
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          for (final posicion in posicionesMoradas) posicion: tipo,
        },
      );
      final bloc = TableroBloc(tablero);

      for (final posicion in [posicionesMoradas[0], posicionesMoradas[1]]) {
        bloc.agregar(
            ColocarNumero(posicion, posicion == posicionesMoradas[0] ? 1 : 2));
      }
      expect(bloc.estadoActual.puntajeTotal, 7);

      bloc.agregar(ColocarNumero(posicionesMoradas[2], 3));
      bloc.agregar(ColocarNumero(posicionesMoradas[3], 4));
      expect(bloc.estadoActual.puntajeTotal, 12);

      bloc.agregar(ColocarNumero(posicionesMoradas[4], 5));
      bloc.agregar(ColocarNumero(posicionesMoradas[5], 6));
      expect(bloc.estadoActual.puntajeTotal, 15);

      bloc.dispose();
    });
  });

  test('cada nivel configura la puntuación morada solicitada', () {
    final niveles = construirNiveles();
    final puntuacionesEsperadas = [
      {1: 6, 2: 4, 3: 2},
      {1: 6, 2: 4, 3: 2},
      {1: 7, 2: 5, 3: 3},
      {1: 7, 2: 5, 3: 3},
    ];

    for (var i = 0; i < niveles.length; i++) {
      final tipoMorado =
          niveles[i].tipoPorPosicion.values.whereType<TipoMorado>().first;
      expect(tipoMorado.puntuaciones, puntuacionesEsperadas[i]);
    }
  });
}
