import 'dart:math';

class RandomFalso implements Random {
  RandomFalso(this._valores);

  final List<int> _valores;
  var _indice = 0;

  @override
  int nextInt(int max) => _valores[_indice++ % _valores.length];

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}
