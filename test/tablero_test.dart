
import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';
 
Map<Posicion, Bloque> _mapeoDePrueba() => {
      const Posicion(0, 0): Bloque.bloque1,
      const Posicion(0, 1): Bloque.bloque1,
      const Posicion(3, 3): Bloque.bloque2,
    };
 
void main() {
  group('Tablero.valoresDeBloque', () {
    test('tablero vacío: un bloque con celdas asignadas pero sin '
        'números retorna lista vacía', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      expect(tablero.valoresDeBloque(Bloque.bloque1), isEmpty);
    });
 
    test('un bloque sin ninguna celda asignada retorna lista vacía', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      expect(tablero.valoresDeBloque(Bloque.bloque3), isEmpty);
    });
 
    test('extrae los valores de las celdas ocupadas de un bloque', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 2);
 
      expect(tablero.valoresDeBloque(Bloque.bloque1), unorderedEquals([5, 2]));
    });
 
    test('ignora las celdas vacías del bloque, aunque otras ya tengan '
        'número', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      // (0, 1) se queda vacía a propósito.
 
      expect(tablero.valoresDeBloque(Bloque.bloque1), equals([5]));
    });
 
    test('no mezcla valores de celdas de otros bloques', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(3, 3), 9); // pertenece a bloque2
 
      expect(tablero.valoresDeBloque(Bloque.bloque1), equals([5]));
      expect(tablero.valoresDeBloque(Bloque.bloque2), equals([9]));
    });
 
    test('el resultado se puede usar directamente con las reglas de zona',
        () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(0, 0), 5);
      tablero.colocarNumero(const Posicion(0, 1), 5);
 
      final valores = tablero.valoresDeBloque(Bloque.bloque1);
      expect(cumpleReglaTodosIguales(valores, 5), isTrue);
      expect(cumpleReglaTodosDiferentes(valores, 5), isFalse);
    });
  });
 
  group('Tablero.colocarNumero / celdaEn', () {
    test('colocar un número actualiza la celda correspondiente', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(2, 4), 3);
 
      final celda = tablero.celdaEn(const Posicion(2, 4));
      expect(celda.estaOcupada, isTrue);
      expect(celda.valor, equals(3));
    });
 
    test('las demás celdas siguen vacías tras colocar un número', () {
      final tablero = Tablero.vacio(_mapeoDePrueba());
      tablero.colocarNumero(const Posicion(2, 4), 3);
 
      expect(tablero.celdaEn(const Posicion(0, 0)).estaVacia, isTrue);
    });
  });
}