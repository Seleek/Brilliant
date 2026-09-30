import 'package:flutter/material.dart';

class PanelMano extends StatelessWidget{
  final List<int> numerosEnMano;

  final int? indiceSeleccionado;

  final ValueChanged<int>? onNumeroTocado;

  final VoidCallback? onColocarFicha;

  final VoidCallback? onPasar;

  const PanelMano({
    super.key,
    required this.numerosEnMano,
    this.indiceSeleccionado,
    this.onNumeroTocado,
    this.onColocarFicha,
    this.onPasar,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text(
              'Tu mano',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for(var i = 0; i< numerosEnMano.length;i++)
                  BotonNumeroMano(
                    key: ValueKey('boton_mano_$i'),
                    numero:numerosEnMano[i],
                    seleccionado: i == indiceSeleccionado,
                    onTocado:
                      onNumeroTocado == null ? null : () => onNumeroTocado!(i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onColocarFicha,
                      child: const Text('Colocar ficha'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPasar,
                      child: const Text('Pasar'),
                    ),
                  ),
              ],
            ),
          ],
        )
      ),
    );
  }
}

class BotonNumeroMano extends StatelessWidget{
  final int numero;
  final bool seleccionado;
  final VoidCallback? onTocado;

  const BotonNumeroMano({
    super.key,
    required this.numero,
    this.seleccionado = false,
    this.onTocado,
  });

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: onTocado,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionado ? Colors.blue.shade100 : Colors.white,
          border: Border.all(
            color: seleccionado ? Colors.blue : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$numero',
          style: TextStyle(
            fontSize: 18,
            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}