import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/src/ui/panel_mano_widget.dart';

Widget _envolver(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('muestra un botón por cada número de la mano, en orden',
      (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelMano(numerosEnMano: [1, 2, 2, 3, 4, 6])),
    );

    expect(find.byType(BotonNumeroMano), findsNWidgets(6));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('sin selección, ningún botón se ve resaltado', (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelMano(numerosEnMano: [1, 2, 3])),
    );

    for (var i = 0; i < 3; i++) {
      final boton = tester.widget<BotonNumeroMano>(
        find.byKey(ValueKey('boton_mano_$i')),
      );
      expect(boton.seleccionado, isFalse);
    }
  });

  testWidgets('marca como seleccionado solo el índice indicado, no el '
      'valor', (tester) async {
    await tester.pumpWidget(
      _envolver(
        const PanelMano(
          numerosEnMano: [1, 2, 2, 3],
          indiceSeleccionado: 2,
        ),
      ),
    );

    final segundoDos =
        tester.widget<BotonNumeroMano>(find.byKey(const ValueKey('boton_mano_2')));
    final primerDos =
        tester.widget<BotonNumeroMano>(find.byKey(const ValueKey('boton_mano_1')));

    expect(segundoDos.seleccionado, isTrue);
    expect(primerDos.seleccionado, isFalse);
  });

  testWidgets('tocar un número llama a onNumeroTocado con su índice',
      (tester) async {
    int? indiceTocado;
    await tester.pumpWidget(
      _envolver(
        PanelMano(
          numerosEnMano: const [1, 2, 3],
          onNumeroTocado: (indice) => indiceTocado = indice,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('boton_mano_1')));
    await tester.pump();

    expect(indiceTocado, 1);
  });

  testWidgets('sin onNumeroTocado, tocar un número no falla (no hace '
      'nada)', (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelMano(numerosEnMano: [1, 2, 3])),
    );

    await tester.tap(find.byKey(const ValueKey('boton_mano_0')));
    await tester.pump();
  });

  testWidgets('"Colocar ficha" está deshabilitado sin onColocarFicha',
      (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelMano(numerosEnMano: [1, 2, 3])),
    );

    final boton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Colocar ficha'),
    );
    expect(boton.onPressed, isNull);
  });

  testWidgets('"Colocar ficha" llama a onColocarFicha al tocarlo',
      (tester) async {
    var tocado = false;
    await tester.pumpWidget(
      _envolver(
        PanelMano(
          numerosEnMano: const [1, 2, 3],
          onColocarFicha: () => tocado = true,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Colocar ficha'));
    await tester.pump();

    expect(tocado, isTrue);
  });

  testWidgets('"Pasar" llama a onPasar al tocarlo', (tester) async {
    var tocado = false;
    await tester.pumpWidget(
      _envolver(
        PanelMano(
          numerosEnMano: const [1, 2, 3],
          onPasar: () => tocado = true,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Pasar'));
    await tester.pump();

    expect(tocado, isTrue);
  });

  group('números de la mano deshabilitados', () {
    testWidgets('con numerosHabilitados en false, tocar un número no '
        'llama al callback', (tester) async {
      int? tocado;
      await tester.pumpWidget(
        _envolver(
          PanelMano(
            numerosEnMano: const [1, 2, 3],
            numerosHabilitados: false,
            onNumeroTocado: (i) => tocado = i,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('boton_mano_1')));
      await tester.pump();

      expect(tocado, isNull);
    });

    testWidgets('todos los botones de número quedan marcados como '
        'deshabilitados', (tester) async {
      await tester.pumpWidget(
        _envolver(
          const PanelMano(
            numerosEnMano: [1, 2, 3],
            numerosHabilitados: false,
          ),
        ),
      );

      for (var i = 0; i < 3; i++) {
        final boton = tester.widget<BotonNumeroMano>(
          find.byKey(ValueKey('boton_mano_$i')),
        );
        expect(boton.habilitado, isFalse);
      }
    });

    testWidgets('un botón deshabilitado se ve gris, y no resaltado '
        'aunque sea el seleccionado', (tester) async {
      await tester.pumpWidget(
        _envolver(
          const PanelMano(
            numerosEnMano: [1, 2, 3],
            indiceSeleccionado: 0,
            numerosHabilitados: false,
          ),
        ),
      );

      final contenedor = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(const ValueKey('boton_mano_0')),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoracion = contenedor.decoration as BoxDecoration;
      expect(decoracion.color, Colors.grey.shade200);
      expect((decoracion.border as Border).top.color, isNot(Colors.blue));
    });

    testWidgets('por defecto los números siguen habilitados',
        (tester) async {
      int? tocado;
      await tester.pumpWidget(
        _envolver(
          PanelMano(
            numerosEnMano: const [1, 2, 3],
            onNumeroTocado: (i) => tocado = i,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('boton_mano_2')));
      await tester.pump();

      expect(tocado, 2);
    });
  });
}