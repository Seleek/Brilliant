bool cumpleReglaTodosIguales(List<int> numerosEnZona, int nuevoNumero) {
  if (numerosEnZona.isEmpty) return true;
  return numerosEnZona.first == nuevoNumero;
}