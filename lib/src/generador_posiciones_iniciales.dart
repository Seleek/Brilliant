import 'dart:math';
import 'celda.dart';
import 'tablero.dart';

Set<Posicion> generarPosicionesInicialesAleatorias({required int semilla}){
  final random = Random(semilla);
  final todasLasPosiciones = [
    for (var y=0; y < Tablero.tamano; y++)
      for (var x=0; x < Tablero.tamano; x++)
        Posicion(x, y)
  ];
  todasLasPosiciones.shuffle(random);
  return todasLasPosiciones.take(6).toSet();
}