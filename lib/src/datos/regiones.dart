import 'package:flutter/material.dart';

import '../celda.dart';
import '../tablero.dart';
import '../tipo.dart';

List<Set<Posicion>> agruparEnRegiones(
  Map<Posicion, Tipo> tipoPorPosicion, {
  Set<Color> coloresUnificados = const {},
  Map<Color, int> divisionesPorColumna = const {},
  Map<Color, int> divisionesPorFila = const {},
}) {
  final regiones = <Set<Posicion>>[];
  final visitadas = <Posicion>{};

  for (var y = 0; y < Tablero.tamano; y++) {
    for (var x = 0; x < Tablero.tamano; x++) {
      final inicio = Posicion(x, y);
      if (visitadas.contains(inicio) || !tipoPorPosicion.containsKey(inicio)) {
        continue;
      }

      final color = tipoPorPosicion[inicio]!.color;
      if (coloresUnificados.contains(color)) {
        final region = tipoPorPosicion.entries
            .where((entrada) => entrada.value.color == color)
            .map((entrada) => entrada.key)
            .toSet();
        visitadas.addAll(region);
        regiones.add(region);
        continue;
      }

      final division = divisionesPorColumna[color];
      if (division != null) {
        for (final lado in [true, false]) {
          final region = tipoPorPosicion.entries
              .where(
                (entrada) =>
                    entrada.value.color == color &&
                    (entrada.key.x <= division) == lado,
              )
              .map((entrada) => entrada.key)
              .toSet();
          if (region.isNotEmpty) {
            visitadas.addAll(region);
            regiones.add(region);
          }
        }
        continue;
      }

      final divisionFila = divisionesPorFila[color];
      if (divisionFila != null) {
        for (final lado in [true, false]) {
          final region = tipoPorPosicion.entries
              .where(
                (entrada) =>
                    entrada.value.color == color &&
                    (entrada.key.y <= divisionFila) == lado,
              )
              .map((entrada) => entrada.key)
              .toSet();
          if (region.isNotEmpty) {
            visitadas.addAll(region);
            regiones.add(region);
          }
        }
        continue;
      }

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
