import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/main.dart' show PantallaTablero;
import 'package:brilliant/src/datos/niveles.dart';

void main() {
  testWidgets('confirma antes de salir de una partida activa', (tester) async {
    final nivelSinPreparacion = Nivel(
      numero: 1,
      tipoPorPosicion: const {},
      coloresUnificados: const {},
      divisionesPorColumna: const {},
      divisionesPorFila: const {},
      posicionesIniciales: const {},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaTablero(
                    nivel: nivelSinPreparacion,
                  ),
                ),
              ),
              child: const Text('Abrir nivel'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir nivel'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Iniciar partida'));
    await tester.tap(find.text('Iniciar partida'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('¿Salir de la partida?'), findsOneWidget);
    expect(
      find.text('Si sales ahora, perderás el progreso de esta partida.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Seguir jugando'));
    await tester.pumpAndSettle();
    expect(find.text('¿Salir de la partida?'), findsNothing);
    expect(find.text('Brilliant — Nivel 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir'));
    await tester.pumpAndSettle();

    expect(find.text('Abrir nivel'), findsOneWidget);
  });
}
