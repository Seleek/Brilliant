import 'package:flutter/material.dart';

class PanelDados extends StatelessWidget {

  final List<int> dados;

  final int turno;

  final int? indiceSeleccionado;

  final ValueChanged<int>? onDadoTocado;

  const PanelDados({
    super.key,
    required this.dados,
    this.turno = 0,
    this.indiceSeleccionado,
    this.onDadoTocado,
  });

  @override
  Widget build(BuildContext context) {
    final pidiendoElegir = dados.isNotEmpty &&
        onDadoTocado != null &&
        indiceSeleccionado == null;

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
                    seleccionado: i == indiceSeleccionado,
                    onTocado: (i < dados.length && onDadoTocado != null)
                        ? () => onDadoTocado!(i)
                        : null,
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
            if (pidiendoElegir)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Elige un dado para ver dónde puedes colocarlo.',
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
  final bool seleccionado;
  final VoidCallback? onTocado;

  const CasillaDado({
    super.key,
    this.valor,
    this.seleccionado = false,
    this.onTocado,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTocado,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: seleccionado ? Colors.blue : Colors.grey.shade400,
            width: seleccionado ? 2.5 : 1.5,
          ),
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
      ),
    );
  }
}