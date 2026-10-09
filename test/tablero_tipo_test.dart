import 'package:test/test.dart';
import 'package:brilliant/brilliant.dart';

Map<Bloque, Tipo> _tiposDePrueba() => {
      Bloque.bloque1: TipoVerde(),
      Bloque.bloque2: TipoAzul(),
      Bloque.bloque3: TipoVerde(),
    };

void main() {
  group('Tablero.tipoDe', () {
    test('retorna el tipo asignado a un bloque', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.tipoDe(Bloque.bloque2), isA<TipoAzul>());
    });

    test('retorna null si el bloque no tiene tipo asignado', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.tipoDe(Bloque.bloque4), isNull);
    });
  });

  group('Tablero.colorDe', () {
    test('retorna el color del tipo asignado al bloque', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.colorDe(Bloque.bloque1), TipoVerde().color);
    });

    test('retorna null si el bloque no tiene tipo asignado', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.colorDe(Bloque.bloque4), isNull);
    });
  });

  group('Tablero.bloquesDeColor', () {
    test('identifica varios bloques que comparten el mismo color', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(
        tablero.bloquesDeColor(TipoVerde().color),
        unorderedEquals([Bloque.bloque1, Bloque.bloque3]),
      );
    });

    test('un color con un solo bloque retorna solo ese bloque', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.bloquesDeColor(TipoAzul().color), [Bloque.bloque2]);
    });

    test('un color que ningún bloque tiene retorna lista vacía', () {
      final tablero = Tablero.vacio({}, tipoPorBloque: _tiposDePrueba());
      expect(tablero.bloquesDeColor(TipoMorado().color), isEmpty);
    });
  });

  test('un tablero construido antes de tener tipos sigue funcionando '
      '(tipoPorBloque es opcional)', () {
    final tablero = Tablero.vacio({const Posicion(0, 0): Bloque.bloque1});
    expect(tablero.tipoDe(Bloque.bloque1), isNull);
    expect(tablero.colorDe(Bloque.bloque1), isNull);
  });
}
