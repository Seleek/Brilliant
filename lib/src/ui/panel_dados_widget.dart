import 'package:flutter/material.dart';

class PanelDados extends StatelessWidget {

  final List<int> dados;

  final int turno;

  const PanelDados({super.key, required this.dados, this.turno = 0});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dados',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (turno > 0)
                  Text(
                    'Turno $turno',
                    style: const TextStyle(color: Colors.black54),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  CasillaDado(
                    key: ValueKey('dado_$i'),
                    valor: i < dados.length ? dados[i] : null,
                  ),
                ],
              ],
            ),
            if (dados.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Los dados se tiran al iniciar la partida.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CasillaDado extends StatelessWidget {
  final int? valor;

  const CasillaDado({super.key, this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        valor == null ? '–' : '$valor',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: valor == null ? Colors.black26 : Colors.black87,
        ),
      ),
    );
  }
}