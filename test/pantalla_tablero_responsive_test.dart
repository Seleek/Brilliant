import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:brilliant/main.dart' show PantallaTablero;
import 'package:brilliant/src/datos/niveles.dart';
import 'package:brilliant/src/servicios/auth_service.dart';
import 'package:brilliant/src/ui/pantalla_seleccion_nivel.dart';

void main() {
  testWidgets('adapta el tablero al ancho de un teléfono', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: PantallaTablero(nivel: construirNiveles().first)),
    );

    final tablero = tester.widget<SizedBox>(
      find.byKey(const ValueKey('tablero-responsive')),
    );
    expect(tablero.width, lessThanOrEqualTo(328));
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduce el tablero para aprovechar la pantalla en horizontal',
      (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: PantallaTablero(nivel: construirNiveles().first)),
    );

    final tablero = tester.widget<SizedBox>(
      find.byKey(const ValueKey('tablero-responsive')),
    );
    expect(tablero.width, lessThan(420));
    expect(tablero.width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra la selección de nivel sin desbordarse en un teléfono',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaSeleccionNivel(
          authService: AuthService(),
          onNivelElegido: (_) {},
          onLogout: () {},
          onMultijugador: () {},
        ),
      ),
    );

    expect(find.text('Selecciona un Nivel'), findsOneWidget);
    expect(find.text('Nivel 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
