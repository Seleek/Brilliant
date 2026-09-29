import 'package:flutter/material.dart';
import '../tablero.dart';

class TableroWidget extends StatelessWidget{
  const TableroWidget({super.key});
  
  @override
  Widget build(BuildContext context){
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics:const NeverScrollableScrollPhysics(),
        itemCount: Tablero.tamano * Tablero.tamano,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Tablero.tamano,),
        itemBuilder:(context, index) {
          final x = index % Tablero.tamano;
          final y = index ~/ Tablero.tamano;
          return CasillaTablero(key: ValueKey('celda_${x}_$y'));
        },
      ),
    );
  }
}

class CasillaTablero extends StatelessWidget{
  const CasillaTablero({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }
}