import '../celda.dart';
import '../tipo.dart';
import 'niveles.dart';

Map<Posicion, Tipo> construirTipoPorPosicionOficial() =>
    construirNiveles().first.tipoPorPosicion;
