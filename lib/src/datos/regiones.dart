import '../celda.dart';
import '../tablero.dart';
import '../tipo.dart';

List<Set<Posicion>> agruparEnRegiones(Map<Posicion, Tipo> tipoPorPosicion) {
  final regiones = <Set<Posicion>>[];
  final visitadas = <Posicion>{};

  for (var y = 0; y < Tablero.tamano; y++) {
    for (var x = 0; x < Tablero.tamano; x++) {
      final inicio = Posicion(x, y);
      if (visitadas.contains(inicio) || !tipoPorPosicion.containsKey(inicio)) {
        continue;
      }

      final color = tipoPorPosicion[inicio]!.color;
      final region = <Posicion>{};
      final pendientes = <Posicion>[inicio];
      visitadas.add(inicio);

      while (pendientes.isNotEmpty) {
        final actual = pendientes.removeLast();
        region.add(actual);

        for (final vecino in _vecinosOrtogonales(actual)) {
          if (visitadas.contains(vecino)) continue;
          final tipoVecino = tipoPorPosicion[vecino];
          if (tipoVecino == null || tipoVecino.color != color) continue;
          visitadas.add(vecino);
          pendientes.add(vecino);
        }
      }

      regiones.add(region);
    }
  }

  return regiones;
}

Iterable<Posicion> _vecinosOrtogonales(Posicion p) sync* {
  const desplazamientos = [(1, 0), (-1, 0), (0, 1), (0, -1)];
  for (final (dx, dy) in desplazamientos) {
    final x = p.x + dx;
    final y = p.y + dy;
    if (x >= 0 && x < Tablero.tamano && y >= 0 && y < Tablero.tamano) {
      yield Posicion(x, y);
    }
  }
}