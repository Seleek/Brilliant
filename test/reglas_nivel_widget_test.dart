import 'package:brilliant/src/datos/niveles.dart';
import 'package:brilliant/src/ui/reglas_nivel_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la regla de cada zona con su color', (tester) async {
    final nivel = construirNiveles()[3];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReglasNivelWidget(nivel: nivel)),
      ),
    );

    expect(find.text('Reglas de las zonas'), findsOneWidget);
    expect(find.textContaining('Solo números del 4 al 6'), findsWidgets);
    expect(find.textContaining('Solo números del 1 al 3'), findsWidgets);

    final coloresNaranjas = tester
        .widgetList<Icon>(find.byIcon(Icons.circle))
        .where((icon) => icon.color == const Color(0xFFFF9800));
    expect(coloresNaranjas, hasLength(1));
    expect(
      find.text('Solo números del 4 al 6; Solo números del 1 al 3'),
      findsOneWidget,
    );

    final colores = tester
        .widgetList<Icon>(find.byIcon(Icons.circle))
        .map((icon) => icon.color)
        .toList();
    expect(colores.toSet(), hasLength(colores.length));
  });

  testWidgets('permite expandir las reglas en pantallas compactas',
      (tester) async {
    final nivel = construirNiveles().first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReglasNivelWidget(nivel: nivel, expandible: true),
        ),
      ),
    );

    expect(find.text('Todos los números deben ser diferentes'), findsNothing);
    await tester.tap(find.text('Reglas de las zonas'));
    await tester.pumpAndSettle();
    expect(
      find.text('Todos los números deben ser diferentes'),
      findsNWidgets(2),
    );
  });
}
