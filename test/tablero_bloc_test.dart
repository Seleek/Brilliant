import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

Tablero _tableroConEstrellitas() => Tablero.vacio(
      {},
      posicionesIniciales: {
        const Posicion(0, 0),
        const Posicion(3, 3),
      },
    );

void main() {
  group('TableroBloc.estadoActual', () {
    test('el estado inicial refleja que el tablero está bloqueado', () {
      final bloc = TableroBloc(_tableroConEstrellitas());
      expect(bloc.estadoActual.bloqueadoPorValoresIniciales, isTrue);
      expect(bloc.estadoActual.mensajeError, isNull);
      bloc.dispose();
    });

    test('rechaza ColocarNumero fuera de una estrellita mientras está '
        'bloqueado, sin modificar el tablero', () {
      final bloc = TableroBloc(_tableroConEstrellitas());
      bloc.agregar(ColocarNumero(const Posicion(1, 1), 5));

      expect(bloc.estadoActual.mensajeError, isNotNull);
      expect(
        bloc.estadoActual.mensajeError,
        contains('valores iniciales'),
      );
      expect(
        bloc.estadoActual.tablero.celdaEn(const Posicion(1, 1)).estaVacia,
        isTrue,
      );
      bloc.dispose();
    });

    test('acepta ColocarNumero sobre una estrellita pendiente', () {
      final bloc = TableroBloc(_tableroConEstrellitas());
      bloc.agregar(ColocarNumero(const Posicion(0, 0), 4));

      expect(bloc.estadoActual.mensajeError, isNull);
      expect(
        bloc.estadoActual.tablero.celdaEn(const Posicion(0, 0)).valor,
        4,
      );
      bloc.dispose();
    });

    test('el estado deja de estar bloqueado tras completar las '
        'estrellitas', () {
      final bloc = TableroBloc(_tableroConEstrellitas());
      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(3, 3), 2));

      expect(bloc.estadoActual.bloqueadoPorValoresIniciales, isFalse);
      bloc.dispose();
    });

    test('una vez desbloqueado, acepta ColocarNumero en cualquier '
        'casilla', () {
      final bloc = TableroBloc(_tableroConEstrellitas());
      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(3, 3), 2));

      bloc.agregar(ColocarNumero(const Posicion(5, 5), 6));

      expect(bloc.estadoActual.mensajeError, isNull);
      expect(
        bloc.estadoActual.tablero.celdaEn(const Posicion(5, 5)).valor,
        6,
      );
      bloc.dispose();
    });
  });

  group('TableroBloc.estados (Stream)', () {
    test('emite un nuevo estado por cada evento procesado', () async {
      final bloc = TableroBloc(_tableroConEstrellitas());
      final estadosEmitidos = <TableroEstado>[];
      final suscripcion = bloc.estado.listen(estadosEmitidos.add);

      bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
      bloc.agregar(ColocarNumero(const Posicion(3, 3), 2));

      // Los eventos del Stream se entregan de forma asíncrona.
      await Future<void>.delayed(Duration.zero);

      expect(estadosEmitidos, hasLength(2));
      expect(estadosEmitidos.last.bloqueadoPorValoresIniciales, isFalse);

      await suscripcion.cancel();
      bloc.dispose();
    });

    test('una jugada rechazada también emite un estado, con mensaje '
        'de error', () async {
      final bloc = TableroBloc(_tableroConEstrellitas());
      final estadosEmitidos = <TableroEstado>[];
      final suscripcion = bloc.estado.listen(estadosEmitidos.add);

      bloc.agregar(ColocarNumero(const Posicion(1, 1), 5));
      await Future<void>.delayed(Duration.zero);

      expect(estadosEmitidos, hasLength(1));
      expect(estadosEmitidos.single.mensajeError, isNotNull);

      await suscripcion.cancel();
      bloc.dispose();
    });
  });
}
