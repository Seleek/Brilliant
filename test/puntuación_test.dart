import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

Map<Posicion, Bloque> _mapeoDePrueba() => {
      const Posicion(0, 0): Bloque.bloque1,
      const Posicion(1, 0): Bloque.bloque1,
      const Posicion(3, 3): Bloque.bloque2,
    };

Map<Bloque, Tipo> _tiposDePrueba() => {
      Bloque.bloque1: TipoAzul(),
      Bloque.bloque2: TipoAzul(),
    };

Tablero _tablero() => Tablero.vacio(
      _mapeoDePrueba(),
      tipoPorBloque: _tiposDePrueba(),
    );

void main() {
  group('puntosDeBloque', () {
    test('un bloque sin terminar no otorga puntos', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);

      expect(puntosDeBloque(tablero, Bloque.bloque1, 1), 0);
    });

    test('terminar primero otorga la puntuación más alta', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2);

      expect(puntosDeBloque(tablero, Bloque.bloque1, 1), 7);
    });

    test('terminar segundo o tercero otorga menos puntos', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2);

      expect(puntosDeBloque(tablero, Bloque.bloque1, 2), 5);
      expect(puntosDeBloque(tablero, Bloque.bloque1, 3), 3);
    });

    test('un lugar fuera de la tabla de puntuaciones no otorga puntos', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2);

      expect(puntosDeBloque(tablero, Bloque.bloque1, 4), 0);
    });

    test('un bloque sin tipo asignado no otorga puntos', () {
      final tablero = Tablero.vacio(_mapeoDePrueba()); // sin tipos
      tablero.colocarNumero(const Posicion(3, 3), 6);

      expect(puntosDeBloque(tablero, Bloque.bloque2, 1), 0);
    });
  });

  group('calcularPuntuacion', () {
    test('tablero sin zonas terminadas: 0 puntos', () {
      final tablero = _tablero();
      expect(calcularPuntuacion(tablero, {Bloque.bloque1: 1}), 0);
    });

    test('suma los puntos de cada zona según el lugar en que se '
        'completó', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2); // bloque1 completo
      tablero.colocarNumero(const Posicion(3, 3), 6); // bloque2 completo

      expect(
        calcularPuntuacion(tablero, {
          Bloque.bloque1: 1,
          Bloque.bloque2: 3,
        }),
        10,
      );
    });

    test('el mismo tablero da distinta puntuación según el orden de '
        'finalización', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2);
      tablero.colocarNumero(const Posicion(3, 3), 6);

      final llegandoPrimero = calcularPuntuacion(tablero, {
        Bloque.bloque1: 1,
        Bloque.bloque2: 1,
      });
      final llegandoSegundo = calcularPuntuacion(tablero, {
        Bloque.bloque1: 2,
        Bloque.bloque2: 2,
      });

      expect(llegandoPrimero, 14); 
      expect(llegandoSegundo, 10); 
      expect(llegandoPrimero, greaterThan(llegandoSegundo));
    });

    test('una zona terminada sin lugar registrado no aporta puntos', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(0, 0), 2);
      tablero.colocarNumero(const Posicion(1, 0), 2);
      tablero.colocarNumero(const Posicion(3, 3), 6);

      // Solo se registra el lugar de bloque1.
      expect(calcularPuntuacion(tablero, {Bloque.bloque1: 1}), 7);
    });

    test('las zonas sin terminar se ignoran aunque tengan lugar '
        'registrado', () {
      final tablero = _tablero();
      tablero.colocarNumero(const Posicion(3, 3), 6);

      expect(
        calcularPuntuacion(tablero, {
          Bloque.bloque1: 1, 
          Bloque.bloque2: 1,
        }),
        7,
      );
    });
  });
}
