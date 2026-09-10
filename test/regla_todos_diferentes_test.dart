import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

void main() {
  group('Celda', () {
    test('una celda recién creada está vacía', () {
      const celda = Celda.vacia();
      expect(celda.estaVacia, isTrue);
      expect(celda.estaOcupada, isFalse);
      expect(celda.valor, isNull);
    });

    test('una celda ocupada guarda su valor', () {
      const celda = Celda.ocupada(4);
      expect(celda.estaOcupada, isTrue);
      expect(celda.estaVacia, isFalse);
      expect(celda.valor, equals(4));
    });

    test('rechaza valores fuera del rango de un dado (1-6)', () {
      expect(() => Celda.ocupada(0), throwsA(isA<AssertionError>()));
      expect(() => Celda.ocupada(7), throwsA(isA<AssertionError>()));
    });
  });

  group('cumpleReglaTodosDiferentes', () {
    test('zona vacía: cualquier número es válido', () {
      expect(cumpleReglaTodosDiferentes([], 3), isTrue);
    });

    test('el número a insertar no está repetido -> válido', () {
      expect(cumpleReglaTodosDiferentes([1, 2, 5], 4), isTrue);
    });

    test('el número a insertar ya existe en la zona -> inválido', () {
      expect(cumpleReglaTodosDiferentes([1, 2, 5], 2), isFalse);
    });

    test('detecta duplicado aunque esté al final de la lista', () {
      expect(cumpleReglaTodosDiferentes([6, 3, 1, 4], 4), isFalse);
    });

    test('zona casi llena (5 de 6 valores de dado) sin duplicados', () {
      expect(cumpleReglaTodosDiferentes([1, 2, 3, 4, 5], 6), isTrue);
    });

    test('zona con todos los valores de dado ya usados -> siempre inválido',
        () {
      final zonaCompleta = [1, 2, 3, 4, 5, 6];
      for (final n in zonaCompleta) {
        expect(cumpleReglaTodosDiferentes(zonaCompleta, n), isFalse);
      }
    });

    test('no modifica la lista original (sin efectos secundarios)', () {
      final zona = [1, 2, 3];
      final copiaOriginal = List<int>.from(zona);
      cumpleReglaTodosDiferentes(zona, 3);
      expect(zona, equals(copiaOriginal));
    });
  });
}
