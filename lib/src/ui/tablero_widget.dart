import 'package:flutter/material.dart';

import '../celda.dart';
import '../tablero.dart';
import '../tablero_bloc.dart';
import '../tipo.dart';

class TableroWidget extends StatelessWidget {
  final TableroBloc bloc;

  final Map<Posicion, Tipo> tipoPorPosicion;

  const TableroWidget({
    super.key,
    required this.bloc,
    this.tipoPorPosicion = const {},
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TableroEstado>(
      stream: bloc.estado,
      initialData: bloc.estadoActual,
      builder: (context, snapshot) {
        final estado = snapshot.data!;

        return AspectRatio(
                   aspectRatio: 1,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Tablero.tamano * Tablero.tamano,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Tablero.tamano,
            ),
            itemBuilder: (context, index) {
                          final x = index % Tablero.tamano;
              final y = index ~/ Tablero.tamano;
              final posicion = Posicion(x, y);
              final esSeleccionada = posicion == estado.posicionSeleccionada;

              final celda = estado.tablero.celdaEn(posicion);

                            final indice = estado.indiceNumeroSeleccionado;
              final numeroPreview = (esSeleccionada && indice != null)
                  ? estado.numerosEnMano[indice]
                  : null;

              return CasillaTablero(
                key: ValueKey('celda_${x}_$y'),
                seleccionada: esSeleccionada,
                esInicial: estado.tablero.posicionesIniciales.contains(posicion),
                               iluminada:
                    estado.tablero.posicionesIniciales.contains(posicion) &&
                        !estado.partidaIniciada,
                valor: celda.estaOcupada ? celda.valor : null,
                numeroPreview: numeroPreview,
                colorZona: tipoPorPosicion[posicion]?.color,
                onTap: () => bloc.agregar(SeleccionarCelda(posicion)),
              );
            },
          ),
        );
      },
    );
  }
}

class CasillaTablero extends StatelessWidget {
  final bool seleccionada;

    final bool esInicial;

   final bool iluminada;

  final int? valor;
  final int? numeroPreview;
  final Color? colorZona;
  final VoidCallback? onTap;

  const CasillaTablero({
    super.key,
    this.seleccionada = false,
    this.esInicial = false,
    this.iluminada = false,
    this.valor,
    this.numeroPreview,
    this.colorZona,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarPreview = valor == null && numeroPreview != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorZona ?? Colors.white,
          border: Border.all(
            color: seleccionada
                ? Colors.deepOrange
                : (iluminada ? Colors.amber : Colors.black),
            width: seleccionada ? 3 : (iluminada ? 2 : 1),
          ),
          boxShadow: iluminada
              ? const [
                  BoxShadow(
                    color: Colors.amberAccent,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (iluminada)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [Colors.white70, Colors.transparent],
                    ),
                  ),
                ),
              ),
            if (valor != null)
              Text(
                '$valor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (mostrarPreview)
              Opacity(
                opacity: 0.45,
                child: Text(
                  '$numeroPreview',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (esInicial)
              const Positioned(
                top: 1,
                right: 1,
                child: Icon(Icons.star, size: 12, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }
}