import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';
 
void main() {
  group('cumpleReglaZonaVerde', () {
    test('zona vacía: cualquier número es válido', () {
      expect(cumpleReglaZonaVerde([], 3), isTrue);
    });
 
    test('zona con números repetidos: sigue siendo válido cualquier número',
        () {
      expect(cumpleReglaZonaVerde([2, 2, 2], 2), isTrue);
    });
 
    test('zona con números distintos: sigue siendo válido cualquier número',
        () {
      expect(cumpleReglaZonaVerde([1, 2, 3, 4, 5], 5), isTrue);
    });
 
    test('es válido para cada uno de los 6 valores posibles de dado', () {
      for (var n = 1; n <= 6; n++) {
        expect(cumpleReglaZonaVerde([1, 1, 1], n), isTrue);
      }
    });
 
    test('no modifica la lista original (sin efectos secundarios)', () {
      final zona = [1, 2, 3];
      final copiaOriginal = List<int>.from(zona);
      cumpleReglaZonaVerde(zona, 6);
      expect(zona, equals(copiaOriginal));
    });
  });
}