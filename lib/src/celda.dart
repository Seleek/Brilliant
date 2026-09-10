
class Celda {

  final int? valor;

  const Celda.vacia() : valor = null;

  const Celda.ocupada(int this.valor) : assert(valor >= 1 && valor <= 6);

  bool get estaVacia => valor == null;

  bool get estaOcupada => valor != null;

  @override
  bool operator ==(Object other) => other is Celda && other.valor == valor;

  @override
  int get hashCode => valor.hashCode;

  @override
  String toString() => estaVacia ? 'Celda(vacía)' : 'Celda($valor)';
}


class Posicion {
  final int fila; // 0..6
  final int columna; // 0..6

  const Posicion(this.fila, this.columna);

  @override
  bool operator ==(Object other) =>
      other is Posicion && other.fila == fila && other.columna == columna;

  @override
  int get hashCode => Object.hash(fila, columna);

  @override
  String toString() => '($fila, $columna)';
}
