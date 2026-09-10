bool cumpleReglaMoradoMaximoDosDiferentes(
  List<int> numerosEnZona,
  int nuevoNumero,
) {
  if (numerosEnZona.contains(nuevoNumero)) return true;
  final valoresDistintos = numerosEnZona.toSet();
  return valoresDistintos.length < 2;
}