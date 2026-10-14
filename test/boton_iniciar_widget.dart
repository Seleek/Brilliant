import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';

Widget _envolver(TableroBloc bloc) =>
    MaterialApp(home: Scaffold(body: BotonIniciar(bloc: bloc)));

TableroBloc _crearBlocConEstrellitas() => TableroBloc(
      Tablero.vacio(
        const {},
        posicionesIniciales: {
          const Posicion(0, 0),
          const Posicion(1, 0),
        },
      ),
      numerosEnMano: const [1, 2, 3, 4, 5, 6],
    );

void main() {
  testWidgets('está deshabilitado mientras las estrellitas no estén '
      'completas', (tester) async {
    final bloc = _crearBlocConEstrellitas();
    addTearDown(bloc.dispose);

    await tester.pumpWidget(_envolver(bloc));

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(boton.onPressed, isNull);
  });

  testWidgets('se habilita cuando las estrellitas ya están completas '
      'sin repetir', (tester) async {
    final bloc = _crearBlocConEstrellitas();
    addTearDown(bloc.dispose);

    bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
    bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));

    await tester.pumpWidget(_envolver(bloc));
    await tester.pump();

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(boton.onPressed, isNotNull);
  });

  testWidgets('tocarlo manda IniciarPartida y luego muestra "Partida '
      'iniciada" en vez del botón', (tester) async {
    final bloc = _crearBlocConEstrellitas();
    addTearDown(bloc.dispose);

    bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
    bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));

    await tester.pumpWidget(_envolver(bloc));
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
    await tester.pump();

    expect(bloc.estadoActual.partidaIniciada, isTrue);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text('Partida iniciada'), findsOneWidget);
  });

  testWidgets('con las dos casillas llenas pero repetidas, el botón '
      'sigue deshabilitado', (tester) async {
    // Se llenan directo en el Tablero para simular números repetidos
    // que llegan sin pasar por la validación del bloc.
    final tablero = Tablero.vacio(
      const {},
      posicionesIniciales: {const Posicion(0, 0), const Posicion(1, 0)},
    );
    tablero.colocarNumero(const Posicion(0, 0), 4);
    tablero.colocarNumero(const Posicion(1, 0), 4);
    final bloc = TableroBloc(tablero);
    addTearDown(bloc.dispose);

    await tester.pumpWidget(_envolver(bloc));

    final boton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(boton.onPressed, isNull);
  });

  testWidgets('mientras está deshabilitado, explica qué falta', (tester) async {
    final bloc = _crearBlocConEstrellitas();
    addTearDown(bloc.dispose);

    await tester.pumpWidget(_envolver(bloc));

    expect(find.textContaining('números diferentes'), findsOneWidget);
  });

  testWidgets('cuando ya se puede iniciar, el mensaje de ayuda '
      'desaparece', (tester) async {
    final bloc = _crearBlocConEstrellitas();
    addTearDown(bloc.dispose);

    bloc.agregar(ColocarNumero(const Posicion(0, 0), 1));
    bloc.agregar(ColocarNumero(const Posicion(1, 0), 2));

    await tester.pumpWidget(_envolver(bloc));
    await tester.pump();

    expect(find.textContaining('números diferentes'), findsNothing);
  });
}
