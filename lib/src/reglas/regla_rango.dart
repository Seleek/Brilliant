bool cumpleReglaRango(
  List<int> numerosEnZona,
  int nuevoNumero, {
  required int minimo,
  required int maximo,
}) {
  return nuevoNumero >= minimo && nuevoNumero <= maximo;
}
