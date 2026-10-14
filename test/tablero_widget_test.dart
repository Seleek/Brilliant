import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';
import 'package:brilliant/src/ui/tablero_widget.dart';

Widget _envolver(TableroBloc bloc) =>
    MaterialApp(home: Scaffold(body: TableroWidget(bloc: bloc)));

void main() {
  late TableroBloc bloc;

  setUp(() {
    bloc = TableroBloc(
      Tablero.vacio(const {}),
      numerosEnMano: const [1, 2, 2, 3, 4, 6],
    );
  });

  tearDown(() {
    bloc.dispose();
  });

  testWidgets('muestra 49 casillas (7x7)', (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    expect(find.byType(CasillaTablero), findsNWidgets(49));
  });

  testWidgets('cada casilla tiene un borde negro', (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    final contenedor = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(CasillaTablero),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoracion = contenedor.decoration as BoxDecoration;
    final borde = decoracion.border as Border;

    expect(borde.top.color, Colors.black);
    expect(borde.top.width, 1);
  });

  testWidgets('el tablero mantiene proporción cuadrada (1:1)',
      (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(aspectRatio.aspectRatio, 1);
  });

  testWidgets('tocar una casilla la marca como seleccionada (cambia de '
      'color)', (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    await tester.tap(find.byKey(const ValueKey('celda_3_2')));
    await tester.pump();

    final casillaTocada = tester.widget<CasillaTablero>(
      find.byKey(const ValueKey('celda_3_2')),
    );
    expect(casillaTocada.seleccionada, isTrue);
  });

  testWidgets('al seleccionarse, el borde cambia de negro a un color '
      'que resalta (el fondo ya lo ocupa el color de la zona)',
      (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    await tester.tap(find.byKey(const ValueKey('celda_3_2')));
    await tester.pump();

    final contenedor = tester.widget<Container>(
      find
          .descendant(
            of: find.byKey(const ValueKey('celda_3_2')),
            matching: find.byType(Container),
          )
          .first,
    );
    final borde = (contenedor.decoration as BoxDecoration).border as Border;

    expect(borde.top.color, isNot(Colors.black));
    expect(borde.top.width, greaterThan(1));
  });

  group('coloreado por zona (tipoPorPosicion)', () {
    Widget envolverConColor(TableroBloc bloc, Map<Posicion, Tipo> tipos) =>
        MaterialApp(
          home: Scaffold(
            body: TableroWidget(bloc: bloc, tipoPorPosicion: tipos),
          ),
        );

    testWidgets('una celda con tipo asignado se pinta de su color',
        (tester) async {
      final tipos = {const Posicion(0, 0): TipoAzul()};
      await tester.pumpWidget(envolverConColor(bloc, tipos));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_0_0')),
      );
      expect(casilla.colorZona, TipoAzul().color);
    });

    testWidgets('una celda sin tipo asignado se pinta blanca', (tester) async {
      await tester.pumpWidget(envolverConColor(bloc, const {}));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_0_0')),
      );
      expect(casilla.colorZona, isNull);
    });

    testWidgets('el layout oficial pinta la esquina (0, 0) de amarillo '
        '(primera letra de la primera fila)', (tester) async {
      final tipos = construirTipoPorPosicionOficial();
      await tester.pumpWidget(envolverConColor(bloc, tipos));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_0_0')),
      );
      expect(casilla.colorZona, TipoAmarillo().color);
    });

    testWidgets('el layout oficial pinta la esquina (6, 6) de azul '
        '(última letra de la última fila)', (tester) async {
      final tipos = construirTipoPorPosicionOficial();
      await tester.pumpWidget(envolverConColor(bloc, tipos));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_6_6')),
      );
      expect(casilla.colorZona, TipoAzul().color);
    });
  });

  testWidgets('al seleccionar una casilla vacía, muestra el "1" en '
      'tono translúcido', (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    await tester.tap(find.byKey(const ValueKey('celda_3_2')));
    await tester.pump();

    final casilla = tester.widget<CasillaTablero>(
      find.byKey(const ValueKey('celda_3_2')),
    );
    expect(casilla.valor, isNull);
    expect(casilla.numeroPreview, 1);

    final opacidad = tester.widget<Opacity>(
      find.descendant(
        of: find.byKey(const ValueKey('celda_3_2')),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacidad.opacity, lessThan(1));
  });

  testWidgets('tras colocar la ficha, el número se muestra sólido, no '
      'translúcido', (tester) async {
    await tester.pumpWidget(_envolver(bloc));

    await tester.tap(find.byKey(const ValueKey('celda_2_2')));
    await tester.pump();
    bloc.agregar(ColocarFicha());
    await tester.pump();

    final casilla = tester.widget<CasillaTablero>(
      find.byKey(const ValueKey('celda_2_2')),
    );
    expect(casilla.valor, 1);

    // Ya no hay ningún Opacity dentro de esa celda.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('celda_2_2')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  group('casillas iniciales (estrellitas)', () {
    testWidgets('las casillas que son posicionesIniciales muestran la '
        'estrella', (tester) async {
      final blocConEstrellitas = TableroBloc(
        Tablero.vacio(
          const {},
          posicionesIniciales: {const Posicion(2, 4)},
        ),
      );
      addTearDown(blocConEstrellitas.dispose);

      await tester.pumpWidget(_envolver(blocConEstrellitas));

      final casillaEstrella = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_2_4')),
      );
      expect(casillaEstrella.esInicial, isTrue);

      final casillaNormal = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_0_0')),
      );
      expect(casillaNormal.esInicial, isFalse);

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('celda_2_4')),
          matching: find.byIcon(Icons.star),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('celda_0_0')),
          matching: find.byIcon(Icons.star),
        ),
        findsNothing,
      );
    });
  });

  group('iluminación de las casillas iniciales', () {
    BoxDecoration decoracionDe(WidgetTester tester, String clave) {
      final contenedor = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(ValueKey(clave)),
              matching: find.byType(Container),
            )
            .first,
      );
      return contenedor.decoration as BoxDecoration;
    }

    testWidgets('al inicio, la casilla inicial está iluminada: resplandor '
        'y borde dorado, no solo la estrella', (tester) async {
      final b = TableroBloc(
        Tablero.vacio(const {}, posicionesIniciales: {const Posicion(2, 4)}),
      );
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_2_4')),
      );
      expect(casilla.iluminada, isTrue);

      final deco = decoracionDe(tester, 'celda_2_4');
      expect(deco.boxShadow, isNotEmpty); // resplandor
      expect((deco.border as Border).top.color, Colors.amber); 
      expect((deco.border as Border).top.width, greaterThan(1));
    });

    testWidgets('una casilla normal no se ilumina', (tester) async {
      final b = TableroBloc(
        Tablero.vacio(const {}, posicionesIniciales: {const Posicion(2, 4)}),
      );
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_0_0')),
      );
      expect(casilla.iluminada, isFalse);
      expect(decoracionDe(tester, 'celda_0_0').boxShadow, isNull);
    });

    testWidgets('la casilla inicial sigue iluminada después de escribir '
        'su número (antes de iniciar)', (tester) async {
      final b = TableroBloc(
        Tablero.vacio(const {}, posicionesIniciales: {const Posicion(2, 4)}),
      );
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(ColocarNumero(const Posicion(2, 4), 3));
      await tester.pump();

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_2_4')),
      );
      expect(casilla.valor, 3);
      expect(casilla.iluminada, isTrue);
    });

    testWidgets('al iniciar la partida, el brillo se apaga', (tester) async {
      final b = TableroBloc(
        Tablero.vacio(const {}, posicionesIniciales: {const Posicion(2, 4)}),
      );
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(ColocarNumero(const Posicion(2, 4), 3));
      b.agregar(IniciarPartida());
      await tester.pump();

      final casilla = tester.widget<CasillaTablero>(
        find.byKey(const ValueKey('celda_2_4')),
      );
      expect(casilla.iluminada, isFalse);
      expect(decoracionDe(tester, 'celda_2_4').boxShadow, isNull);
    });
  });

  group('turno: casillas propuestas para el dado elegido', () {
    TableroBloc crearBlocEnTurno() {
      final tablero = Tablero.vacio(
        const {},
        posicionesIniciales: {const Posicion(0, 0), const Posicion(1, 0)},
      );
      tablero.colocarNumero(const Posicion(0, 0), 3);
      tablero.colocarNumero(const Posicion(1, 0), 5);
      final b = TableroBloc(
        tablero,
        numerosEnMano: const [1, 2, 3, 4, 5, 6],
      );
      b.agregar(IniciarPartida());
      return b;
    }

    CasillaTablero casilla(WidgetTester tester, String clave) =>
        tester.widget<CasillaTablero>(find.byKey(ValueKey(clave)));

    double opacidadDeNumero(WidgetTester tester, String clave) =>
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byKey(ValueKey(clave)),
                matching: find.byType(Opacity),
              ),
            )
            .opacity;

    testWidgets('al comenzar el turno no hay casillas propuestas ni '
        'números', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      for (final clave in ['celda_2_0', 'celda_0_1', 'celda_1_1']) {
        expect(casilla(tester, clave).propuesta, isFalse);
        expect(casilla(tester, clave).numeroPreview, isNull);
      }
    });

    testWidgets('al elegir un dado, el número aparece en las casillas '
        'propuestas y solo en ellas', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      await tester.pump();
      final numero = b.estadoActual.dados[0];

      for (final clave in ['celda_2_0', 'celda_0_1', 'celda_1_1']) {
        expect(casilla(tester, clave).propuesta, isTrue, reason: clave);
        expect(casilla(tester, clave).numeroPreview, numero, reason: clave);
      }
      expect(casilla(tester, 'celda_5_5').propuesta, isFalse);
      expect(casilla(tester, 'celda_5_5').numeroPreview, isNull);
      expect(casilla(tester, 'celda_0_0').propuesta, isFalse);
    });

    testWidgets('el número propuesto se ve translúcido', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      await tester.pump();

      expect(opacidadDeNumero(tester, 'celda_2_0'), lessThan(0.6));
    });

    testWidgets('elegir el otro dado muestra el número del otro dado',
        (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      await tester.pump();
      b.agregar(SeleccionarDado(1));
      await tester.pump();

      expect(
        casilla(tester, 'celda_2_0').numeroPreview,
        b.estadoActual.dados[1],
      );
    });

    testWidgets('tocar una casilla propuesta la selecciona y se ilumina '
        'más que las demás propuestas', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('celda_2_0')));
      await tester.pump();

      expect(casilla(tester, 'celda_2_0').seleccionada, isTrue);
      expect(casilla(tester, 'celda_0_1').seleccionada, isFalse);

      expect(
        opacidadDeNumero(tester, 'celda_2_0'),
        greaterThan(opacidadDeNumero(tester, 'celda_0_1')),
      );
    });

    testWidgets('tocar una casilla que no está propuesta no la '
        'selecciona', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('celda_5_5')));
      await tester.pump();

      expect(casilla(tester, 'celda_5_5').seleccionada, isFalse);
    });

    testWidgets('tras colocar la ficha, el número queda sólido en su '
        'casilla y desaparecen las propuestas', (tester) async {
      final b = crearBlocEnTurno();
      addTearDown(b.dispose);
      await tester.pumpWidget(_envolver(b));

      b.agregar(SeleccionarDado(0));
      final numero = b.estadoActual.dados[0];
      b.agregar(SeleccionarCelda(const Posicion(2, 0)));
      b.agregar(ColocarFicha());
      await tester.pump();

      expect(casilla(tester, 'celda_2_0').valor, numero);
      expect(casilla(tester, 'celda_0_1').propuesta, isFalse);
      expect(casilla(tester, 'celda_0_1').numeroPreview, isNull);
    });
  });
}