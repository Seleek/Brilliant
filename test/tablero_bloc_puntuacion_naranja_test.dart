import 'package:brilliant/brilliant.dart';
import 'package:brilliant/src/datos/niveles.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableroBloc puntuación naranja', () {
    test('las franjas superior e inferior puntúan por separado en orden', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoNaranja(minimo: 4, maximo: 6),
          const Posicion(1, 0): TipoNaranja(minimo: 4, maximo: 6),
          const Posicion(0, 6): TipoNaranja(minimo: 1, maximo: 3),
          const Posicion(1, 6): TipoNaranja(minimo: 1, maximo: 3),
        },
        divisionesPorFila: {TipoNaranja(minimo: 4, maximo: 6).color: 3},
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 4));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 6));
      expect(bloc.estadoActual.puntajeTotal, 6);

      bloc.agregar(ColocarNumero(const Posicion(0, 6), 1));
      bloc.agregar(ColocarNumero(const Posicion(1, 6), 3));
      expect(bloc.estadoActual.puntajeTotal, 10);

      bloc.dispose();
    });

    test('rechaza números fuera del rango de la franja', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoNaranja(minimo: 4, maximo: 6),
          const Posicion(0, 6): TipoNaranja(minimo: 1, maximo: 3),
        },
        divisionesPorFila: {TipoNaranja(minimo: 4, maximo: 6).color: 3},
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 3));
      expect(bloc.estadoActual.mensajeError, contains('4 al 6'));
      expect(bloc.estadoActual.tablero.celdaEn(const Posicion(0, 0)).estaVacia,
          isTrue);

      bloc.agregar(ColocarNumero(const Posicion(0, 6), 4));
      expect(bloc.estadoActual.mensajeError, contains('1 al 3'));
      expect(bloc.estadoActual.tablero.celdaEn(const Posicion(0, 6)).estaVacia,
          isTrue);

      bloc.dispose();
    });
  });

  test('el nivel 4 configura dos zonas naranjas con las puntuaciones indicadas',
      () {
    final nivel = construirNiveles()[3];
    final zonasNaranjas = agruparEnRegiones(
      nivel.tipoPorPosicion,
      coloresUnificados: nivel.coloresUnificados,
      divisionesPorColumna: nivel.divisionesPorColumna,
      divisionesPorFila: nivel.divisionesPorFila,
    ).where((zona) => nivel.tipoPorPosicion[zona.first] is TipoNaranja);

    expect(zonasNaranjas, hasLength(2));
    for (final zona in zonasNaranjas) {
      final y = zona.first.y;
      expect(zona.every((posicion) => posicion.y == y), isTrue);
    }

    final naranjaSuperior = nivel.tipoPorPosicion.values
        .whereType<TipoNaranja>()
        .firstWhere((tipo) => tipo.minimo == 4);
    final naranjaInferior = nivel.tipoPorPosicion.values
        .whereType<TipoNaranja>()
        .firstWhere((tipo) => tipo.minimo == 1);
    expect(naranjaSuperior.puntuaciones, {1: 6, 2: 4, 3: 3});
    expect(naranjaInferior.puntuaciones, {1: 6, 2: 4, 3: 3});
  });
}
