import 'package:flutter/material.dart';
import '../celda.dart';
import '../tablero.dart';
import '../tablero_bloc.dart';

class TableroWidget extends StatelessWidget{
  final TableroBloc bloc;
  const TableroWidget({super.key, required this.bloc});
  
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
                valor: celda.estaOcupada ? celda.valor : null,
                numeroPreview: numeroPreview,
                onTap: () => bloc.agregar(SeleccionarCelda(posicion)),
              );
            },
          ),
        );
      },
    );
  }
}

class CasillaTablero extends StatelessWidget{

  final bool seleccionada;
  final int? valor;
  final int? numeroPreview;
  final VoidCallback? onTap;

  const CasillaTablero({super.key, this.seleccionada = false, this.valor, this.numeroPreview, this.onTap});

  @override
  Widget build(BuildContext context){
    final mostrarPreview = valor == null && numeroPreview != null;

    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: seleccionada ? Colors.blue.shade200 : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: valor != null
            ? Text(
                '$valor',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            : mostrarPreview
                ? Opacity(
                    opacity: 0.4,
                    child: Text(
                      '$numeroPreview',
                      style: const TextStyle(fontSize: 18),
                    ),
                  )
                : null,
      ),
    );
  }
}