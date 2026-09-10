import 'celda.dart';

enum Bloque {
  bloque1,
  bloque2,
  bloque3,
  bloque4,
}
 
class Tablero {
  static const int tamano = 7;
 
 final List<List<Celda>> celdas;
 
  final Map<Posicion, Bloque> bloquePorPosicion;
 
  Tablero({required this.celdas, required this.bloquePorPosicion})
      : assert(celdas.length == tamano,
            'El tablero debe tener $tamano filas'),
        assert(celdas.every((fila) => fila.length == tamano),
            'Cada fila del tablero debe tener $tamano columnas');
 
  factory Tablero.vacio(Map<Posicion, Bloque> bloquePorPosicion) {
    return Tablero(
      celdas: List.generate(
        tamano,
        (_) => List.generate(tamano, (_) => const Celda.vacia()),
      ),
      bloquePorPosicion: bloquePorPosicion,
    );
  }
 
  Celda celdaEn(Posicion posicion) => celdas[posicion.fila][posicion.columna];
 
  void colocarNumero(Posicion posicion, int valor) {
    celdas[posicion.fila][posicion.columna] = Celda.ocupada(valor);
  }

  List<int> valoresDeBloque(Bloque bloque) {
    final valores = <int>[];
    bloquePorPosicion.forEach((posicion, bloqueDeLaCelda) {
      if (bloqueDeLaCelda == bloque) {
        final celda = celdaEn(posicion);
        if (celda.estaOcupada) valores.add(celda.valor!);
      }
    });
    return valores;
  }
 
  List<Posicion> _posicionesDeBloque(Bloque bloque) {
    final posiciones = <Posicion>[];
    bloquePorPosicion.forEach((posicion, bloqueDeLaCelda) {
      if (bloqueDeLaCelda == bloque) posiciones.add(posicion);
    });
    return posiciones;
  }
  bool bloqueEstaLleno(Bloque bloque) {
    final posiciones = _posicionesDeBloque(bloque);
    if (posiciones.isEmpty) return false;
    return posiciones.every((posicion) => celdaEn(posicion).estaOcupada);
  }
 
 List<Bloque> bloquesTerminados() {
    final bloquesDelTablero = bloquePorPosicion.values.toSet();
    return bloquesDelTablero
        .where((bloque) => bloqueEstaLleno(bloque))
        .toList();
  }
}