import 'tablero.dart';

int calcularPuntuacion(Tablero tablero, Map<Bloque, int> ordenDeFinalizacion,){
  var total = 0;
  for(final bloque in tablero.bloquesTerminados()){
    final tipo = tablero.tipoDe(bloque);
    if(tipo == null) continue;

    final lugar = ordenDeFinalizacion[bloque];
    if(lugar == null) continue;

    total += tipo.puntuaciones[lugar] ?? 0;
  }
  return total;
} 

int puntosDeBloque(Tablero tablero, Bloque bloque, int lugar){
  if(!tablero.bloqueEstaLleno(  bloque)) return 0;
  final tipo = tablero.tipoDe(bloque);
  if(tipo == null) return 0;
  return tipo.puntuaciones[lugar] ?? 0;
}