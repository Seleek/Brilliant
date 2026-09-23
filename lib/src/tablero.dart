import 'package:flutter/material.dart';
import 'celda.dart';
import 'tipo.dart';

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
 
 final Map<Bloque, Tipo> tipoPorBloque;

 final Set<Posicion> posicionesIniciales;

  Tablero({required this.celdas, required this.bloquePorPosicion, 
  this.tipoPorBloque = const {}, this.posicionesIniciales = const {},
  })
      : assert(celdas.length == tamano,
            'El tablero debe tener $tamano filas'),
        assert(celdas.every((fila) => fila.length == tamano),
            'Cada fila del tablero debe tener $tamano columnas');
 
  factory Tablero.vacio(Map<Posicion, Bloque> bloquePorPosicion, {
    Map<Bloque, Tipo> tipoPorBloque = const {},  Set<Posicion> posicionesIniciales = const {},
  }) {
    return Tablero(
      celdas: List.generate(
        tamano,
        (_) => List.generate(tamano, (_) => const Celda.vacia()),
      ),
      bloquePorPosicion: bloquePorPosicion,
      tipoPorBloque: tipoPorBloque,
      posicionesIniciales: posicionesIniciales,
    );
  }

  Celda celdaEn(Posicion posicion) => celdas[posicion.y][posicion.x];

  bool get bloqueadoPorValoresIniciales => posicionesIniciales
      .any((posicion) => celdaEn(posicion).estaVacia);
    
  bool puedeColocarEn(Posicion posicion) {
    if (!bloqueadoPorValoresIniciales) return true;
    return posicionesIniciales.contains(posicion);
  }

  bool intentarColocarNumero(Posicion posicion, int valor) {
    if (!puedeColocarEn(posicion)) return false;
    colocarNumero(posicion, valor);
    return true;
  }
 
  void colocarNumero(Posicion posicion, int valor) {
    celdas[posicion.y][posicion.x] = Celda.ocupada(valor);
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

  Tipo? tipoDe(Bloque bloque) => tipoPorBloque[bloque];

  Color? colorDe(Bloque bloque) => tipoDe(bloque)?.color;

  List<Bloque> bloquesDeColor(Color color) => tipoPorBloque.entries
      .where((entry) => entry.value.color == color)
      .map((entry) => entry.key)
      .toList();
}