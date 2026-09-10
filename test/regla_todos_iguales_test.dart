import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';
 
void main() {
  group('cumpleReglaTodosIguales', () {
    test('zona vacía: cualquier número es válido (la inicia)', () {
      expect(cumpleReglaTodosIguales([], 5), isTrue);
    });
 
    test('el número a insertar coincide con el ya establecido -> válido',
        () {
      expect(cumpleReglaTodosIguales([2, 2, 2], 2), isTrue);
    });
 
    test('el número a insertar no coincide con el ya establecido -> inválido',
        () {
      expect(cumpleReglaTodosIguales([2, 2, 2], 5), isFalse);
    });
 
    test('zona con un solo número ya escrito', () {
      expect(cumpleReglaTodosIguales([4], 4), isTrue);
      expect(cumpleReglaTodosIguales([4], 1), isFalse);
    });
 
    test('no modifica la lista original (sin efectos secundarios)', () {
      final zona = [3, 3];
      final copiaOriginal = List<int>.from(zona);
      cumpleReglaTodosIguales(zona, 3);
      expect(zona, equals(copiaOriginal));
    });
  });
}