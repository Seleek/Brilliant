
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
  final int x; 
  final int y; 

  const Posicion(this.x, this.y);

  bool esAdyacenteA(Posicion otra) =>
      (x - otra.x).abs() + (y - otra.y).abs() == 1;

  @override
  bool operator ==(Object other) =>
      other is Posicion && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '(x: $x,y:  $y)';
}
