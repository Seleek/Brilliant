import 'package:brilliant/brilliant.dart';
import 'package:brilliant/src/datos/niveles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableroBloc puntuación roja y amarilla', () {
    test('las zonas puntúan en el orden de finalización', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoRojo(),
          const Posicion(1, 0): TipoRojo(),
          const Posicion(2, 0): TipoAmarillo(),
          const Posicion(3, 0): TipoAmarillo(),
          const Posicion(4, 0): TipoRojo(),
          const Posicion(5, 0): TipoRojo(),
        },
        coloresUnificados: {TipoAmarillo().color},
        divisionesPorColumna: {TipoRojo().color: 3},
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 6);

      bloc.agregar(ColocarNumero(const Posicion(2, 0), 3));
      bloc.agregar(ColocarNumero(const Posicion(3, 0), 4));
      expect(bloc.estadoActual.puntajeTotal, 14);

      bloc.agregar(ColocarNumero(const Posicion(4, 0), 5));
      bloc.agregar(ColocarNumero(const Posicion(5, 0), 6));
      expect(bloc.estadoActual.puntajeTotal, 18);

      bloc.dispose();
    });

    test('no permite duplicados en rojo ni amarillo y no los puntúa', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoRojo(),
          const Posicion(1, 0): TipoRojo(),
          const Posicion(2, 0): TipoAmarillo(),
          const Posicion(3, 0): TipoAmarillo(),
        },
        coloresUnificados: {TipoAmarillo().color},
        divisionesPorColumna: {TipoRojo().color: 3},
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 2));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));
      expect(bloc.estadoActual.mensajeError, contains('Todos los números'));
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.agregar(ColocarNumero(const Posicion(1, 0), 3));
      expect(bloc.estadoActual.puntajeTotal, 6);

      bloc.agregar(ColocarNumero(const Posicion(2, 0), 4));
      bloc.agregar(ColocarNumero(const Posicion(3, 0), 4));
      expect(bloc.estadoActual.mensajeError, contains('Todos los números'));
      expect(bloc.estadoActual.puntajeTotal, 6);

      bloc.dispose();
    });
  });

  group('zonas y puntuaciones configuradas por nivel', () {
    final niveles = construirNiveles();

    test('cada nivel tiene dos zonas rojas y una amarilla', () {
      for (final nivel in niveles) {
        final zonas = agruparEnRegiones(
          nivel.tipoPorPosicion,
          coloresUnificados: nivel.coloresUnificados,
          divisionesPorColumna: nivel.divisionesPorColumna,
        );
        final zonasRojas = zonas
            .where((zona) => nivel.tipoPorPosicion[zona.first] is TipoRojo);
        final zonasAmarillas = zonas
            .where((zona) => nivel.tipoPorPosicion[zona.first] is TipoAmarillo);

        expect(zonasRojas, hasLength(2), reason: nivel.nombre);
        expect(zonasAmarillas, hasLength(1), reason: nivel.nombre);
      }
    });

    test('mantiene los premios solicitados para rojo y amarillo', () {
      for (final nivel in niveles) {
        final rojo = nivel.tipoPorPosicion.values.whereType<TipoRojo>().first;
        expect(rojo.puntuaciones, {1: 6, 2: 4, 3: 2});
      }

      final puntuacionesAmarillas = [
        {1: 8, 2: 6, 3: 4},
        {1: 6, 2: 4, 3: 2},
        {1: 7, 2: 5, 3: 3},
        {1: 8, 2: 6, 3: 4},
      ];
      for (var i = 0; i < niveles.length; i++) {
        final amarillo =
            niveles[i].tipoPorPosicion.values.whereType<TipoAmarillo>().first;
        expect(amarillo.puntuaciones, puntuacionesAmarillas[i]);
      }
    });
  });
}
