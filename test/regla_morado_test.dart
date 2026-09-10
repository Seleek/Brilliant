
import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';
 
void main() {
  group('cumpleReglaMoradoMaximoDosDiferentes', () {
    test('zona vacía: cualquier número es válido (la inicia)', () {
      expect(cumpleReglaMoradoMaximoDosDiferentes([], 4), isTrue);
    });
 
    test('zona con 1 valor distinto: repetir ese mismo valor es válido', () {
      expect(cumpleReglaMoradoMaximoDosDiferentes([3, 3], 3), isTrue);
    });
 
    test('zona con 1 valor distinto: agregar un segundo valor es válido',
        () {
      expect(cumpleReglaMoradoMaximoDosDiferentes([3, 3], 6), isTrue);
    });
 
    test('zona con 2 valores distintos: repetir cualquiera de los dos es '
        'válido', () {
      expect(cumpleReglaMoradoMaximoDosDiferentes([3, 6, 3], 6), isTrue);
      expect(cumpleReglaMoradoMaximoDosDiferentes([3, 6, 3], 3), isTrue);
    });
 
    test('zona con 2 valores distintos: agregar un tercer valor es '
        'inválido', () {
      expect(cumpleReglaMoradoMaximoDosDiferentes([3, 6, 3], 1), isFalse);
    });
 
    test('zona con 2 valores distintos y muchas repeticiones sigue '
        'rechazando un tercer valor nuevo', () {
      final zona = [2, 2, 5, 2, 5, 5, 5];
      expect(cumpleReglaMoradoMaximoDosDiferentes(zona, 1), isFalse);
      expect(cumpleReglaMoradoMaximoDosDiferentes(zona, 2), isTrue);
      expect(cumpleReglaMoradoMaximoDosDiferentes(zona, 5), isTrue);
    });
 
    test('no modifica la lista original (sin efectos secundarios)', () {
      final zona = [1, 4, 1];
      final copiaOriginal = List<int>.from(zona);
      cumpleReglaMoradoMaximoDosDiferentes(zona, 6);
      expect(zona, equals(copiaOriginal));
    });
  });
}