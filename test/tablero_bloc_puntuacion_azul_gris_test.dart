import 'package:brilliant/brilliant.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/src/datos/niveles.dart';

void main() {
  group('TableroBloc puntuación azul y gris', () {
    test('las zonas azules puntúan según el orden de finalización', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoAzul(),
          const Posicion(1, 0): TipoAzul(),
          const Posicion(2, 0): TipoRojo(),
          const Posicion(3, 0): TipoAzul(),
          const Posicion(4, 0): TipoAzul(),
          const Posicion(5, 0): TipoRojo(),
          const Posicion(6, 0): TipoAzul(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(3, 0), 2));
      bloc.agregar(ColocarNumero(const Posicion(4, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 7);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 5));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 5));
      expect(bloc.estadoActual.puntajeTotal, 12);

      bloc.agregar(ColocarNumero(const Posicion(6, 0), 3));
      expect(bloc.estadoActual.puntajeTotal, 15);

      bloc.dispose();
    });

    test('una zona azul incompleta o con valores distintos no puntúa', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoAzul(),
          const Posicion(1, 0): TipoAzul(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.agregar(ColocarNumero(const Posicion(1, 0), 3));
      expect(bloc.estadoActual.mensajeError, contains('Todos los números'));
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 7);

      bloc.dispose();
    });

    test('las celdas grises separadas se completan y puntúan como una zona',
        () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoGris(puntuaciones: {1: 3, 2: 3, 3: 1}),
          const Posicion(3, 0): TipoRojo(),
          const Posicion(6, 0): TipoGris(puntuaciones: {1: 3, 2: 3, 3: 1}),
        },
        coloresUnificados: {TipoGris().color},
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 4));
      expect(bloc.estadoActual.puntajeTotal, 0);
      bloc.agregar(ColocarNumero(const Posicion(6, 0), 4));
      expect(bloc.estadoActual.puntajeTotal, 3);

      bloc.dispose();
    });
  });

  group('zonas y puntuaciones configuradas por nivel', () {
    final niveles = construirNiveles();

    test('azul de niveles 3 y 4 es una zona única', () {
      for (final nivel in [niveles[2], niveles[3]]) {
        final zonasAzules = agruparEnRegiones(
          nivel.tipoPorPosicion,
          coloresUnificados: nivel.coloresUnificados,
        ).where((zona) => nivel.tipoPorPosicion[zona.first] is TipoAzul);

        expect(zonasAzules, hasLength(1));
      }
    });

    test('gris de niveles 2 y 3 es una zona aunque sus celdas estén separadas',
        () {
      for (final (nivel, cantidadDeCeldas) in [
        (niveles[1], 2),
        (niveles[2], 5),
      ]) {
        final zonasGrises = agruparEnRegiones(
          nivel.tipoPorPosicion,
          coloresUnificados: nivel.coloresUnificados,
        ).where((zona) => nivel.tipoPorPosicion[zona.first] is TipoGris);

        expect(zonasGrises, hasLength(1));
        expect(zonasGrises.single, hasLength(cantidadDeCeldas));
      }
    });

    test('mantiene los premios solicitados para azul y gris', () {
      for (final nivel in niveles.take(3)) {
        final azul = nivel.tipoPorPosicion.values.whereType<TipoAzul>().first;
        expect(azul.puntuaciones, {1: 7, 2: 5, 3: 3});
      }

      final azulNivel4 =
          niveles[3].tipoPorPosicion.values.whereType<TipoAzul>().first;
      expect(azulNivel4.puntuaciones, {1: 8, 2: 6, 3: 4});

      final grisNivel2 =
          niveles[1].tipoPorPosicion.values.whereType<TipoGris>().first;
      expect(grisNivel2.puntuaciones, {1: 3, 2: 3, 3: 1});

      final grisNivel3 =
          niveles[2].tipoPorPosicion.values.whereType<TipoGris>().first;
      expect(grisNivel3.puntuaciones, {1: 8, 2: 6, 3: 4});
    });
  });
}
