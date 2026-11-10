import 'package:flutter/material.dart';

import '../celda.dart';
import '../tablero.dart';
import '../tipo.dart';

class Nivel {
  final int numero;

  final String nombre;

  final Map<Posicion, Tipo> tipoPorPosicion;

  final Set<Color> coloresUnificados;

  final Map<Color, int> divisionesPorColumna;

  final Map<Color, int> divisionesPorFila;

  final Set<Posicion> posicionesIniciales;

  Nivel({
    required this.numero,
    required this.tipoPorPosicion,
    required this.coloresUnificados,
    required this.divisionesPorColumna,
    required this.divisionesPorFila,
    required this.posicionesIniciales,
  }) : nombre = 'Nivel $numero';
}

List<Nivel> construirNiveles() => [
      _construirNivel(
        numero: 1,
        filas: _filasNivel1,
        estrellas: _estrellasNivel1,
        puntos: _puntosNivel1,
      ),
      _construirNivel(
        numero: 2,
        filas: _filasNivel2,
        estrellas: _estrellasNivel2,
        puntos: _puntosNivel2,
      ),
      _construirNivel(
        numero: 3,
        filas: _filasNivel3,
        estrellas: _estrellasNivel3,
        puntos: _puntosNivel3,
      ),
      _construirNivel(
        numero: 4,
        filas: _filasNivel4,
        estrellas: _estrellasNivel4,
        puntos: _puntosNivel4,
      ),
    ];

const List<String> _filasNivel1 = [
  'YVAMMMY',
  'VVAAMMV',
  'VRRAMVV',
  'VRMYVVV',
  'VRMMRRA',
  'RRMRRAA',
  'YMMRRAY',
];
const List<Posicion> _estrellasNivel1 = [
  Posicion(2, 0),
  Posicion(5, 1),
  Posicion(1, 3),
  Posicion(4, 3),
  Posicion(2, 5),
  Posicion(4, 6),
];
const Map<String, Map<int, int>> _puntosNivel1 = {
  'A': {1: 7, 2: 5, 3: 3},
  'V': {1: 4, 2: 3, 3: 2},
  'R': {1: 6, 2: 4, 3: 2},
  'M': {1: 6, 2: 4, 3: 2},
  'Y': {1: 8, 2: 6, 3: 4},
};

const List<String> _filasNivel2 = [
  'MMMGVVV',
  'MYAAAYV',
  'MRRAARV',
  'RRRYRRR',
  'VRAARRM',
  'VYAAAYM',
  'VVVGMMM',
];
const List<Posicion> _estrellasNivel2 = [
  Posicion(4, 0),
  Posicion(0, 2),
  Posicion(2, 3),
  Posicion(5, 4),
  Posicion(1, 5),
  Posicion(4, 6),
];
const Map<String, Map<int, int>> _puntosNivel2 = {
  'Y': {1: 6, 2: 4, 3: 2},
  'M': {1: 6, 2: 4, 3: 2},
  'R': {1: 6, 2: 4, 3: 2},
  'A': {1: 7, 2: 5, 3: 3},
  'V': {1: 4, 2: 3, 3: 2},
  'G': {1: 3, 2: 3, 3: 1},
};

const List<String> _filasNivel3 = [
  'YYMGMYY',
  'GYMMMYG',
  'RRRMRRR',
  'RRRGRRR',
  'VAAAAAV',
  'VVVVVVV',
  'MMMGMMM',
];
const List<Posicion> _estrellasNivel3 = [
  Posicion(2, 1),
  Posicion(5, 1),
  Posicion(3, 3),
  Posicion(1, 4),
  Posicion(6, 4),
  Posicion(2, 6),
];
const Map<String, Map<int, int>> _puntosNivel3 = {
  'M': {1: 7, 2: 5, 3: 3},
  'Y': {1: 7, 2: 5, 3: 3},
  'R': {1: 6, 2: 4, 3: 2},
  'A': {1: 7, 2: 5, 3: 3},
  'V': {1: 6, 2: 5, 3: 4},
  'G': {1: 8, 2: 6, 3: 4},
};

const List<String> _filasNivel4 = [
  'NNNNNNN',
  'YRAVARY',
  'RRMMMRR',
  'YVAMAVY',
  'RRMMMRR',
  'YRAVARY',
  'nnnnnnn',
];
const List<Posicion> _estrellasNivel4 = [
  Posicion(4, 0),
  Posicion(2, 2),
  Posicion(5, 2),
  Posicion(0, 3),
  Posicion(4, 5),
  Posicion(1, 6),
];
const Map<String, Map<int, int>> _puntosNivel4 = {
  'M': {1: 7, 2: 5, 3: 3},
  'A': {1: 8, 2: 6, 3: 4},
  'R': {1: 6, 2: 4, 3: 2},
  'Y': {1: 8, 2: 6, 3: 4},
  'V': {1: 3, 2: 2, 3: 1},
  // Las dos zonas naranjas (4-6 y 1-3) valen lo mismo.
  'N': {1: 6, 2: 4, 3: 3},
};

Nivel _construirNivel({
  required int numero,
  required List<String> filas,
  required List<Posicion> estrellas,
  required Map<String, Map<int, int>> puntos,
}) {
  assert(filas.length == Tablero.tamano, 'Nivel $numero: faltan filas');
  assert(
    filas.every((fila) => fila.length == Tablero.tamano),
    'Nivel $numero: alguna fila no tiene ${Tablero.tamano} letras',
  );
  assert(estrellas.length == 6, 'Nivel $numero: deben ser 6 estrellas');

  final tipoPorPosicion = <Posicion, Tipo>{};
  for (var y = 0; y < filas.length; y++) {
    final fila = filas[y];
    for (var x = 0; x < fila.length; x++) {
      tipoPorPosicion[Posicion(x, y)] = _crearTipo(fila[x], puntos);
    }
  }

  final coloresUnificados = <Color>{};
  coloresUnificados.add(TipoAmarillo().color);
  if (tipoPorPosicion.values.any((tipo) => tipo is TipoGris)) {
    coloresUnificados.add(TipoGris().color);
  }
  if (numero == 3 || numero == 4) {
    coloresUnificados.add(TipoAzul().color);
  }
  final divisionesPorColumna = {TipoRojo().color: 3};
  final divisionesPorFila = numero == 4
      ? {TipoNaranja(minimo: 4, maximo: 6).color: 3}
      : <Color, int>{};
  return Nivel(
    numero: numero,
    tipoPorPosicion: tipoPorPosicion,
    coloresUnificados: coloresUnificados,
    divisionesPorColumna: divisionesPorColumna,
    divisionesPorFila: divisionesPorFila,
    posicionesIniciales: estrellas.toSet(),
  );
}

Tipo _crearTipo(String letra, Map<String, Map<int, int>> puntos) {
  switch (letra) {
    case 'R':
      return TipoRojo(puntuaciones: puntos['R']);
    case 'Y':
      return TipoAmarillo(puntuaciones: puntos['Y']);
    case 'A':
      return TipoAzul(puntuaciones: puntos['A']);
    case 'G':
      return TipoGris(puntuaciones: puntos['G']);
    case 'V':
      return TipoVerde(puntuaciones: puntos['V']);
    case 'M':
      return TipoMorado(puntuaciones: puntos['M']);
    case 'N':
      return TipoNaranja(minimo: 4, maximo: 6, puntuaciones: puntos['N']);
    case 'n':
      return TipoNaranja(minimo: 1, maximo: 3, puntuaciones: puntos['N']);
    default:
      throw ArgumentError('Letra de color de tablero desconocida: $letra');
  }
}
