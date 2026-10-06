import '../celda.dart';
import '../tipo.dart';

const List<String> _filasColorTableroOficial = [
  'YVAMMMY', // y = 0
  'VVAAMMV', // y = 1
  'VRRAMVV', // y = 2
  'VRMYVVV', // y = 3
  'VRMMRRA', // y = 4
  'RRMRRAA', // y = 5
  'YMMRRYA', // y = 6
];

Tipo _tipoDeLetra(String letra) {
  switch (letra) {
    case 'R':
      return TipoRojo();
    case 'Y':
      return TipoAmarillo();
    case 'A':
      return TipoAzul();
    case 'V':
      return TipoVerde();
    case 'M':
      return TipoMorado();
    default:
      throw ArgumentError('Letra de color de tablero desconocida: $letra');
  }
}

Map<Posicion, Tipo> construirTipoPorPosicionOficial() {
  final mapa = <Posicion, Tipo>{};
  for (var y = 0; y < _filasColorTableroOficial.length; y++) {
    final fila = _filasColorTableroOficial[y];
    for (var x = 0; x < fila.length; x++) {
      mapa[Posicion(x, y)] = _tipoDeLetra(fila[x]);
    }
  }
  return mapa;
}
 