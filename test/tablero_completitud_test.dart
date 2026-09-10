import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';
 
Map<Posicion, Bloque> _mapeoDePrueba() => {
      const Posicion(0, 0): Bloque.bloque1,
      const Posicion(0, 1): Bloque.bloque1,
      const Posicion(3, 3): Bloque.bloque2,
    };
 
void main() {
  group('Tablero.bloqueEstaLleno', () {
    test('un bloque recién creado (sin números) no está lleno', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      expect(tablero.bloqueEstaLleno(Bloque.bloque1), isFalse);
    });
 
    test('un bloque parcialmente lleno no está lleno', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      expect(tablero.bloqueEstaLleno(Bloque.bloque1), isFalse);
    });
 
    test('un bloque con todas sus celdas ocupadas está lleno', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 2);
      expect(tablero.bloqueEstaLleno(Bloque.bloque1), isTrue);
    });
 
    test('un bloque de una sola celda está lleno con solo esa celda', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(3, 3), 9);
      expect(tablero.bloqueEstaLleno(Bloque.bloque2), isTrue);
    });
 
    test('un bloque sin ninguna celda asignada nunca está lleno', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      expect(tablero.bloqueEstaLleno(Bloque.bloque3), isFalse);
    });
 
    test('llenar un bloque no afecta a los demás', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 2);
      expect(tablero.bloqueEstaLleno(Bloque.bloque1), isTrue);
      expect(tablero.bloqueEstaLleno(Bloque.bloque2), isFalse);
    });
  });
 
  group('Tablero.bloquesTerminados', () {
    test('tablero recién creado: ningún bloque terminado', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      expect(tablero.bloquesTerminados(), isEmpty);
    });
 
    test('solo devuelve los bloques que ya están completos', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(3, 3), 9); // bloque2 completo
 
      expect(tablero.bloquesTerminados(), equals([Bloque.bloque2]));
    });
 
    test('devuelve varios bloques terminados a la vez', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 2); // bloque1 completo
      tablero.colocarNumero(const Posicion(3, 3), 9); // bloque2 completo
 
      expect(
        tablero.bloquesTerminados(),
        unorderedEquals([Bloque.bloque1, Bloque.bloque2]),
      );
    });
 
    test('bloque3 nunca aparece como terminado (no tiene celdas)', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 2);
      tablero.colocarNumero(const Posicion(3, 3), 9);
 
      expect(tablero.bloquesTerminados(), isNot(contains(Bloque.bloque3)));
    });
  });
}
 