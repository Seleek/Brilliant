import 'package:brilliant/brilliant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TableroBloc puntuación de zonas verdes', () {
    test('otorga 4 puntos al completar una zona verde', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoVerde(),
          const Posicion(1, 0): TipoVerde(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 0);

      bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));
      expect(bloc.estadoActual.puntajeTotal, 4);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 5));
      expect(bloc.estadoActual.puntajeTotal, 4);

      bloc.dispose();
    });

    test('puntúa por separado dos zonas verdes desconectadas', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoVerde(),
          const Posicion(1, 0): TipoVerde(),
          const Posicion(2, 0): TipoRojo(),
          const Posicion(3, 0): TipoVerde(),
          const Posicion(4, 0): TipoVerde(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 6));
      expect(bloc.estadoActual.puntajeTotal, 4);

      bloc.agregar(ColocarNumero(const Posicion(3, 0), 3));
      bloc.agregar(ColocarNumero(const Posicion(4, 0), 3));
      expect(bloc.estadoActual.puntajeTotal, 8);

      bloc.dispose();
    });

    test('la zona verde permite repetir cualquier número', () {
      final tablero = Tablero.vacio(
        const {},
        tipoPorPosicion: {
          const Posicion(0, 0): TipoVerde(),
          const Posicion(1, 0): TipoVerde(),
        },
      );
      final bloc = TableroBloc(tablero);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 6));
      bloc.agregar(ColocarNumero(const Posicion(1, 0), 6));

      expect(bloc.estadoActual.mensajeError, isNull);
      expect(bloc.estadoActual.puntajeTotal, 4);

      bloc.dispose();
    });
  });
}
