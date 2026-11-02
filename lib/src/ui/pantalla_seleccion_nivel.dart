import 'package:flutter/material.dart';

import '../datos/niveles.dart';

class PantallaSeleccionNivel extends StatelessWidget {
  final List<Nivel> niveles;
  final ValueChanged<Nivel> onNivelElegido;

  const PantallaSeleccionNivel({
    super.key,
    required this.niveles,
    required this.onNivelElegido,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Elige un nivel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              for (final nivel in niveles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    key: ValueKey('nivel_${nivel.numero}'),
                    onPressed: () => onNivelElegido(nivel),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(nivel.nombre),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}