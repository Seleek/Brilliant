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
 
              return CasillaTablero(
                key: ValueKey('celda_${x}_$y'),
                seleccionada: posicion == estado.posicionSeleccionada,
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
  final VoidCallback? onTap;

  const CasillaTablero({super.key, this.seleccionada = false, this.onTap});

  @override
  Widget build(BuildContext context){
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: seleccionada ? Colors.blue.shade200 : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}