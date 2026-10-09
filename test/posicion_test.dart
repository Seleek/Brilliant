import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

void main() {
  group('Posicion (coordenadas x, y)', () {
    test('el primer argumento es x y el segundo es y', () {
      const posicion = Posicion(2, 5);
      expect(posicion.x, 2);
      expect(posicion.y, 5);
    });

    test('dos posiciones con las mismas coordenadas son iguales', () {
      expect(const Posicion(3, 4), equals(const Posicion(3, 4)));
    });

    test('x e y no son intercambiables', () {
      expect(const Posicion(3, 4), isNot(equals(const Posicion(4, 3))));
    });
  });

  group('Tablero con coordenadas x, y', () {
    Tablero tableroVacio() => Tablero.vacio({});

    test('(0, 0) es la esquina superior izquierda', () {
      final tablero = tableroVacio();
      tablero.colocarNumero(const Posicion(0, 0), 4);

      expect(tablero.celdas[0][0].valor, 4);
    });

    test('x avanza de izquierda a derecha sobre la misma fila', () {
      final tablero = tableroVacio();
      tablero.colocarNumero(const Posicion(6, 0), 2);

      expect(tablero.celdas[0][6].valor, 2);
    });

    test('y avanza de arriba hacia abajo sobre la misma columna', () {
      final tablero = tableroVacio();
      tablero.colocarNumero(const Posicion(0, 6), 3);

      expect(tablero.celdas[6][0].valor, 3);
    });

    test('(6, 6) es la esquina inferior derecha', () {
      final tablero = tableroVacio();
      tablero.colocarNumero(const Posicion(6, 6), 5);

      expect(tablero.celdas[6][6].valor, 5);
    });

    test('celdaEn devuelve la celda escrita en esa coordenada', () {
      final tablero = tableroVacio();
      tablero.colocarNumero(const Posicion(1, 5), 6);

      expect(tablero.celdaEn(const Posicion(1, 5)).valor, 6);
      expect(tablero.celdaEn(const Posicion(5, 1)).estaVacia, isTrue);
    });
  });
}