import 'package:flutter/material.dart';

import '../celda.dart';
import '../tablero.dart';
import '../tablero_bloc.dart';
import '../tipo.dart';

/// Dibuja la cuadrícula de 7x7 casillas del tablero, cada una
/// delineada con una línea negra para poder distinguirlas, y
/// pintada con el color de su zona.
///
/// Está conectado a un [TableroBloc]: escucha su [TableroBloc.estado]
/// con un `StreamBuilder` y, al tocar una casilla, manda un evento
/// [SeleccionarCelda] en vez de manejar la selección por su cuenta.
/// La UI nunca decide "estoy seleccionada" ni "qué número mostrar" —
/// solo refleja lo que el [TableroEstado] más reciente dice.
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

  final int? valor;
  final int? numeroPreview;
  final Color? colorZona;
  final VoidCallback? onTap;

  const CasillaTablero({
    super.key,
    this.seleccionada = false,
    this.esInicial = false,
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
            color: seleccionada ? Colors.deepOrange : Colors.black,
            width: seleccionada ? 3 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
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