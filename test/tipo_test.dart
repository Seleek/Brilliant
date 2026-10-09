import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

void main() {
  group('TipoRojo', () {
    final tipo = TipoRojo();

    test('descripcion y color están definidos', () {
      expect(tipo.descripcion, 'Todos los números deben ser diferentes');
      expect(tipo.color, isNotNull);
    });

    test('esPosibleAgregar delega en cumpleReglaTodosDiferentes', () {
      expect(tipo.esPosibleAgregar([1, 2, 3], 4), isTrue);
      expect(tipo.esPosibleAgregar([1, 2, 3], 2), isFalse);
    });

    test('puntuaciones son las de la hoja real', () {
      expect(tipo.puntuaciones, {1: 6, 2: 4, 3: 2});
    });
  });

  group('TipoAmarillo', () {
    final tipo = TipoAmarillo();

    test('esPosibleAgregar delega en cumpleReglaTodosDiferentes', () {
      expect(tipo.esPosibleAgregar([5, 6], 1), isTrue);
      expect(tipo.esPosibleAgregar([5, 6], 6), isFalse);
    });

    test('puntuaciones son las de la hoja real', () {
      expect(tipo.puntuaciones, {1: 8, 2: 6, 3: 4});
    });
  });

  group('TipoAzul', () {
    final tipo = TipoAzul();

    test('descripcion es la indicada', () {
      expect(tipo.descripcion, 'Todos los números deben de ser iguales');
    });

    test('esPosibleAgregar delega en cumpleReglaTodosIguales', () {
      expect(tipo.esPosibleAgregar([2, 2], 2), isTrue);
      expect(tipo.esPosibleAgregar([2, 2], 5), isFalse);
    });

    test('puntuaciones son las de la hoja real', () {
      expect(tipo.puntuaciones, {1: 7, 2: 5, 3: 3});
    });
  });

  group('TipoVerde', () {
    final tipo = TipoVerde();

    test('esPosibleAgregar siempre es true (sin restricciones)', () {
      for (var n = 1; n <= 6; n++) {
        expect(tipo.esPosibleAgregar([1, 1, 1], n), isTrue);
      }
    });

    test('puntuaciones son las de la hoja real', () {
      expect(tipo.puntuaciones, {1: 4, 2: 3, 3: 2});
    });
  });

  group('TipoMorado', () {
    final tipo = TipoMorado();

    test('esPosibleAgregar delega en la regla de máximo 2 diferentes', () {
      expect(tipo.esPosibleAgregar([3, 3], 6), isTrue);
      expect(tipo.esPosibleAgregar([3, 6], 1), isFalse);
    });

    test('puntuaciones son las de la hoja real', () {
      expect(tipo.puntuaciones, {1: 6, 2: 4, 3: 2});
    });
  });

  test('cada tipo tiene un color distinto', () {
    final colores = {
      TipoRojo().color,
      TipoAmarillo().color,
      TipoAzul().color,
      TipoVerde().color,
      TipoMorado().color,
    };
    expect(colores, hasLength(5));
  });
}
