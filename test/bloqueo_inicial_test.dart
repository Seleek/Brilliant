import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';

Tablero _tableroConEstrellitas() => Tablero.vacio(
      {},
      posicionesIniciales: {
        const Posicion(0, 0),
        const Posicion(3, 3),
        const Posicion(6, 6),
      },
    );

void main() {
  group('Tablero.bloqueadoPorValoresIniciales', () {
    test('un tablero recién creado con estrellitas empieza bloqueado', () {
      final tablero = _tableroConEstrellitas();
      expect(tablero.bloqueadoPorValoresIniciales, isTrue);
    });

    test('sigue bloqueado mientras falte alguna estrellita', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 1);
      tablero.colocarNumero(const Posicion(3, 3), 2);
      expect(tablero.bloqueadoPorValoresIniciales, isTrue);
    });

    test('se desbloquea al completar todas las estrellitas', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 1);
      tablero.colocarNumero(const Posicion(3, 3), 2);
      tablero.colocarNumero(const Posicion(6, 6), 3);
      expect(tablero.bloqueadoPorValoresIniciales, isFalse);
    });

    test('un tablero sin estrellitas configuradas nunca está bloqueado',
        () {
      final tablero = Tablero.vacio({}); 
      expect(tablero.bloqueadoPorValoresIniciales, isFalse);
    });
  });

  group('Tablero.puedeColocarEn', () {
    test('mientras está bloqueado, sí se puede escribir en una '
        'estrellita pendiente', () {
      final tablero = _tableroConEstrellitas();
      expect(tablero.puedeColocarEn(const Posicion(3, 3)), isTrue);
    });

    test('mientras está bloqueado, NO se puede escribir fuera de las '
        'estrellitas', () {
      final tablero = _tableroConEstrellitas();
      expect(tablero.puedeColocarEn(const Posicion(1, 1)), isFalse);
    });

    test('una vez desbloqueado, se puede escribir en cualquier casilla',
        () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 1);
      tablero.colocarNumero(const Posicion(3, 3), 2);
      tablero.colocarNumero(const Posicion(6, 6), 3);

      expect(tablero.puedeColocarEn(const Posicion(1, 1)), isTrue);
    });
  });

  group('Tablero.intentarColocarNumero', () {
    test('rechaza la jugada si el tablero sigue bloqueado y la '
        'posición no es una estrellita', () {
      final tablero = _tableroConEstrellitas();
      final exito = tablero.intentarColocarNumero(const Posicion(1, 1), 5);

      expect(exito, isFalse);
      expect(tablero.celdaEn(const Posicion(1, 1)).estaVacia, isTrue);
    });

    test('acepta la jugada sobre una estrellita pendiente', () {
      final tablero = _tableroConEstrellitas();
      final exito = tablero.intentarColocarNumero(const Posicion(0, 0), 4);

      expect(exito, isTrue);
      expect(tablero.celdaEn(const Posicion(0, 0)).valor, 4);
    });

    test('una vez completadas las estrellitas, acepta jugadas en '
        'cualquier casilla', () {
      final tablero = _tableroConEstrellitas();
      tablero.intentarColocarNumero(const Posicion(0, 0), 1);
      tablero.intentarColocarNumero(const Posicion(3, 3), 2);
      tablero.intentarColocarNumero(const Posicion(6, 6), 3);

      final exito = tablero.intentarColocarNumero(const Posicion(2, 5), 6);

      expect(exito, isTrue);
      expect(tablero.celdaEn(const Posicion(2, 5)).valor, 6);
    });

    test('colocarNumero (sin "intentar") ignora el bloqueo, para armar '
        'escenarios de prueba', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(1, 1), 5);

      expect(tablero.celdaEn(const Posicion(1, 1)).valor, 5);
      expect(tablero.bloqueadoPorValoresIniciales, isTrue);
    });
  });

  group('Tablero.valoresInicialesSonDiferentes', () {
    test('sin ningún número escrito, no hay repetidos', () {
      expect(_tableroConEstrellitas().valoresInicialesSonDiferentes, isTrue);
    });

    test('con números distintos, es true', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 1);
      tablero.colocarNumero(const Posicion(3, 3), 2);
      expect(tablero.valoresInicialesSonDiferentes, isTrue);
    });

    test('con dos estrellitas con el mismo número, es false', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 4);
      tablero.colocarNumero(const Posicion(3, 3), 4);
      expect(tablero.valoresInicialesSonDiferentes, isFalse);
    });

    test('un número repetido fuera de las estrellitas no cuenta', () {
      final tablero = _tableroConEstrellitas();
      tablero.colocarNumero(const Posicion(0, 0), 4);
      tablero.colocarNumero(const Posicion(1, 1), 4); // no es estrellita
      expect(tablero.valoresInicialesSonDiferentes, isTrue);
    });
  });
}
