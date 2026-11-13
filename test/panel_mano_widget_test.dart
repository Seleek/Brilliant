import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/src/ui/panel_mano_widget.dart';

void main() {
  testWidgets(
      'oculta los números de la mano durante la partida y conserva '
      'los controles del turno', (tester) async {
    var colocarTocado = false;
    var pasarTocado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PanelMano(
            numerosEnMano: const [1, 2, 3, 4, 5, 6],
            mostrarNumeros: false,
            onColocarFicha: () => colocarTocado = true,
            onPasar: () => pasarTocado = true,
          ),
        ),
      ),
    );

    expect(find.byType(Card), findsNothing);
    expect(find.text('Tu mano'), findsNothing);
    for (var numero = 1; numero <= 6; numero++) {
      expect(find.text('$numero'), findsNothing);
    }

    await tester.tap(find.text('Colocar ficha'));
    await tester.tap(find.text('Pasar'));

    expect(colocarTocado, isTrue);
    expect(pasarTocado, isTrue);
  });
}
