import 'package:flutter/material.dart';

import '../datos/niveles.dart';
import '../datos/regiones.dart';

class ReglasNivelWidget extends StatelessWidget {
  final Nivel nivel;

  const ReglasNivelWidget({super.key, required this.nivel});

  @override
  Widget build(BuildContext context) {
    final zonas = agruparEnRegiones(
      nivel.tipoPorPosicion,
      coloresUnificados: nivel.coloresUnificados,
      divisionesPorColumna: nivel.divisionesPorColumna,
      divisionesPorFila: nivel.divisionesPorFila,
    );

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
            for (var indice = 0; indice < zonas.length; indice++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 14,
                      color: nivel.tipoPorPosicion[zonas[indice].first]!.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zona ${indice + 1}: '
                        '${nivel.tipoPorPosicion[zonas[indice].first]!.descripcion}',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
