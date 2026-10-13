import 'dart:math';
import 'celda.dart';
import 'tablero.dart';
import 'tipo.dart';
import 'datos/regiones.dart';

const int _maximoIntentos = 100;

Set<Posicion> generarPosicionesInicialesAleatorias({
  required int semilla, 
  required Map<Posicion, Tipo> tipoPorPosicion,
  }){
    const cantidad = 6;
  final random = Random(semilla);

  final regiones = agruparEnRegiones(tipoPorPosicion);
  if (regiones.length < cantidad) {
    throw StateError(
      'Se necesitan al menos $cantidad zonas para sortear las casillas '
      'iniciales, pero el tablero solo tiene ${regiones.length}.',
    );
  }

  final regionesPorColor = <Object, List<Set<Posicion>>>{};
  for (final region in regiones) {
    final color = tipoPorPosicion[region.first]!.color;
    regionesPorColor.putIfAbsent(color, () => []).add(region);
  }

  for (var intento = 0; intento < _maximoIntentos; intento++) {
    final zonas = _elegirZonas(regiones, regionesPorColor, cantidad, random);

        final candidatas = [
      for (final zona in zonas) zona.toList()..shuffle(random),
    ];

    final casillas = _elegirCasillasSinAdyacentes(candidatas, 0, const []);
    if (casillas != null) return casillas.toSet();
  }

  throw StateError(
    'No se pudieron elegir $cantidad casillas iniciales en zonas '
    'distintas y sin que se toquen entre sí.',
  );
}

List<Set<Posicion>> _elegirZonas(
  List<Set<Posicion>> regiones,
  Map<Object, List<Set<Posicion>>> regionesPorColor,
  int cantidad,
  Random random,
) {
  final elegidas = <Set<Posicion>>[];

  final colores = regionesPorColor.keys.toList()..shuffle(random);
  for (final color in colores) {
    if (elegidas.length == cantidad) break;
    final candidatas = regionesPorColor[color]!;
    elegidas.add(candidatas[random.nextInt(candidatas.length)]);
  }

  if (elegidas.length < cantidad) {
    final restantes = regiones.where((r) => !elegidas.contains(r)).toList()
      ..shuffle(random);
    elegidas.addAll(restantes.take(cantidad - elegidas.length));
  }

  return elegidas;
}

List<Posicion>? _elegirCasillasSinAdyacentes(
  List<List<Posicion>> candidatas,
  int indiceZona,
  List<Posicion> elegidas,
) {
  if (indiceZona == candidatas.length) return elegidas;

  for (final casilla in candidatas[indiceZona]) {
    if (elegidas.any((elegida) => elegida.esAdyacenteA(casilla))) continue;

    final resultado = _elegirCasillasSinAdyacentes(
      candidatas,
      indiceZona + 1,
      [...elegidas, casilla],
    );
    if (resultado != null) return resultado;
  }

  return null;
}
