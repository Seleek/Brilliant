import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

void main() {
  group('generarPosicionesInicialesAleatorias', () {
    test('siempre devuelve exactamente 6 posiciones', () {
      final posiciones = generarPosicionesInicialesAleatorias(semilla: 1);
      expect(posiciones, hasLength(6));
    });

    test('las 6 posiciones están dentro del tablero (0..6 en x e y)', () {
      final posiciones = generarPosicionesInicialesAleatorias(semilla: 7);
      for (final posicion in posiciones) {
        expect(posicion.x, inInclusiveRange(0, 6));
        expect(posicion.y, inInclusiveRange(0, 6));
      }
    });

    test('las 6 posiciones son todas distintas entre sí (es un Set, '
        'no debería hacer falta probarlo, pero confirma que no hay '
        'colisiones silenciosas)', () {
      final posiciones = generarPosicionesInicialesAleatorias(semilla: 99);
      expect(posiciones.toSet(), hasLength(6));
    });

    test('la misma semilla siempre da exactamente las mismas 6 '
        'posiciones (para que coincidan entre jugadores)', () {
      final primeraVez = generarPosicionesInicialesAleatorias(semilla: 123);
      final segundaVez = generarPosicionesInicialesAleatorias(semilla: 123);

      expect(segundaVez, equals(primeraVez));
    });

    test('semillas distintas pueden dar resultados distintos (no está '
        'codeado un único resultado fijo)', () {
      final resultados = {
        for (var semilla = 1; semilla <= 10; semilla++)
          semilla: generarPosicionesInicialesAleatorias(semilla: semilla),
      };

      final resultadosUnicos = resultados.values.map((s) {
        final lista = s.toList()
          ..sort((a, b) =>
              a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y));
        return lista.map((p) => '${p.x},${p.y}').join(';');
      }).toSet();

      expect(resultadosUnicos.length, greaterThan(1));
    });
  });
}
