import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';

Widget _envolver(Widget child) => MaterialApp(home: Scaffold(body: child));

String _textoDelDado(WidgetTester tester, int indice) {
  final texto = tester.widget<Text>(
    find.descendant(
      of: find.byKey(ValueKey('dado_$indice')),
      matching: find.byType(Text),
    ),
  );
  return texto.data!;
}

void main() {
  testWidgets('muestra dos casillas de dado', (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [3, 6])));

    expect(find.byType(CasillaDado), findsNWidgets(2));
  });

  testWidgets('cada casilla muestra el valor de su dado', (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [3, 6])));

    expect(_textoDelDado(tester, 0), '3');
    expect(_textoDelDado(tester, 1), '6');
  });

  testWidgets('dos dados iguales se muestran los dos', (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [4, 4])));

    expect(_textoDelDado(tester, 0), '4');
    expect(_textoDelDado(tester, 1), '4');
  });

  testWidgets('sin tirada, muestra dos casillas vacías y la nota',
      (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [])));

    expect(find.byType(CasillaDado), findsNWidgets(2));
    expect(_textoDelDado(tester, 0), '–');
    expect(_textoDelDado(tester, 1), '–');
    expect(find.textContaining('se tiran al iniciar'), findsOneWidget);
  });

  testWidgets('con tirada, la nota de "se tiran al iniciar" no aparece',
      (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [1, 2])));

    expect(find.textContaining('se tiran al iniciar'), findsNothing);
  });

  testWidgets('muestra el número de turno cuando es mayor que 0',
      (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelDados(dados: [1, 2], turno: 3)),
    );

    expect(find.text('Turno 3'), findsOneWidget);
  });

  testWidgets('no muestra "Turno" antes de empezar (turno 0)',
      (tester) async {
    await tester.pumpWidget(_envolver(const PanelDados(dados: [])));

    expect(find.textContaining('Turno'), findsNothing);
  });

  testWidgets('se actualiza cuando llegan dados nuevos', (tester) async {
    await tester.pumpWidget(
      _envolver(const PanelDados(dados: [1, 2], turno: 1)),
    );
    await tester.pumpWidget(
      _envolver(const PanelDados(dados: [5, 6], turno: 2)),
    );

    expect(_textoDelDado(tester, 0), '5');
    expect(_textoDelDado(tester, 1), '6');
    expect(find.text('Turno 2'), findsOneWidget);
  });

  group('elegir un dado', () {
    CasillaDado dado(WidgetTester tester, int i) =>
        tester.widget<CasillaDado>(find.byKey(ValueKey('dado_$i')));

    testWidgets('resalta solo el dado elegido', (tester) async {
      await tester.pumpWidget(
        _envolver(const PanelDados(dados: [3, 6], indiceSeleccionado: 1)),
      );

      expect(dado(tester, 0).seleccionado, isFalse);
      expect(dado(tester, 1).seleccionado, isTrue);
    });

    testWidgets('con dos dados iguales, solo se resalta el del índice '
        'elegido', (tester) async {
      await tester.pumpWidget(
        _envolver(const PanelDados(dados: [4, 4], indiceSeleccionado: 0)),
      );

      expect(dado(tester, 0).seleccionado, isTrue);
      expect(dado(tester, 1).seleccionado, isFalse);
    });

    testWidgets('tocar un dado llama a onDadoTocado con su índice',
        (tester) async {
      int? tocado;
      await tester.pumpWidget(
        _envolver(
          PanelDados(dados: const [3, 6], onDadoTocado: (i) => tocado = i),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('dado_1')));
      await tester.pump();

      expect(tocado, 1);
    });

    testWidgets('sin onDadoTocado, tocar un dado no hace nada ni falla',
        (tester) async {
      await tester.pumpWidget(_envolver(const PanelDados(dados: [3, 6])));

      await tester.tap(find.byKey(const ValueKey('dado_0')));
      await tester.pump();
    });

    testWidgets('sin tirada (dados vacíos), los dados no responden aunque '
        'haya callback', (tester) async {
      var llamado = false;
      await tester.pumpWidget(
        _envolver(PanelDados(dados: const [], onDadoTocado: (_) => llamado = true)),
      );

      await tester.tap(find.byKey(const ValueKey('dado_0')));
      await tester.pump();

      expect(llamado, isFalse);
    });

    testWidgets('pide elegir un dado mientras no haya ninguno elegido',
        (tester) async {
      await tester.pumpWidget(
        _envolver(PanelDados(dados: const [3, 6], onDadoTocado: (_) {})),
      );

      expect(find.textContaining('Elige un dado'), findsOneWidget);
    });

    testWidgets('ya con un dado elegido, la invitación desaparece',
        (tester) async {
      await tester.pumpWidget(
        _envolver(
          PanelDados(
            dados: const [3, 6],
            indiceSeleccionado: 0,
            onDadoTocado: (_) {},
          ),
        ),
      );

      expect(find.textContaining('Elige un dado'), findsNothing);
    });
  });
}
