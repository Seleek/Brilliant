import 'package:flutter/material.dart';

import '../datos/niveles.dart';
import '../datos/regiones.dart';

class ReglasNivelWidget extends StatelessWidget {
  final Nivel nivel;
  final bool expandible;

  const ReglasNivelWidget({
    super.key,
    required this.nivel,
    this.expandible = false,
  });

  @override
  Widget build(BuildContext context) {
    final zonas = agruparEnRegiones(
      nivel.tipoPorPosicion,
      coloresUnificados: nivel.coloresUnificados,
      divisionesPorColumna: nivel.divisionesPorColumna,
      divisionesPorFila: nivel.divisionesPorFila,
    );
    final reglasPorColor = <Color, Set<String>>{};
    for (final zona in zonas) {
      final tipo = nivel.tipoPorPosicion[zona.first]!;
      reglasPorColor.putIfAbsent(tipo.color, () => <String>{}).add(
            tipo.descripcion,
          );
    }
    final reglas = reglasPorColor.entries.toList();

    if (expandible) {
      return Card(
        margin: EdgeInsets.zero,
        child: ExpansionTile(
          title: const Text(
            'Reglas de las zonas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          children: [
            for (final regla in reglas) _filaRegla(regla),
          ],
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Reglas de las zonas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final regla in reglas) _filaRegla(regla),
          ],
        ),
      ),
    );
  }

  Widget _filaRegla(MapEntry<Color, Set<String>> regla) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle, size: 14, color: regla.key),
            const SizedBox(width: 8),
            Expanded(child: Text(regla.value.join('; '))),
          ],
        ),
      );
}
