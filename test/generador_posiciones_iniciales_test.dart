import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';

void main() {
  final layout = construirTipoPorPosicionOficial();
  final regiones = agruparEnRegiones(layout);

  Set<Posicion> generar(int semilla) => generarPosicionesInicialesAleatorias(
        semilla: semilla,
        tipoPorPosicion: layout,
      );

  /// Índice de la zona a la que pertenece una posición.
  int zonaDe(Posicion p) => regiones.indexWhere((r) => r.contains(p));

  group('generarPosicionesInicialesAleatorias', () {
    test('siempre devuelve exactamente 6 posiciones distintas', () {
      for (var semilla = 1; semilla <= 100; semilla++) {
        expect(generar(semilla), hasLength(6), reason: 'semilla $semilla');
      }
    });

    test('las posiciones están dentro del tablero (0..6 en x e y)', () {
      for (final posicion in generar(7)) {
        expect(posicion.x, inInclusiveRange(0, 6));
        expect(posicion.y, inInclusiveRange(0, 6));
      }
    });

    test('las 6 posiciones caen en 6 zonas distintas', () {
      for (var semilla = 1; semilla <= 200; semilla++) {
        final zonas = generar(semilla).map(zonaDe).toSet();
        expect(zonas, hasLength(6), reason: 'semilla $semilla');
      }
    });

    test('aparecen los 5 colores del tablero (ninguno se queda sin '
        'estrellita)', () {
      for (var semilla = 1; semilla <= 200; semilla++) {
        final colores =
            generar(semilla).map((p) => layout[p]!.color).toSet();
        expect(colores, hasLength(5), reason: 'semilla $semilla');
      }
    });

    test('la misma semilla siempre da las mismas 6 posiciones (para '
        'que coincidan entre jugadores)', () {
      expect(generar(123), equals(generar(123)));
    });

    test('semillas distintas dan resultados distintos', () {
      final resultados = {
        for (var semilla = 1; semilla <= 10; semilla++)
          (generar(semilla).toList()
                ..sort((a, b) =>
                    a.x != b.x ? a.x.compareTo(b.x) : a.y.compareTo(b.y)))
              .map((p) => '${p.x},${p.y}')
              .join(';'),
      };
      expect(resultados.length, greaterThan(1));
    });

    test('lanza StateError si el tablero tiene menos de 6 zonas', () {
      final poco = {
        const Posicion(0, 0): TipoAzul(),
        const Posicion(1, 0): TipoRojo(),
      };
      expect(
        () => generarPosicionesInicialesAleatorias(
          semilla: 1,
          tipoPorPosicion: poco,
        ),
        throwsStateError,
      );
    });

    test('ninguna casilla toca a otra en horizontal ni en vertical',
        () {
      for (var semilla = 1; semilla <= 300; semilla++) {
        final posiciones = generar(semilla).toList();
        for (var i = 0; i < posiciones.length; i++) {
          for (var j = i + 1; j < posiciones.length; j++) {
            expect(
              posiciones[i].esAdyacenteA(posiciones[j]),
              isFalse,
              reason: 'semilla $semilla: ${posiciones[i]} y '
                  '${posiciones[j]} están pegadas',
            );
          }
        }
      }
    });

    test('lanza StateError si es imposible separarlas: seis zonas en '
        'fila, cada una tocando a la siguiente', () {
      // Colores alternados en fila: son 6 zonas distintas, pero como
      // solo hay 6, hay que usar todas, y cada una toca a la vecina.
      final fila = {
        for (var x = 0; x < 6; x++)
          Posicion(x, 0): x.isEven ? TipoAzul() : TipoRojo(),
      };

      expect(
        () => generarPosicionesInicialesAleatorias(
          semilla: 1,
          tipoPorPosicion: fila,
        ),
        throwsStateError,
      );
    });
  });
}